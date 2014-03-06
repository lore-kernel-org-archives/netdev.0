From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Thu, 6 Mar 2014 10:57:28 +0800
Message-ID: <ABDC71BA1D664CE2AC25DC45DC8BEBCD@realtek.com.tw>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com><B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw><CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com><6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw><CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com><FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw><CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com><65183A93811745C58958ECBAD0B8E00F@realtek.com.tw><CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com><CANEJEGsMafeZQDfnmdgmf2VN0CKrTkjVHwKTX9JHTDUUqwx0Mg@mail.gmail.com><FB59F84B1E5E42AA98F0906286C444DF@realtek.com.tw><CANEJEGvMPMT3OroMGLJaR65uEz0+JVYkd5rxcPMMGT_wzvds+w@mail.gmail.com><D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw><CANEJEGuCWZSBNppE
 +W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com><6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw><CANEJEGuuJ=Jt2gAY_LCURk4hg1XvPL_Er0G0mTHSY-YVt0On4g@mail.gmail.com><8BAC0B4EC07D4C7DA6F45A61DF846689!
 @realtek.
 c	om.tw> <CANEJEGu0_7Vv_y7hfxag28=k7uEJzOJxHTz_wywcSDmAHN4nNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Inki Yoo' <inky.yoo@samsung.com>,
	'netdev' <netdev@vger.kernel.org>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:42519 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229AbaCFC5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 21:57:31 -0500
In-Reply-To: <CANEJEGu0_7Vv_y7hfxag28=k7uEJzOJxHTz_wywcSDmAHN4nNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler [mailto:grundler@google.com] 
> Sent: Wednesday, March 05, 2014 5:28 AM
> To: hayeswang
> Cc: Inki Yoo; netdev
> Subject: Re: RTL8153 fails to get link after applying 
> c7de7dec2 to 3.8 kernel
[...]
> I now slightly better understand your previous "Windows settings"
> comment. And I'm under the impression questions about any HW vendor
> shipping devices with "Windows Settings" will land in this forum again
> with "WTF? link doesn't come up". Am I judging this correctly?

Excuse me. I don't sure what is your question. I hope the followings
could answer you. The action of setting the configuration for Windows
is done, when the driver is loaded. Therefore, the driver could determine
which config to set, and could avoid this situation. However, the config
is set before loading the the device driver for Linux. Besides, for
keeping the config switchable, the driver wouldn't change the config.
Additionally, the default config which would be set is the ECM mode.
All of them result in the problem you find.

I think the settings is for power saving, because it could save the power
before loading the driver. However, it is not suitable for Linux platform.

> I think it's Realtek's responsibility to advise those HW vendors more
> carefully to make sure what happened to Samsung doesn't happen again.
> Either by removing the settings or by adding the support (if possible
> for a given setting) to the ECM mode linux driver.

Thanks for you suggestions. I would report them to the relative people.
