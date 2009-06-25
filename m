From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/19] drivers/atm: Use PCI_VDEVICE
Date: Wed, 24 Jun 2009 22:13:18 -0700
Message-ID: <5b7c60739ce4077bf33eac0b3977c77c1dfa6278.1245906152.git.joe@perches.com>
References: <cover.1245906151.git.joe@perches.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1435 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724AbZFYFNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 01:13:38 -0400
In-Reply-To: <cover.1245906151.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/atm/ambassador.c |    6 ++----
 drivers/atm/eni.c        |    6 ++----
 drivers/atm/firestream.c |    6 ++----
 drivers/atm/fore200e.c   |    3 +--
 drivers/atm/he.c         |    3 +--
 drivers/atm/horizon.c    |    3 +--
 drivers/atm/idt77252.c   |    3 +--
 drivers/atm/nicstar.c    |    3 +--
 drivers/atm/solos-pci.c  |    2 +-
 drivers/atm/zatm.c       |    6 ++----
 10 files changed, 14 insertions(+), 27 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 703364b..cae8b04 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2377,10 +2377,8 @@ MODULE_PARM_DESC(pci_lat, "PCI latency in bus cycles");
 /********** module entry **********/
 
 static struct pci_device_id amb_pci_tbl[] = {
-	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 },
-	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 },
+	{ PCI_VDEVICE(MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR), 0 },
+	{ PCI_VDEVICE(MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD), 0 },
 	{ 0, }
 };
 
diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 5503bfc..b1d7acd 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2268,10 +2268,8 @@ out0:
 
 
 static struct pci_device_id eni_pci_tbl[] = {
-	{ PCI_VENDOR_ID_EF, PCI_DEVICE_ID_EF_ATM_FPGA, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 /* FPGA */ },
-	{ PCI_VENDOR_ID_EF, PCI_DEVICE_ID_EF_ATM_ASIC, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 1 /* ASIC */ },
+	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_FPGA), 0 /* FPGA */ },
+	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_ASIC), 1 /* ASIC */ },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci,eni_pci_tbl);
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index b119640..8cb3088 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -2026,10 +2026,8 @@ static void __devexit firestream_remove_one (struct pci_dev *pdev)
 }
 
 static struct pci_device_id firestream_pci_tbl[] = {
-	{ PCI_VENDOR_ID_FUJITSU_ME, PCI_DEVICE_ID_FUJITSU_FS50, 
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, FS_IS50},
-	{ PCI_VENDOR_ID_FUJITSU_ME, PCI_DEVICE_ID_FUJITSU_FS155, 
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, FS_IS155},
+	{ PCI_VDEVICE(FUJITSU_ME, PCI_DEVICE_ID_FUJITSU_FS50), FS_IS50},
+	{ PCI_VDEVICE(FUJITSU_ME, PCI_DEVICE_ID_FUJITSU_FS155), FS_IS155},
 	{ 0, }
 };
 
diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 10f000d..1241b08 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2770,8 +2770,7 @@ static void __devexit fore200e_pca_remove_one(struct pci_dev *pci_dev)
 
 
 static struct pci_device_id fore200e_pca_tbl[] = {
-    { PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_PCA200E, PCI_ANY_ID, PCI_ANY_ID,
-      0, 0, (unsigned long) &fore200e_bus[0] },
+    { PCI_VDEVICE(FORE, PCI_DEVICE_ID_FORE_PCA200E), (unsigned long) &fore200e_bus[0] },
     { 0, }
 };
 
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 2de6406..a536a53 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2921,8 +2921,7 @@ module_param(sdh, bool, 0);
 MODULE_PARM_DESC(sdh, "use SDH framing (default 0)");
 
 static struct pci_device_id he_pci_tbl[] = {
-	{ PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_HE, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 },
+	{ PCI_VDEVICE(FORE, PCI_DEVICE_ID_FORE_HE), 0 },
 	{ 0, }
 };
 
diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 6b969f8..cec9a66 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2896,8 +2896,7 @@ MODULE_PARM_DESC(max_rx_size, "maximum size of RX AAL5 frames");
 MODULE_PARM_DESC(pci_lat, "PCI latency in bus cycles");
 
 static struct pci_device_id hrz_pci_tbl[] = {
-	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_HORIZON, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 },
+	{ PCI_VDEVICE(MADGE, PCI_DEVICE_ID_MADGE_HORIZON), 0 },
 	{ 0, }
 };
 
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index e33ae00..351b9b0 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3781,8 +3781,7 @@ err_out_disable_pdev:
 
 static struct pci_device_id idt77252_pci_tbl[] =
 {
-	{ PCI_VENDOR_ID_IDT, PCI_DEVICE_ID_IDT_IDT77252,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VDEVICE(IDT, PCI_DEVICE_ID_IDT_IDT77252), 0 },
 	{ 0, }
 };
 
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 3da804b..8ddacf8 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -277,8 +277,7 @@ static void __devexit nicstar_remove_one(struct pci_dev *pcidev)
 
 static struct pci_device_id nicstar_pci_tbl[] __devinitdata =
 {
-	{PCI_VENDOR_ID_IDT, PCI_DEVICE_ID_IDT_IDT77201,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{PCI_VDEVICE(IDT, PCI_DEVICE_ID_IDT_IDT77201), 0},
 	{0,}			/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, nicstar_pci_tbl);
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 9359613..376c120 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1265,7 +1265,7 @@ static void fpga_remove(struct pci_dev *dev)
 }
 
 static struct pci_device_id fpga_pci_tbl[] __devinitdata = {
-	{ 0x10ee, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VDEVICE(XILINX, 0x0300), 0 },
 	{ 0, }
 };
 
diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 752b1ba..d33d6b6 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1636,10 +1636,8 @@ out_free:
 MODULE_LICENSE("GPL");
 
 static struct pci_device_id zatm_pci_tbl[] __devinitdata = {
-	{ PCI_VENDOR_ID_ZEITNET, PCI_DEVICE_ID_ZEITNET_1221,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, ZATM_COPPER },
-	{ PCI_VENDOR_ID_ZEITNET, PCI_DEVICE_ID_ZEITNET_1225,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VDEVICE(ZEITNET, PCI_DEVICE_ID_ZEITNET_1221), ZATM_COPPER },
+	{ PCI_VDEVICE(ZEITNET, PCI_DEVICE_ID_ZEITNET_1225), 0 },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, zatm_pci_tbl);
-- 
1.6.3.1.10.g659a0.dirty

