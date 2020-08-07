--v0.99
-- i have no idea what im doing anymore
function appcull()
	if (offset < 0) then
		offset = 0
	elseif (offset > #apps - 4) then
		offset = #apps - 4
	end
	for i = 1, 4 do
		if (psv:match(apps[offset + tmp])) then
			apptype = vita
		elseif (psm:match(apps[offset + tmp])) then
			apptype = mobile
		end
		if (System.doesFileExist(apptype .. apps[offset + tmp] .. '/icon0.png')) then
			app0 = Graphics.loadImage(apptype .. apps[offset + tmp] .. '/icon0.png')
		else
			app0 = Graphics.loadImage('app0:/app/noicon.png')
		end
		if (tmp == 1) then
			app1 = app0
		elseif (tmp == 2) then
			app2 = app0
		elseif (tmp == 3) then
			app3 = app0
		elseif (tmp == 4) then
			app4 = app0
		end
		tmp = tmp + 1
	end
	update = 0
	x = y
end

-- init stuffs
lang = 'en'
bgicon = Graphics.loadImage('app0:/app/bgicon.png')
font = Font.load('app0:/app/Meiryo.ttf')
font2 = Font.load('app0:/app/Meiryo.ttf')
white = Color.new(255, 255, 255)
grey = Color.new(87, 87, 87)
black = Color.new(0, 0, 0)
y = -100
vita = 'ur0:/appmeta/'
mobile = 'app0:/app/'

-- check if psm dir exists and create if not (uses an additional 4kb)
apps_psm = System.listDirectory('ux0:/psm')
if not (apps_psm) then
	System.createDirectory('ux0:/psm')
end

-- get app list
apps = {}
app_ux0 = System.listDirectory('ux0:/app')
app_psm = System.listDirectory('ux0:/psm')
num = 1
num1 = 1
psv = ''
psm = ''
for i = 1, #app_ux0 do
	if (app_ux0[num].name:match('PCS')) then -- games only
		apps[num1] = app_ux0[num].name
		if (System.doesFileExist('ur0:/appmeta/' .. apps[num1] .. '/icon0.png')) then
			psv = psv .. apps[num1]
		end
		num1 = num1 + 1
	end
	num = num + 1
end
num = 1
for i = 1, #app_psm do
	apps[num1] = app_psm[num].name
	if (System.doesFileExist('app0:/app/' .. apps[num1] .. '/icon0.png')) then
		psm = psm .. apps[num1]
	end
	num1 = num1 + 1
	num = num + 1
end

--load descriptions
appdesc = {}
apptmp = 1
for i = 1, #apps do -- inefficient, not io.open so wont bother doing it correct
	if (System.doesFileExist('app0:/app/' .. lang .. '_' .. apps[apptmp] .. '.lua')) then
		dofile('app0:/app/' .. lang .. '_' .. apps[apptmp] .. '.lua')
		appdesc[apptmp] = description
	else
		appdesc[apptmp] = 'No description exists for ' .. lang .. '_' .. apps[apptmp] .. ', please contact Candeggiare or make one yourself.'
	end
	apptmp = apptmp + 1
end

-- drawscreen
delay = 2
first = 1
first1 = 1
update = 1
x = y
offset = 0
change = 0
cull = 10
tt = 31
tmp = 1
x3 = 0
y3 = 0
appcull()
Font.setPixelSizes(font2, 100)
Font.setPixelSizes(font, 15)
while true do
	x1, y1 = Controls.readTouch() -- touchscreen shit
	if (x1 ~= nil) and (delay <= 0) then
		if (first == 1) then
			first = 0
			y2 = y1
		end
		delay = 2
		y = y + (y1 - y2)
		y2 = y1
	else
		delay = delay - 1
		if (x1 == nil) then
			first = 1
		end
	end
	if (x1 ~= nil) then -- taps
		x3 = x1
		y3 = y1
		if (first1 == 1) then
			first1 = 0
			tt = 0
		else
			tt = tt + 0.1
		end
	end
	if (tt <= 30) and (x1 == nil) then
		tt = 0
		first1 = 1
		if (x3 <= 281) then
			colour = Screen.getPixel(x3, y3)
			if (colour ~= 000000) or (colour ~= 255255255) then
				idk = 1
			end
		end
	end
	if (x - y <= -175) then -- track touch for culling
		update = 1
		offset = offset - 1
	elseif (x - y >= 175) then
		update = 1
		offset = offset + 1
	end
	Graphics.initBlend()
	Screen.clear()
	tmp = 1
	tmp1 = 1
	for i = 1, #apps do -- ultra inefficient
		if not (y + (281 * tmp) > 825) then
			if not (y + (281 * tmp) < -281) then
				Graphics.drawScaleImage(25, y + (281 * tmp), bgicon, 2, 2) -- draw this always because of games like jet set radio
				cull = cull - 0.1
				if (offset == 0) and (cull <= 0) then
					offset = tmp
					cull = 10
				end
				Graphics.drawScaleImage(25, y + (281 * tmp), app1, 2, 2)
				Graphics.drawScaleImage(25, y + (281 * (tmp + 1)), app2, 2, 2)
				Graphics.drawScaleImage(25, y + (281 * (tmp + 2)), app3, 2, 2)
				Graphics.drawScaleImage(25, y + (281 * (tmp + 3)), app4, 2, 2)
				Font.print(font, 288, y + (281 * tmp), appdesc[tmp], grey)
			end
		end
		tmp = tmp + 1
	end
	if (update == 1) then -- app culling
		tmp = 1
		appcull()
	end
	Graphics.fillRect(0, 960, 0, 45, black)
	Font.print(font2, -24, -60, "apps", white)
	Graphics.debugPrint(0, 0, Screen.getPixel(x3, y3), grey)
	Graphics.termBlend()
	Screen.flip()
end