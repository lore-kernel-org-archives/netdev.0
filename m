From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next] ethernet: ti: remove unwanted THIS_MODULE macro
Date: Mon,  8 Sep 2014 09:28:19 +0530
Message-ID: <1410148699-3724-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, balbi@ti.com, mugunthanvnm@ti.com,
	linux@rainbow-software.org, linux-kernel@vger.kernel.org,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It removes the owner field updation of driver structure.
It will be automatically updated by module_platform_driver()

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c        |    1 -
 drivers/net/ethernet/ti/cpsw-phy-sel.c |    1 -
 drivers/net/ethernet/ti/cpsw.c         |    1 -
 drivers/net/ethernet/ti/davinci_emac.c |    1 -
 drivers/net/ethernet/ti/davinci_mdio.c |    1 -
 5 files changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index f9bcf7a..dd94300 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1207,7 +1207,6 @@ static int cpmac_remove(struct platform_device *pdev)
 static struct platform_driver cpmac_driver = {
 	.driver = {
 		.name 	= "cpmac",
-		.owner 	= THIS_MODULE,
 	},
 	.probe 	= cpmac_probe,
 	.remove = cpmac_remove,
diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index aa8bf45..0ea7832 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -211,7 +211,6 @@ static struct platform_driver cpsw_phy_sel_driver = {
 	.probe		= cpsw_phy_sel_probe,
 	.driver		= {
 		.name	= "cpsw-phy-sel",
-		.owner	= THIS_MODULE,
 		.of_match_table = cpsw_phy_sel_id_table,
 	},
 };
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 03b4099..6d20e24 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2359,7 +2359,6 @@ MODULE_DEVICE_TABLE(of, cpsw_of_mtable);
 static struct platform_driver cpsw_driver = {
 	.driver = {
 		.name	 = "cpsw",
-		.owner	 = THIS_MODULE,
 		.pm	 = &cpsw_pm_ops,
 		.of_match_table = cpsw_of_mtable,
 	},
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 35a139e..ea71251 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2083,7 +2083,6 @@ MODULE_DEVICE_TABLE(of, davinci_emac_of_match);
 static struct platform_driver davinci_emac_driver = {
 	.driver = {
 		.name	 = "davinci_emac",
-		.owner	 = THIS_MODULE,
 		.pm	 = &davinci_emac_pm_ops,
 		.of_match_table = of_match_ptr(davinci_emac_of_match),
 	},
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 2791f6f..98655b4 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -481,7 +481,6 @@ MODULE_DEVICE_TABLE(of, davinci_mdio_of_mtable);
 static struct platform_driver davinci_mdio_driver = {
 	.driver = {
 		.name	 = "davinci_mdio",
-		.owner	 = THIS_MODULE,
 		.pm	 = &davinci_mdio_pm_ops,
 		.of_match_table = of_match_ptr(davinci_mdio_of_mtable),
 	},
-- 
1.7.9.5
