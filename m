From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 4/4] net/macb: trivial: correct wording of for caps
Date: Fri, 27 Mar 2015 16:34:12 +0100
Message-ID: <93279a83ffa1e098ad72976c9863f9b6321f565e.1427469791.git.nicolas.ferre@atmel.com>
References: <cover.1427469791.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	<monstr@monstr.eu>, <michal.simek@xilinx.com>,
	<punnaia@xilinx.com>, Nicolas Ferre <nicolas.ferre@atmel.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427469791.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As a non-native English speaker, I would correct "capacities" of the macb
peripheral to "capabilities": correct me if I'm wrong!

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 64e35a50e5c1..3032ae052755 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2129,7 +2129,7 @@ static const struct net_device_ops macb_netdev_ops = {
 };
 
 /*
- * Configure peripheral capacities according to device tree
+ * Configure peripheral capabilities according to device tree
  * and integration options used
  */
 static void macb_configure_caps(struct macb *bp, const struct macb_config *dt_conf)
@@ -2731,7 +2731,7 @@ static int macb_probe(struct platform_device *pdev)
 		}
 	}
 
-	/* setup capacities */
+	/* setup capabilities */
 	macb_configure_caps(bp, macb_config);
 
 	platform_set_drvdata(pdev, dev);
-- 
2.1.3
