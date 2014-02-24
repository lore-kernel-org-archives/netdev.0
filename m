From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Mon, 24 Feb 2014 08:17:40 -0800
Message-ID: <CANEJEGuCWZSBNppE+W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:39499 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbaBXQRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 11:17:41 -0500
Received: by mail-oa0-f46.google.com with SMTP id l6so630272oag.19
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 08:17:40 -0800 (PST)
In-Reply-To: <D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hayes,

On Sun, Feb 23, 2014 at 10:00 PM, hayeswang <hayeswang@realtek.com> wrote:
...
>> Or you have any idea why ECM mode doesn't work with c7de7dec2 patch?
>
> The reason is that your dangle has the settings of the
> customization for some purposes. And it limites the dangle
> could use the vendor mode only.

Does Realtek have a publicly available tool that I can use to set all
customization back to "official" values?

> My dangle with the official settings works fine, so I consider that this
> is not a bug. Instead, I consider it it the limitation of the hardware.

Sorry, I disagree. Where "customization" is available, I expect the
device driver to know/understand those values OR set them to some
state the driver knows how to deal with. This is a limitation of the
driver, not the HW.



>
> Best Regards,
> Hayes
>
