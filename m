From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Thu, 13 Feb 2014 14:22:57 -0800
Message-ID: <CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
	<B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
	<CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
	<6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
	<CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
	<FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:57488 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaBMWW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:22:57 -0500
Received: by mail-oa0-f45.google.com with SMTP id i11so13655679oag.32
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 14:22:57 -0800 (PST)
In-Reply-To: <FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 6:55 PM, hayeswang <hayeswang@realtek.com> wrote:
...
> According to the information from our FAE about the dangles for samsung,
> the default values of some device power are disabled or off. I don't know
> the history about this. However, it would cause the dangle no link, because
> the ecm driver wouldn't enable them. That is, the dangle couldn't use the
> ECM mode.

That makes sense. How can I check that?

> I think you should create a udev rule to change the configuration
> to 1 when the dangle is plugged. Then, it could load the vendor mode driver.

Which "configuration" are you referring to?
Something like this? /sys/devices/12110000.usb/usb3/3-2/bConfigurationValue

I'm happy to try any command line you give me.

If that command works, I can write the udev rule for future testing
with these devices.

> I don't think so. The reason is as above. Change the configuration of the
> device to 1 (vendor mode) is what you have to do.

Ok...just need one more bit of guidance from you and this will be
resolved I think.

cheers,
grant
