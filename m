From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 performance?
Date: Mon, 5 Dec 2011 07:44:03 +0100
Message-ID: <20111205064403.GA3426@electric-eye.fr.zoreil.com>
References: <20111204211007.GA32098@hiwaay.net> <20111204234004.GA32515@electric-eye.fr.zoreil.com> <20111205004650.GA5948@hiwaay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chris Adams <cmadams@hiwaay.net>, netdev@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59062 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab1LEGur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 01:50:47 -0500
Content-Disposition: inline
In-Reply-To: <20111205004650.GA5948@hiwaay.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Adams <cmadams@hiwaay.net> :
[...]
> On the "problem" computer (on Fedora 16, kernel 3.1.2):
> 
> [    7.101106] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    7.102665] r8169 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> [    7.107308] r8169 0000:02:00.0: setting latency timer to 64
> [    7.107370] r8169 0000:02:00.0: irq 42 for MSI/MSI-X
> [    7.107703] r8169 0000:02:00.0: eth0: RTL8168d/8111d at 0xffffc900112fc000, 00:19:66:f2:dc:0b, XID 081000c0 IRQ 42
> 
> On the "okay" computer (on Fedora 14, kernel 2.6.35.14):
> 
> [    9.053574] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    9.053594] r8169 0000:06:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> [    9.053689] r8169 0000:06:00.0: setting latency timer to 64
> [    9.053740] r8169 0000:06:00.0: irq 47 for MSI/MSI-X
> [    9.053830] r8169 0000:06:00.0: eth0: RTL8168d/8111d at 0xffffc90012998000, 6c:f0:49:b7:67:91, XID 083000c0 IRQ 47

Almost the same: RTL_GIGA_MAC_VER_25 versus RTL_GIGA_MAC_VER_26 (faster).

The only difference in the driver is the hw_phy_config part.

-- 
Ueimor
