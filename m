From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Current git r8169 driver often misses link at boot
Date: Wed, 22 Oct 2008 01:50:11 +0200
Message-ID: <20081021235011.GL12825@one.firstfloor.org>
References: <20081021191158.GA16262@basil.nowhere.org> <20081021202601.GA24322@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58456 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbYJUXmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 19:42:51 -0400
Content-Disposition: inline
In-Reply-To: <20081021202601.GA24322@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2008 at 10:26:01PM +0200, Francois Romieu wrote:
> Andi Kleen <andi@firstfloor.org> :
> [...]
> > I have a nfsroot test system with a r8169 NIC. Since I updated
> > from 2.6.27 to 2.6.27-git10 it doesn't find its root fs in 2 out of
> > 3 boots. The r8169 gets detected, but there is never
> > a message that it finds the link in the failed cases:
> > 
> > r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > r8169 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> > r8169 0000:02:00.0: setting latency timer to 64
> > r8169 0000:02:00.0: irq 45 for MSI/MSI-X
> > eth0: RTL8168b/8111b at 0xffffc2000035a000, 00:00:00:00:00:00, XID 38000000 IRQ 45
> 
> The workarounds are in Jeff's tree as :
> 9b1abbccf53ef1a1213b159d56257b535c599f07
> d7d25be4418b609e54b407458003a4b6bff1c63b

Confirmed.

With upstream-fixes it survived three boots now. Can this fix please
be submitted ASAP, not having it impacts testing here.

Thanks,
-Andi
