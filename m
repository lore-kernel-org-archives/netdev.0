From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/8] can: rcar_can: fix typo in error message
Date: Sun, 12 Jul 2015 21:18:06 +0200
Message-ID: <1436728691-1145-4-git-send-email-mkl@pengutronix.de>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Fix typo in the first error message printed by rcar_can_open().

Based on the original patch by Vladimir Barinov.

Fixes: 862e2b6af941 ("can: rcar_can: support all input clocks")
Reported-by: Vladimir Barinov <vladimir.barinov@cogentembedded.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/rcar_can.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index 2f9ebad4ff56..310a0cd20679 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -508,7 +508,8 @@ static int rcar_can_open(struct net_device *ndev)
 
 	err = clk_prepare_enable(priv->clk);
 	if (err) {
-		netdev_err(ndev, "failed to enable periperal clock, error %d\n",
+		netdev_err(ndev,
+			   "failed to enable peripheral clock, error %d\n",
 			   err);
 		goto out;
 	}
-- 
2.1.4

