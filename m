From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 2/2] net: gianfar - align BD ring size console messages
Date: Tue, 30 Mar 2010 16:54:22 -0500
Message-ID: <1269986062-1697-2-git-send-email-kim.phillips@freescale.com>
References: <1269986062-1697-1-git-send-email-kim.phillips@freescale.com>
Cc: Kim Phillips <kim.phillips@freescale.com>
To: "David S. Miller" <davem@davemloft.net>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Andy Flem
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54973 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab0C3Vqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 17:46:40 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o2ULkdGY006915
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 14:46:39 -0700 (MST)
Received: from az33exm22.fsl.freescale.net (az33exm22.am.freescale.net [10.64.32.10])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id o2ULsBHt007639
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 16:54:11 -0500 (CDT)
In-Reply-To: <1269986062-1697-1-git-send-email-kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix this:

eth2: :RX BD ring size for Q[0]: 256
eth2:TX BD ring size for Q[0]: 256

to look like:

eth2: RX BD ring size for Q[0]: 256
eth2: TX BD ring size for Q[0]: 256

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/gianfar.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index d557ab6..5131d12 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1120,10 +1120,10 @@ static int gfar_probe(struct of_device *ofdev,
 	/* provided which set of benchmarks. */
 	printk(KERN_INFO "%s: Running with NAPI enabled\n", dev->name);
 	for (i = 0; i < priv->num_rx_queues; i++)
-		printk(KERN_INFO "%s: :RX BD ring size for Q[%d]: %d\n",
+		printk(KERN_INFO "%s: RX BD ring size for Q[%d]: %d\n",
 			dev->name, i, priv->rx_queue[i]->rx_ring_size);
 	for(i = 0; i < priv->num_tx_queues; i++)
-		 printk(KERN_INFO "%s:TX BD ring size for Q[%d]: %d\n",
+		 printk(KERN_INFO "%s: TX BD ring size for Q[%d]: %d\n",
 			dev->name, i, priv->tx_queue[i]->tx_ring_size);
 
 	return 0;
-- 
1.7.0.2

