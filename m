From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Wed, 12 Feb 2014 15:58:27 -0800
Message-ID: <CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
	<B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
	<CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
	<6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:63018 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbaBLX61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 18:58:27 -0500
Received: by mail-ob0-f176.google.com with SMTP id gq1so11356566obb.35
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 15:58:27 -0800 (PST)
In-Reply-To: <6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 11, 2014 at 7:47 PM, hayeswang <hayeswang@realtek.com> wrote:
> It still works for me. The followings are some messages from Fedora 20 with kernel 3.14.rc2.

Perfect - thanks for following up.

...
> # ethtool -i eth0
> driver: r815x
> version: 22-Aug-2005

BTW, can you please update the version number to match adding RTL8153 support?
Makes life easier for anyone maintaining older kernels.

> Is your dangle from Samsung?

It's labeled "Realtek USB 3.0 Gigabit Ethernet" externally. I'm not
sure if we got these from Samsung or directly from RealTek.

What's notable is this device has no link or activity LEDs visible.
Normally I'd expect those near the RJ45 port.

Also no MAC address or serial number or anything to further identify
the devices. just the "rectangular black plastic" enclosure with a
silver sticker carrying the Realtek logo + text.

> I would ask our PM to check if there is any difference between our devices.
> Maybe it is not the driver issue.

I don't think it's a r8152 or r815x driver issue either. It's much
more likely related to chromeos-3.8 USB NET patches not matching 3.14
kernel behaviors.

Please don't pursue further. Unless I have a good reason to debug
chromeos-3.8 kernel, I'd rather not. If I have problems with 3.12 or
later kernels, I'd be more motivated and will pester you again. :)

Thanks!
grant
