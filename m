From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: NIC driver r8168 with r8169 for RTL8111/8168B and DGE-528T together
Date: Wed, 20 Jul 2011 22:30:41 +0200
Message-ID: <20110720203041.GA10317@electric-eye.fr.zoreil.com>
References: <4E26B198.4020606@telkomsa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Danie Wessels <dawessels@telkomsa.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39798 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab1GTUpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 16:45:55 -0400
Content-Disposition: inline
In-Reply-To: <4E26B198.4020606@telkomsa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Danie Wessels <dawessels@telkomsa.net> :
[...]
> I would like to use my onboard NIC (eth0) with its r8168 driver from
> RealTek together with my D-Link NIC (eth4=eth1) with its r8169
> default driver from the install. Sepatately they seem to work...but
> I would like a firewall set up with NAT and had it before I
> "upgraded". ;^)

Remove the 8168 PCI IDs from the r8169 driver and you should be set.

[...]
>    [ 1.486546] r8169 0000:03:00.0: eth0: RTL8168b/8111b at
> 0xf8024000, 00:1c:c0:a7:03:49, XID 98500000 IRQ 43

It ought to be supported by the kernel r8169 driver.

Which problem(s) do you have with it ?

-- 
Ueimor
