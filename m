From: Colin King <colin.king@canonical.com>
Subject: [PATCH] arcnet: fix spelling mistake "Ackknowledge" -> "Acknowledge"
Date: Sun, 25 Jun 2017 22:15:06 +0100
Message-ID: <20170625211506.29222-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Michael Grzeschik <m.grzeschik@pengutronix.de>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in arc_printk message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/arcnet/capmode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index a80f4eb9262d..b780be6f41ff 100644
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
