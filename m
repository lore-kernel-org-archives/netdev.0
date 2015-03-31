From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 4/8] net/macb: trivial: correct wording for caps
Date: Tue, 31 Mar 2015 15:02:02 +0200
Message-ID: <1427806926-18887-5-git-send-email-nicolas.ferre@atmel.com>
References: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	<michal.simek@xilinx.com>, <punnaia@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As a non-native English speaker, I would correct "capacities" of the macb
peripheral to "capabilities": correct me if I'm wrong!

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

Changes in v2: None

 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 680e1eebb7ea..e27bc6964402 100644
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
