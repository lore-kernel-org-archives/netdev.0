From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Fri, 26 Apr 2013 10:52:08 +0200
Message-ID: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Lucas Stach <l.stach@pengutronix.de>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50044 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758049Ab3DZIxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 04:53:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 3f104c38259dcb3e5443c246f0805bc04d887cc3.

In preparaton to revert the other NAPI related changes.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 73195f6..afb52eb 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1490,7 +1490,6 @@ fec_enet_close(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
 	/* Don't know what to do yet. */
-	napi_disable(&fep->napi);
 	fep->opened = 0;
 	netif_stop_queue(ndev);
 	fec_stop(ndev);
-- 
1.8.2.rc2
