From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Possible bug with r8169 driver
Date: Fri, 28 Sep 2012 00:21:47 +0200
Message-ID: <20120927222147.GA29047@electric-eye.fr.zoreil.com>
References: <2197741.c8FeV4Xbis@bureau>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Nolwenn <donolwenn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45125 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab2I0Wkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:40:49 -0400
Content-Disposition: inline
In-Reply-To: <2197741.c8FeV4Xbis@bureau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nolwenn <donolwenn@gmail.com> :
[...]
> I'm on Archlinux (kernel 3.5.4), I need to set eth0 to promiscuous to get a 
> stable IPv6 connectivity. My internet access provider is Free (France) and 
> IPv6 is enable on the box. 
> If eth0 is not set to promiscuous, I need to intercep packets with 
> "tcpdump -nvvv ip6" to get an IPv6 connectivity and it's lost, a few later, 
> when interception is stopped. 

Can you send an 'ip -s link' before any ipv6 traffic flows, then
after ?

> % dmesg | grep r8169 
> 
> [    1.810423] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.810548] r8169 0000:03:00.0: irq 44 for MSI/MSI-X
> [    1.810671] r8169 0000:03:00.0: eth0: RTL8168f/8111f at 0xffffc900057ae000, 30:85:a9:ee:43:fa, XID 08000800 IRQ 44
> [    1.810672] r8169 0000:03:00.0: eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]

Hayes, is there by any luck something different for the 8168f regarding
the layout of the multicast filtering registers ?

Thanks.

-- 
Ueimor
