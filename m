From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 083/493] irda: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:32 -0500
Message-ID: <1353349642-3677-83-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41669 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515Ab2KSSiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:06 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Samuel Ortiz <samuel@sortiz.org> 
Cc: netdev@vger.kernel.org 
---
 drivers/net/irda/au1k_ir.c  | 2 +-
 drivers/net/irda/bfin_sir.c | 2 +-
 drivers/net/irda/sh_irda.c  | 2 +-
 drivers/net/irda/sh_sir.c   | 2 +-
 drivers/net/irda/via-ircc.c | 2 +-
 drivers/net/irda/vlsi_ir.c  | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index e09417d..51bbc14 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -949,7 +949,7 @@ static struct platform_driver au1k_irda_driver = {
 		.owner	= THIS_MODULE,
 	},
 	.probe		= au1k_irda_probe,
-	.remove		= __devexit_p(au1k_irda_remove),
+	.remove		= au1k_irda_remove,
 };
 
 static int __init au1k_irda_load(void)
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index c6a0299..a4d0dda 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -798,7 +798,7 @@ static int __devexit bfin_sir_remove(struct platform_device *pdev)
 
 static struct platform_driver bfin_ir_driver = {
 	.probe   = bfin_sir_probe,
-	.remove  = __devexit_p(bfin_sir_remove),
+	.remove  = bfin_sir_remove,
 	.suspend = bfin_sir_suspend,
 	.resume  = bfin_sir_resume,
 	.driver  = {
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 945360a..a99127d 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -862,7 +862,7 @@ static const struct dev_pm_ops sh_irda_pm_ops = {
 
 static struct platform_driver sh_irda_driver = {
 	.probe	= sh_irda_probe,
-	.remove	= __devexit_p(sh_irda_remove),
+	.remove	= sh_irda_remove,
 	.driver	= {
 		.name	= DRIVER_NAME,
 		.pm	= &sh_irda_pm_ops,
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 624ac19..1b31f16 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -803,7 +803,7 @@ static int __devexit sh_sir_remove(struct platform_device *pdev)
 
 static struct platform_driver sh_sir_driver = {
 	.probe   = sh_sir_probe,
-	.remove  = __devexit_p(sh_sir_remove),
+	.remove  = sh_sir_remove,
 	.driver  = {
 		.name = DRIVER_NAME,
 	},
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 1a89fd4..1b5e27a 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -132,7 +132,7 @@ static struct pci_driver via_driver = {
 	.name		= VIA_MODULE_NAME,
 	.id_table	= via_pci_tbl,
 	.probe		= via_init_one,
-	.remove		= __devexit_p(via_remove_one),
+	.remove		= via_remove_one,
 };
 
 
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 9021d01..931ef88 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1832,7 +1832,7 @@ static struct pci_driver vlsi_irda_driver = {
 	.name		= drivername,
 	.id_table	= vlsi_irda_table,
 	.probe		= vlsi_irda_probe,
-	.remove		= __devexit_p(vlsi_irda_remove),
+	.remove		= vlsi_irda_remove,
 #ifdef CONFIG_PM
 	.suspend	= vlsi_irda_suspend,
 	.resume		= vlsi_irda_resume,
-- 
1.8.0
