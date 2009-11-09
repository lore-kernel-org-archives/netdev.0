From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next-2.6] au1000-eth: convert to
 platform_driver model
Date: Sun, 08 Nov 2009 21:02:36 -0800 (PST)
Message-ID: <20091108.210236.247950385.davem@davemloft.net>
References: <200911081542.12219.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40293
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbZKIFCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 00:02:10 -0500
In-Reply-To: <200911081542.12219.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 8 Nov 2009 15:42:11 +0100

> This patch converts the au1000-eth driver to become a full
> platform-driver as it ought to be. We now pass PHY-speficic
> configurations through platform_data but for compatibility
> the driver still assumes the default settings (search for PHY1 on
> MAC0) when no platform_data is passed. Tested on my MTX-1 board.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Ralf, feel free to merge this yourself since it depends upon
the previous Alchemy platform patch:

Acked-by: David S. Miller <davem@davemloft.net>
