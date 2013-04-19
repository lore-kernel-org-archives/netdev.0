From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Fri, 19 Apr 2013 16:36:02 +0200
Message-ID: <1366382164-10968-2-git-send-email-l.stach@pengutronix.de>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Fabio Estevam <festevam@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60797 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030604Ab3DSOhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:37:09 -0400
In-Reply-To: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 3f104c38259dcb3e5443c246f0805bc04d887cc3.
---
 drivers/net/ethernet/freescale/fec.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index a23f298..5721ca1 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1513,7 +1513,6 @@ fec_enet_close(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
 	/* Don't know what to do yet. */
-	napi_disable(&fep->napi);
 	fep->opened = 0;
 	netif_stop_queue(ndev);
 	fec_stop(ndev);
-- 
1.8.2.rc2
