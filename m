From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec: Adjust ENET MDIO timeouts
Date: Tue, 27 Dec 2011 14:07:47 -0500 (EST)
Message-ID: <20111227.140747.1238640414600997264.davem@davemloft.net>
References: <1324997198-2241-1-git-send-email-festevam@gmail.com>
	<1325012021-3134-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de, rogerio.pimentel@freescale.com,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab1L0TIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 14:08:54 -0500
In-Reply-To: <1325012021-3134-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 27 Dec 2011 16:53:41 -0200

> On extensive NFS boots on a mx6qsabrelite board it was noted that "FEC: MDIO read timeout" were occuring,
> which caused failure on loading the FEC driver.
> 
> The original FEC_MII_TIMEOUT was set to 1 ms, which is too low when passed to the usecs_to_jiffies macro.
> 
> On ARM one jiffy is 10ms, so use a timeout of 30ms, which corresponds to 3 jiffies.
> 
> After running extensive NFS boots, the MDIO timeouts do not occur anymore with this change.
> 
> Signed-off-by: Rogerio Pimentel <rogerio.pimentel@freescale.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
