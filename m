From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 2/5] Trivial fix to spelling mistake in arc_printk message
Date: Wed, 28 Jun 2017 18:28:34 +0200
Message-ID: <20170628162837.21856-3-m.grzeschik@pengutronix.de>
References: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        Colin Ian King <colin.king@canonical.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:39943 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751592AbdF1Q2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:28:51 -0400
In-Reply-To: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/capmode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index a80f4eb9262d5..b780be6f41ff9 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -212,7 +212,7 @@ static int ack_tx(struct net_device *dev, int acked)
 	ackpkt->soft.cap.proto = 0; /* using protocol 0 for acknowledge */
 	ackpkt->soft.cap.mes.ack = acked;
 
-	arc_printk(D_PROTO, dev, "Ackknowledge for cap packet %x.\n",
+	arc_printk(D_PROTO, dev, "Acknowledge for cap packet %x.\n",
 		   *((int *)&ackpkt->soft.cap.cookie[0]));
 
 	ackskb->protocol = cpu_to_be16(ETH_P_ARCNET);
-- 
2.11.0
