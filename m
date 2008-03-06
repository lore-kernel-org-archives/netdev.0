From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] ioc3.c: replace remaining __FUNCTION__ occurrences
Date: Thu, 6 Mar 2008 15:55:09 +0000
Message-ID: <20080306155509.GA16365@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harvey Harrison <harvey.harrison@gmail.com>
To: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:47041 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933400AbYCFPzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 10:55:18 -0500
Received: from localhost.localdomain ([127.0.0.1]:48827 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S28603680AbYCFPzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 15:55:16 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

__FUNCTION__ is gcc-specific, use __func__

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/sn/ioc3.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/sn/ioc3.c b/drivers/sn/ioc3.c
index 29fcd6d..c083274 100644
--- a/drivers/sn/ioc3.c
+++ b/drivers/sn/ioc3.c
@@ -561,7 +561,7 @@ void ioc3_unregister_submodule(struct ioc3_submodule *is)
 					printk(KERN_WARNING
 					       "%s: IOC3 submodule %s remove failed "
 					       "for pci_dev %s.\n",
-					       __FUNCTION__, module_name(is->owner),
+					       __func__, module_name(is->owner),
 					       pci_name(idd->pdev));
 			idd->active[is->id] = 0;
 			if(is->irq_mask)
@@ -611,7 +611,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 	if ((ret = pci_enable_device(pdev))) {
 		printk(KERN_WARNING
 		       "%s: Failed to enable IOC3 device for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		goto out;
 	}
 	pci_set_master(pdev);
@@ -623,7 +623,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
                 if (ret < 0) {
                         printk(KERN_WARNING "%s: Unable to obtain 64 bit DMA "
                                "for consistent allocations\n",
-				__FUNCTION__);
+				__func__);
                 }
 	}
 #endif
@@ -633,7 +633,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 	if (!idd) {
 		printk(KERN_WARNING
 		       "%s: Failed to allocate IOC3 data for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_idd;
 	}
@@ -649,7 +649,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		printk(KERN_WARNING
 		       "%s: Unable to find IOC3 resource "
 		       "for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_pci;
 	}
@@ -657,7 +657,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		printk(KERN_WARNING
 		       "%s: Unable to request IOC3 region "
 		       "for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_pci;
 	}
@@ -666,7 +666,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		printk(KERN_WARNING
 		       "%s: Unable to remap IOC3 region "
 		       "for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_misc_region;
 	}
@@ -709,7 +709,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		} else {
 			printk(KERN_WARNING
 			       "%s : request_irq fails for IRQ 0x%x\n ",
-			       __FUNCTION__, pdev->irq);
+			       __func__, pdev->irq);
 		}
 		if (!request_irq(pdev->irq+2, ioc3_intr_io, IRQF_SHARED,
 				 "ioc3-io", (void *)idd)) {
@@ -717,7 +717,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		} else {
 			printk(KERN_WARNING
 			       "%s : request_irq fails for IRQ 0x%x\n ",
-			       __FUNCTION__, pdev->irq+2);
+			       __func__, pdev->irq+2);
 		}
 	} else {
 		if (!request_irq(pdev->irq, ioc3_intr_io, IRQF_SHARED,
@@ -726,7 +726,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		} else {
 			printk(KERN_WARNING
 			       "%s : request_irq fails for IRQ 0x%x\n ",
-			       __FUNCTION__, pdev->irq);
+			       __func__, pdev->irq);
 		}
 	}
 
@@ -769,7 +769,7 @@ static void ioc3_remove(struct pci_dev *pdev)
 					printk(KERN_WARNING
 					       "%s: IOC3 submodule 0x%s remove failed "
 					       "for pci_dev %s.\n",
-					        __FUNCTION__,
+						__func__,
 						module_name(ioc3_submodules[id]->owner),
 					        pci_name(pdev));
 			idd->active[id] = 0;
