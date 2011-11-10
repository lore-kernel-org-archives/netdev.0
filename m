From: Stefan Becker <chemobejk@gmail.com>
Subject: Re: [PATCH] r8169: more driver shutdown WoL regression.
Date: Thu, 10 Nov 2011 11:40:22 +0200
Message-ID: <CAOJ2eMe7o4sSMiokhGQc17m1-g5qT5jihv=nT1YanxxJdHE-aw@mail.gmail.com>
References: <20111108223502.GA20437@electric-eye.fr.zoreil.com>
	<E6A5E7482020466E82FD141C8CD92D9A@realtek.com.tw>
	<20111109222556.GA8226@electric-eye.fr.zoreil.com>
	<DCB55CA56A5546B4B7350912D30EC679@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65295 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755410Ab1KJJkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 04:40:23 -0500
Received: by wwh12 with SMTP id 12so2053872wwh.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 01:40:22 -0800 (PST)
In-Reply-To: <DCB55CA56A5546B4B7350912D30EC679@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2011 at 6:11 AM, hayeswang <hayeswang@realtek.com> wrote:
>
> I find that the magic packet which I send is the broadcast packet, and the one
> which you send is the unicast packet. That is, you could wake up the system by
> using broadcast magic packet for the previous chips without the patch.

Confirmed. If I use the "-b" option in ether-wake WoL works for my
system with plain 3.1 kernel, i.e. without the patch.

[    8.357467] r8169 0000:02:00.0: eth0: RTL8168c/8111c at 0xf37be000,
00:1f:d0:5a:22:77, XID 1c4000c0 IRQ 43

> However,
> if you prefer to unicast magic packet, this patch is necessary.

As "-b" is not the default for ether-wake it will come as a surprise
for the user that WoL is no longer working. Maybe we should reword the
patch subject to:

  r8169: driver shutdown unicast WoL regression

Regards,

          Stefan
