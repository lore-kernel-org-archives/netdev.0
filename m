From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Tue, 4 Mar 2014 13:27:35 -0800
Message-ID: <CANEJEGu0_7Vv_y7hfxag28=k7uEJzOJxHTz_wywcSDmAHN4nNw@mail.gmail.com>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
	<B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
	<CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
	<6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
	<CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
	<FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw>
	<CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com>
	<65183A93811745C58958ECBAD0B8E00F@realtek.com.tw>
	<CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com>
	<CANEJEGsMafeZQDfnmdgmf2VN0CKrTkjVHwKTX9JHTDUUqwx0Mg@mail.gmail.com>
	<FB59F84B1E5E42AA98F0906286C444DF@realtek.com.tw>
	<CANEJEGvMPMT3OroMGLJaR65uEz0+JVYkd5rxcPMMGT_wzvds+w@mail.gmail.com>
	<D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw>
	<CANEJEGuCWZSBNppE+W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com>
	<6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw>
	<CANEJEGuuJ=Jt2gAY_LCURk4hg1XvPL_Er0G0mTHSY-YVt0On4g@mail.gmail.com>
	<8BAC0B4EC07D4C7DA6F45A61DF846689@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:63084 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045AbaCDV1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:27:36 -0500
Received: by mail-ob0-f175.google.com with SMTP id uy5so124726obc.20
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 13:27:35 -0800 (PST)
In-Reply-To: <8BAC0B4EC07D4C7DA6F45A61DF846689@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 2, 2014 at 7:00 PM, hayeswang <hayeswang@realtek.com> wrote:
...
>> Hrm. Or replace the firmware on the device?
>
> The settings are embedded in the hw IC. They could be programed
> only once for each IC, and they couldn't be recovered.

Samsung apparently didn't understand this either and will get me new
devices that are programmed to work with the Linux driver. It's clear
now I'm not going to be able to use the devices I have for ECM mode
testing since a few of the settings are not final.

I now slightly better understand your previous "Windows settings"
comment. And I'm under the impression questions about any HW vendor
shipping devices with "Windows Settings" will land in this forum again
with "WTF? link doesn't come up". Am I judging this correctly?

I think it's Realtek's responsibility to advise those HW vendors more
carefully to make sure what happened to Samsung doesn't happen again.
Either by removing the settings or by adding the support (if possible
for a given setting) to the ECM mode linux driver.

And seriously, thanks for your help since it properly unraveled a
situation neither I nor Samsung engineers could have identified.

thanks,
grant
