From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 11/12] net: axienet: Removed _of_ prefix in probe and remove functions
Date: Tue,  5 May 2015 11:26:04 +0200
Message-ID: <20da6b057ab3ec4bc0fd9709e153163612a32ea3.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

Synchronize names with other drivers.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index dec7e9918db4..1781265e3dc3 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1479,7 +1479,7 @@ static void axienet_dma_err_handler(unsigned long data)
 }
 
 /**
- * axienet_of_probe - Axi Ethernet probe function.
+ * axienet_probe - Axi Ethernet probe function.
  * @pdev:	Pointer to platform device structure.
  * @match:	Pointer to device id structure
  *
@@ -1491,7 +1491,7 @@ static void axienet_dma_err_handler(unsigned long data)
  * device. Parses through device tree and populates fields of
  * axienet_local. It registers the Ethernet device.
  */
-static int axienet_of_probe(struct platform_device *pdev)
+static int axienet_probe(struct platform_device *pdev)
 {
 	int ret;
 	struct device_node *np;
@@ -1636,7 +1636,7 @@ free_netdev:
 	return ret;
 }
 
-static int axienet_of_remove(struct platform_device *pdev)
+static int axienet_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct axienet_local *lp = netdev_priv(ndev);
@@ -1652,16 +1652,16 @@ static int axienet_of_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct platform_driver axienet_of_driver = {
-	.probe = axienet_of_probe,
-	.remove = axienet_of_remove,
+static struct platform_driver axienet_driver = {
+	.probe = axienet_probe,
+	.remove = axienet_remove,
 	.driver = {
 		 .name = "xilinx_axienet",
 		 .of_match_table = axienet_of_match,
 	},
 };
 
-module_platform_driver(axienet_of_driver);
+module_platform_driver(axienet_driver);
 
 MODULE_DESCRIPTION("Xilinx Axi Ethernet driver");
 MODULE_AUTHOR("Xilinx");
-- 
2.3.5
