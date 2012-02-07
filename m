From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Fix build due to wrong dev annotation
Date: Tue, 07 Feb 2012 13:33:07 -0500 (EST)
Message-ID: <20120207.133307.109701321398712057.davem@davemloft.net>
References: <1328639251-26310-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev@pradeepdalvi.com,
	kernel@pengutronix.de, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755808Ab2BGSeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:34:21 -0500
In-Reply-To: <1328639251-26310-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue,  7 Feb 2012 16:27:31 -0200

> commit 21a4e469 (netdev: ethernet dev_alloc_skb to netdev_alloc_skb) 
> should have used "ndev" instead of "dev".
> 
> This causes the following build errors:
> 
> drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_rx':
> drivers/net/ethernet/freescale/fec.c:714: error: 'dev' undeclared (first use in this function)
> drivers/net/ethernet/freescale/fec.c:714: error: (Each undeclared identifier is reported only once
> drivers/net/ethernet/freescale/fec.c:714: error: for each function it appears in.)
> drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_alloc_buffers':
> drivers/net/ethernet/freescale/fec.c:1213: error: 'dev' undeclared (first use in this function)
> 
> Fix it, so that fec driver can be built again.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
