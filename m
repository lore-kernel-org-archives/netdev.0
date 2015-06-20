From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/3] rcar_can: fix typo in error message
Date: Sat, 20 Jun 2015 03:34:55 +0300
Message-ID: <7487668.8ZFbI2F5E8@wasted.cogentembedded.com>
References: <2010452.WyFito6egU@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2010452.WyFito6egU@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix typo in the first error message printed by rcar_can_open().

Based on the original patch by Vladimir Barinov.

Fixes: 862e2b6af941 ("can: rcar_can: support all input clocks")
Reported-by: Vladimir Barinov <vladimir.barinov@cogentembedded.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/can/rcar_can.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-can/drivers/net/can/rcar_can.c
===================================================================
--- linux-can.orig/drivers/net/can/rcar_can.c
+++ linux-can/drivers/net/can/rcar_can.c
@@ -508,7 +508,8 @@ static int rcar_can_open(struct net_devi
 
 	err = clk_prepare_enable(priv->clk);
 	if (err) {
-		netdev_err(ndev, "failed to enable periperal clock, error %d\n",
+		netdev_err(ndev,
+			   "failed to enable peripheral clock, error %d\n",
 			   err);
 		goto out;
 	}

--
To unsubscribe from this list: send the line "unsubscribe linux-sh" in
