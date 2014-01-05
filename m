From: =?ISO-8859-1?Q?Fejes_J=F3zsef?= <jozsef.fejes@gmail.com>
Subject: Re: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Sun, 5 Jan 2014 08:28:06 +0100
Message-ID: <CALU-w99x8k+J46xaK28wn0gMr=D4Q6YHHKi-wjwOXfFCBo-vEw@mail.gmail.com>
References: <CALU-w9860x_rWhu35v50N39b8AxiPB_wOk1OUKdBr9eBLzEZFA@mail.gmail.com>
	<20131230233833.GA434@electric-eye.fr.zoreil.com>
	<CALU-w99eT4TX0xHc_KZBoP_JFpEex-0B8iH3sb8wUMfO4WuOHg@mail.gmail.com>
	<20140101223806.GA18715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:44266 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaAEH2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 02:28:08 -0500
Received: by mail-wg0-f45.google.com with SMTP id y10so14535379wgg.0
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 23:28:07 -0800 (PST)
In-Reply-To: <20140101223806.GA18715@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Could you check the irq count and ethtool -S eth0 as well ?

Here you go: http://pastebin.com/acabFBHv

> Does the laptop also include a different operating system ?

Yes, Windows 7.

>> I haven't used that interface for quite some time, a year at most. I
>> keep up to date with the stable kernels, so a version change broke it,
>> but I'm not sure which. Would it be the best course of action if I
>> tried some older versions?
>
> Yes, please do.
>
> There has been no specific change in this timeframe for the chipset you
> use (RTL_GIGA_MAC_VER_25). The problem may have been unnoticed for a
> rather long time. :o/

I booted into an old kernel I found in the Debian repository: Linux
wicklow 3.2.0-4-686-pae #1 SMP Debian 3.2.53-2 i686 GNU/Linux

And the same issue happened. Queue times out, no packets are received
on the other end.

Could it be that this regression ended up in this long-term supported
kernel? Or could it be a hardware problem? My Windows laptop's
ethernet definitely works in other places, so could be the cable or
the integrated NIC in the Linux machine...

Best regards,
Jozsef
