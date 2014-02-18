From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fec: only enable napi if we are successful
Date: Tue, 18 Feb 2014 18:07:30 -0500 (EST)
Message-ID: <20140218.180730.54681622364091114.davem@davemloft.net>
References: <E1WFkD8-0004pj-Pr@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	dmalek@jlc.net, gerg@snapgear.com, phdm@macqel.be,
	fabio.estevam@freescale.com
To: rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbaBRXHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 18:07:33 -0500
In-Reply-To: <E1WFkD8-0004pj-Pr@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Tue, 18 Feb 2014 12:55:42 +0000

> If napi is left enabled after a failed attempt to bring the interface
> up, we BUG:
> 
> fec 2188000.ethernet eth0: no PHY, assuming direct connection to switch
> libphy: PHY fixed-0:00 not found
> fec 2188000.ethernet eth0: could not attach to PHY
> ------------[ cut here ]------------
> kernel BUG at include/linux/netdevice.h:502!
> Internal error: Oops - BUG: 0 [#1] SMP ARM
> ...
> PC is at fec_enet_open+0x4d0/0x500
> LR is at __dev_open+0xa4/0xfc
> 
> Only enable napi after we are past all the failure paths.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied, thanks a lot Russell.
