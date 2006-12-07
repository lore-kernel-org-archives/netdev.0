From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/7][TG3]: Add 5787F device ID.
Date: Wed, 06 Dec 2006 23:46:25 -0800
Message-ID: <1165477585.8488.28.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2162 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031738AbWLGG4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:56:17 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add 5787F device ID.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 819758e..bfa7e3e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -192,6 +192,7 @@ static struct pci_device_id tg3_pci_tbl[
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5786)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787M)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787F)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5714)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5714S)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5715)},
@@ -10859,7 +10860,8 @@ static int __devinit tg3_get_invariants(
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5705F)) ||
 	    (tp->pdev->vendor == PCI_VENDOR_ID_BROADCOM &&
 	     (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5751F ||
-	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F)) ||
+	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F ||
+	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5787F)) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->tg3_flags |= TG3_FLAG_10_100_ONLY;
 
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 6294559..55710b7 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1927,6 +1927,7 @@
 #define PCI_DEVICE_ID_TIGON3_5750M	0x167c
 #define PCI_DEVICE_ID_TIGON3_5751M	0x167d
 #define PCI_DEVICE_ID_TIGON3_5751F	0x167e
+#define PCI_DEVICE_ID_TIGON3_5787F	0x167f
 #define PCI_DEVICE_ID_TIGON3_5787M	0x1693
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696
 #define PCI_DEVICE_ID_TIGON3_5786	0x169a


