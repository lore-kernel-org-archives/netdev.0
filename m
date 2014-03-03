From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Mon, 3 Mar 2014 11:00:20 +0800
Message-ID: <8BAC0B4EC07D4C7DA6F45A61DF846689@realtek.com.tw>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com><B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw><CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com><6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw><CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com><FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw><CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com><65183A93811745C58958ECBAD0B8E00F@realtek.com.tw><CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com><CANEJEGsMafeZQDfnmdgmf2VN0CKrTkjVHwKTX9JHTDUUqwx0Mg@mail.gmail.com><FB59F84B1E5E42AA98F0906286C444DF@realtek.com.tw><CANEJEGvMPMT3OroMGLJaR65uEz0+JVYkd5rxcPMMGT_wzvds+w@mail.gmail.com><D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw><CANEJEGuCWZSBNppE
 +W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com><6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw> <CANEJEGuuJ=Jt2gAY_LCURk4hg1XvPL_Er0G0mTHSY-YVt0On4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Inki Yoo' <inky.yoo@samsung.com>,
	'netdev' <netdev@vger.kernel.org>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41391 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbaCCDAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 22:00:24 -0500
In-Reply-To: <CANEJEGuuJ=Jt2gAY_LCURk4hg1XvPL_Er0G0mTHSY-YVt0On4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Grant Grundler [mailto:grundler@google.com] 
> Sent: Thursday, February 27, 2014 1:09 AM
> To: hayeswang
> Cc: Inki Yoo; netdev
> Subject: Re: RTL8153 fails to get link after applying 
> c7de7dec2 to 3.8 kernel
[...]
> > You couldn't fix it in ECM mode.
> > The only way is to switch the config to the vendor mode.
> 
> Hrm. Or replace the firmware on the device?

The settings are embedded in the hw IC. They could be programed
only once for each IC, and they couldn't be recovered. You could
not modify them by sw or updating something, so I don't know if
there is any tool to change it. The best way is to get an empty
IC and program another settings.
 
Best Regards,
Hayes
