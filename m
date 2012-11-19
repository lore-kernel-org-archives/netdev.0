From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 079/493] can: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:28 -0500
Message-ID: <1353349642-3677-79-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41653 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab2KSSiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:06 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com> 
Cc: Marc Kleine-Budde <mkl@pengutronix.de> 
Cc: linux-can@vger.kernel.org 
Cc: netdev@vger.kernel.org 
---
 drivers/net/can/at91_can.c                    | 2 +-
 drivers/net/can/bfin_can.c                    | 2 +-
 drivers/net/can/c_can/c_can_pci.c             | 2 +-
 drivers/net/can/c_can/c_can_platform.c        | 2 +-
 drivers/net/can/cc770/cc770_isa.c             | 2 +-
 drivers/net/can/cc770/cc770_platform.c        | 2 +-
 drivers/net/can/flexcan.c                     | 2 +-
 drivers/net/can/janz-ican3.c                  | 2 +-
 drivers/net/can/mcp251x.c                     | 2 +-
 drivers/net/can/mscan/mpc5xxx_can.c           | 2 +-
 drivers/net/can/pch_can.c                     | 2 +-
 drivers/net/can/sja1000/kvaser_pci.c          | 2 +-
 drivers/net/can/sja1000/peak_pci.c            | 2 +-
 drivers/net/can/sja1000/sja1000_isa.c         | 2 +-
 drivers/net/can/sja1000/sja1000_of_platform.c | 2 +-
 drivers/net/can/sja1000/tscan1.c              | 2 +-
 drivers/net/can/softing/softing_cs.c          | 2 +-
 drivers/net/can/softing/softing_main.c        | 2 +-
 drivers/net/can/ti_hecc.c                     | 2 +-
 19 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 994b6ac..0f08305 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1374,7 +1374,7 @@ static const struct platform_device_id at91_can_id_table[] = {
 
 static struct platform_driver at91_can_driver = {
 	.probe = at91_can_probe,
-	.remove = __devexit_p(at91_can_remove),
+	.remove = at91_can_remove,
 	.driver = {
 		.name = KBUILD_MODNAME,
 		.owner = THIS_MODULE,
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index f2d6d25..ee4983a 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -677,7 +677,7 @@ static int bfin_can_resume(struct platform_device *pdev)
 
 static struct platform_driver bfin_can_driver = {
 	.probe = bfin_can_probe,
-	.remove = __devexit_p(bfin_can_remove),
+	.remove = bfin_can_remove,
 	.suspend = bfin_can_suspend,
 	.resume = bfin_can_resume,
 	.driver = {
diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index 3d7830b..019cf71 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -210,7 +210,7 @@ static struct pci_driver c_can_pci_driver = {
 	.name = KBUILD_MODNAME,
 	.id_table = c_can_pci_tbl,
 	.probe = c_can_pci_probe,
-	.remove = __devexit_p(c_can_pci_remove),
+	.remove = c_can_pci_remove,
 };
 
 module_pci_driver(c_can_pci_driver);
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index ee14161..fed1dd1 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -306,7 +306,7 @@ static struct platform_driver c_can_plat_driver = {
 		.of_match_table = of_match_ptr(c_can_of_table),
 	},
 	.probe = c_can_plat_probe,
-	.remove = __devexit_p(c_can_plat_remove),
+	.remove = c_can_plat_remove,
 	.suspend = c_can_suspend,
 	.resume = c_can_resume,
 	.id_table = c_can_id_table,
diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index 9f3a25c..dfa9a45 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -316,7 +316,7 @@ static int __devexit cc770_isa_remove(struct platform_device *pdev)
 
 static struct platform_driver cc770_isa_driver = {
 	.probe = cc770_isa_probe,
-	.remove = __devexit_p(cc770_isa_remove),
+	.remove = cc770_isa_remove,
 	.driver = {
 		.name = KBUILD_MODNAME,
 		.owner = THIS_MODULE,
diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index 688371c..a294926 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -266,7 +266,7 @@ static struct platform_driver cc770_platform_driver = {
 		.of_match_table = cc770_platform_table,
 	},
 	.probe = cc770_platform_probe,
-	.remove = __devexit_p(cc770_platform_remove),
+	.remove = cc770_platform_remove,
 };
 
 module_platform_driver(cc770_platform_driver);
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index a412bf6..01e0201 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1168,7 +1168,7 @@ static struct platform_driver flexcan_driver = {
 		.of_match_table = flexcan_of_match,
 	},
 	.probe = flexcan_probe,
-	.remove = __devexit_p(flexcan_remove),
+	.remove = flexcan_remove,
 	.suspend = flexcan_suspend,
 	.resume = flexcan_resume,
 	.id_table = flexcan_id_table,
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 7edadee..a9dfcb9 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1927,7 +1927,7 @@ static struct platform_driver ican3_driver = {
 		.owner	= THIS_MODULE,
 	},
 	.probe		= ican3_probe,
-	.remove		= __devexit_p(ican3_remove),
+	.remove		= ican3_remove,
 };
 
 module_platform_driver(ican3_driver);
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 26e7129..7a059d1 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -1198,7 +1198,7 @@ static struct spi_driver mcp251x_can_driver = {
 
 	.id_table = mcp251x_id_table,
 	.probe = mcp251x_can_probe,
-	.remove = __devexit_p(mcp251x_can_remove),
+	.remove = mcp251x_can_remove,
 	.suspend = mcp251x_can_suspend,
 	.resume = mcp251x_can_resume,
 };
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 799c354..db59bbc 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -404,7 +404,7 @@ static struct platform_driver mpc5xxx_can_driver = {
 		.of_match_table = mpc5xxx_can_table,
 	},
 	.probe = mpc5xxx_can_probe,
-	.remove = __devexit_p(mpc5xxx_can_remove),
+	.remove = mpc5xxx_can_remove,
 #ifdef CONFIG_PM
 	.suspend = mpc5xxx_can_suspend,
 	.resume = mpc5xxx_can_resume,
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 48b3d62..56145f9 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1269,7 +1269,7 @@ static struct pci_driver pch_can_pci_driver = {
 	.name = "pch_can",
 	.id_table = pch_pci_tbl,
 	.probe = pch_can_probe,
-	.remove = __devexit_p(pch_can_remove),
+	.remove = pch_can_remove,
 	.suspend = pch_can_suspend,
 	.resume = pch_can_resume,
 };
diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index 23ed6ea..be95c42 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -394,7 +394,7 @@ static struct pci_driver kvaser_pci_driver = {
 	.name = DRV_NAME,
 	.id_table = kvaser_pci_tbl,
 	.probe = kvaser_pci_init_one,
-	.remove = __devexit_p(kvaser_pci_remove_one),
+	.remove = kvaser_pci_remove_one,
 };
 
 module_pci_driver(kvaser_pci_driver);
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 6525dbc..0247efa 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -757,7 +757,7 @@ static struct pci_driver peak_pci_driver = {
 	.name = DRV_NAME,
 	.id_table = peak_pci_tbl,
 	.probe = peak_pci_probe,
-	.remove = __devexit_p(peak_pci_remove),
+	.remove = peak_pci_remove,
 };
 
 module_pci_driver(peak_pci_driver);
diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index 90c5c2d..f910102 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -248,7 +248,7 @@ static int __devexit sja1000_isa_remove(struct platform_device *pdev)
 
 static struct platform_driver sja1000_isa_driver = {
 	.probe = sja1000_isa_probe,
-	.remove = __devexit_p(sja1000_isa_remove),
+	.remove = sja1000_isa_remove,
 	.driver = {
 		.name = DRV_NAME,
 		.owner = THIS_MODULE,
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index f2683eb..a330fe8 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -217,7 +217,7 @@ static struct platform_driver sja1000_ofp_driver = {
 		.of_match_table = sja1000_ofp_table,
 	},
 	.probe = sja1000_ofp_probe,
-	.remove = __devexit_p(sja1000_ofp_remove),
+	.remove = sja1000_ofp_remove,
 };
 
 module_platform_driver(sja1000_ofp_driver);
diff --git a/drivers/net/can/sja1000/tscan1.c b/drivers/net/can/sja1000/tscan1.c
index 9756099..04a9001 100644
--- a/drivers/net/can/sja1000/tscan1.c
+++ b/drivers/net/can/sja1000/tscan1.c
@@ -197,7 +197,7 @@ static int __devexit tscan1_remove(struct device *dev, unsigned id /*unused*/)
 
 static struct isa_driver tscan1_isa_driver = {
 	.probe = tscan1_probe,
-	.remove = __devexit_p(tscan1_remove),
+	.remove = tscan1_remove,
 	.driver = {
 		.name = "tscan1",
 	},
diff --git a/drivers/net/can/softing/softing_cs.c b/drivers/net/can/softing/softing_cs.c
index c0e1b1e..ab132c5 100644
--- a/drivers/net/can/softing/softing_cs.c
+++ b/drivers/net/can/softing/softing_cs.c
@@ -338,7 +338,7 @@ static struct pcmcia_driver softingcs_driver = {
 	.name		= "softingcs",
 	.id_table	= softingcs_ids,
 	.probe		= softingcs_probe,
-	.remove		= __devexit_p(softingcs_remove),
+	.remove		= softingcs_remove,
 };
 
 static int __init softingcs_start(void)
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index f2a221e..6337581 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -871,7 +871,7 @@ static struct platform_driver softing_driver = {
 		.owner = THIS_MODULE,
 	},
 	.probe = softing_pdev_probe,
-	.remove = __devexit_p(softing_pdev_remove),
+	.remove = softing_pdev_remove,
 };
 
 module_platform_driver(softing_driver);
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 9ded21e..80ee814 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -1045,7 +1045,7 @@ static struct platform_driver ti_hecc_driver = {
 		.owner   = THIS_MODULE,
 	},
 	.probe = ti_hecc_probe,
-	.remove = __devexit_p(ti_hecc_remove),
+	.remove = ti_hecc_remove,
 	.suspend = ti_hecc_suspend,
 	.resume = ti_hecc_resume,
 };
-- 
1.8.0
