From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 389/493] atm: remove use of __devexit
Date: Mon, 19 Nov 2012 13:25:38 -0500
Message-ID: <1353349642-3677-389-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41487 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243Ab2KSSev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:51 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil> 
Cc: linux-atm-general@lists.sourceforge.net 
Cc: netdev@vger.kernel.org 
---
 drivers/atm/ambassador.c | 2 +-
 drivers/atm/eni.c        | 2 +-
 drivers/atm/firestream.c | 6 +++---
 drivers/atm/fore200e.c   | 4 ++--
 drivers/atm/he.c         | 2 +-
 drivers/atm/horizon.c    | 2 +-
 drivers/atm/iphase.c     | 2 +-
 drivers/atm/nicstar.c    | 2 +-
 8 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index eb8d486..6d69032 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2284,7 +2284,7 @@ out_disable:
 }
 
 
-static void __devexit amb_remove_one(struct pci_dev *pci_dev)
+static void amb_remove_one(struct pci_dev *pci_dev)
 {
 	struct amb_dev *dev;
 
diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 1f1aa57..9d062d5 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2292,7 +2292,7 @@ static struct pci_device_id eni_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci,eni_pci_tbl);
 
 
-static void __devexit eni_remove_one(struct pci_dev *pdev)
+static void eni_remove_one(struct pci_dev *pdev)
 {
 	struct atm_dev *dev = pci_get_drvdata(pdev);
 	struct eni_dev *ed = ENI_DEV(dev);
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index c8c81e4..d5967f9 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1528,7 +1528,7 @@ static void top_off_fp (struct fs_dev *dev, struct freepool *fp,
 	fs_dprintk (FS_DEBUG_QUEUE, "Added %d entries. \n", n);
 }
 
-static void __devexit free_queue (struct fs_dev *dev, struct queue *txq)
+static void free_queue (struct fs_dev *dev, struct queue *txq)
 {
 	func_enter ();
 
@@ -1544,7 +1544,7 @@ static void __devexit free_queue (struct fs_dev *dev, struct queue *txq)
 	func_exit ();
 }
 
-static void __devexit free_freepool (struct fs_dev *dev, struct freepool *fp)
+static void free_freepool (struct fs_dev *dev, struct freepool *fp)
 {
 	func_enter ();
 
@@ -1934,7 +1934,7 @@ static int firestream_init_one (struct pci_dev *pci_dev,
 	return -ENODEV;
 }
 
-static void __devexit firestream_remove_one (struct pci_dev *pdev)
+static void firestream_remove_one (struct pci_dev *pdev)
 {
 	int i;
 	struct fs_dev *dev, *nxtdev;
diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 4b34891..e356284 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2681,7 +2681,7 @@ static int fore200e_sba_probe(struct platform_device *op)
 	return 0;
 }
 
-static int __devexit fore200e_sba_remove(struct platform_device *op)
+static int fore200e_sba_remove(struct platform_device *op)
 {
 	struct fore200e *fore200e = dev_get_drvdata(&op->dev);
 
@@ -2766,7 +2766,7 @@ out_disable:
 }
 
 
-static void __devexit fore200e_pca_remove_one(struct pci_dev *pci_dev)
+static void fore200e_pca_remove_one(struct pci_dev *pci_dev)
 {
     struct fore200e *fore200e;
 
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index dac5144..a7e18f8 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -406,7 +406,7 @@ init_one_failure:
 	return err;
 }
 
-static void __devexit
+static void
 he_remove_one (struct pci_dev *pci_dev)
 {
 	struct atm_dev *atm_dev;
diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 67b570a..ca81449 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2836,7 +2836,7 @@ out_disable:
 	goto out;
 }
 
-static void __devexit hrz_remove_one(struct pci_dev *pci_dev)
+static void hrz_remove_one(struct pci_dev *pci_dev)
 {
 	hrz_dev *dev;
 
diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 444e81e..5036908 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3229,7 +3229,7 @@ err_out:
 	return ret;
 }
 
-static void __devexit ia_remove_one(struct pci_dev *pdev)
+static void ia_remove_one(struct pci_dev *pdev)
 {
 	struct atm_dev *dev = pci_get_drvdata(pdev);
 	IADEV *iadev = INPH_IA_DEV(dev);
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index bc9adf2..7e6063c 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -200,7 +200,7 @@ err_out:
 	return -ENODEV;
 }
 
-static void __devexit nicstar_remove_one(struct pci_dev *pcidev)
+static void nicstar_remove_one(struct pci_dev *pcidev)
 {
 	int i, j;
 	ns_dev *card = pci_get_drvdata(pcidev);
-- 
1.8.0
