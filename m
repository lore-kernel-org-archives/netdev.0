From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] ax88796: cleanups and convert to phylib and
 mdio_bitbang
Date: Tue, 22 Feb 2011 11:18:56 -0800 (PST)
Message-ID: <20110222.111856.102538007.davem@davemloft.net>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@fluff.org, daniel@caiaq.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754326Ab1BVTSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 14:18:20 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 21 Feb 2011 14:03:11 +0100

> this patch series fixes the phy-read/write problems of the ax88796
> (see http://www.spinics.net/lists/arm-kernel/msg98982.html).
> 
> Patches 1-8 clean verious aspects of the driver. The 9th patch replaces the
> handcrafted mdio bitbang loop with the generic mdio_bitbang driver.
> 
> This patch series has been tested on the Toradex colibri-320. With the patch
> mii-diag gives sound data:
> 
> root@grabowski:~ mii-diag
> Using the default interface 'eth0'.
> Basic registers of MII PHY #16:  3100 782d 003b 1841 01e1 45e1 0003 0000.
>  The autonegotiated capability is 01e0.
> The autonegotiated media type is 100baseTx-FD.
>  Basic mode control register 0x3100: Auto-negotiation enabled.
>  You have link beat, and everything is working OK.
>  Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx 10baseT-FD 10baseT, w/ 802.3X flow control.
>    End of basic transceiver information.
> 
> please review and consider to appply.

Pulled into net-next-2.6, thanks.

BTW, we could remove the ARM MIPS etc. dependencies this driver has,
and replace it with HAS_IOMEM, as all the interfaces the driver uses
should be provided by every architecture.
