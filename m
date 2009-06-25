From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/19] drivers/net/wan: Use PCI_VDEVICE
Date: Wed, 24 Jun 2009 22:13:26 -0700
Message-ID: <f333b1dcffc974f1df83e8d005f61a710604b8b6.1245906152.git.joe@perches.com>
References: <cover.1245906151.git.joe@perches.com>
Cc: Kevin Curtis <kevin.curtis@farsite.co.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1451 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbZFYFNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 01:13:49 -0400
In-Reply-To: <cover.1245906151.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/farsync.c   |   21 +++++++--------------
 drivers/net/wan/pc300_drv.c |   12 ++++++------
 drivers/net/wan/pc300too.c  |   12 ++++--------
 drivers/net/wan/wanxl.c     |    9 +++------
 4 files changed, 20 insertions(+), 34 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 25c9ef6..8e9272a 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -528,26 +528,19 @@ static int fst_debug_mask = { FST_DEBUG };
  *      PCI ID lookup table
  */
 static struct pci_device_id fst_pci_dev_id[] __devinitdata = {
-	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2P, PCI_ANY_ID, 
-	 PCI_ANY_ID, 0, 0, FST_TYPE_T2P},
+	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T2P), FST_TYPE_T2P},
 
-	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4P, PCI_ANY_ID, 
-	 PCI_ANY_ID, 0, 0, FST_TYPE_T4P},
+	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T4P), FST_TYPE_T4P},
 
-	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T1U, PCI_ANY_ID, 
-	 PCI_ANY_ID, 0, 0, FST_TYPE_T1U},
+	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T1U), FST_TYPE_T1U},
 
-	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2U, PCI_ANY_ID, 
-	 PCI_ANY_ID, 0, 0, FST_TYPE_T2U},
+	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T2U), FST_TYPE_T2U},
 
-	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4U, PCI_ANY_ID, 
-	 PCI_ANY_ID, 0, 0, FST_TYPE_T4U},
+	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T4U), FST_TYPE_T4U},
 
-	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1, PCI_ANY_ID, 
-	 PCI_ANY_ID, 0, 0, FST_TYPE_TE1},
+	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_TE1), FST_TYPE_TE1},
 
-	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1C, PCI_ANY_ID, 
-	 PCI_ANY_ID, 0, 0, FST_TYPE_TE1},
+	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_TE1C), FST_TYPE_TE1},
 	{0,}			/* End */
 };
 
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 79dabc5..d035e8b 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -253,17 +253,17 @@ static char rcsid[] =
 
 static struct pci_device_id cpc_pci_dev_id[] __devinitdata = {
 	/* PC300/RSV or PC300/X21, 2 chan */
-	{0x120e, 0x300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x300},
+	{PCI_VDEVICE(CYCLADES, 0x300), 0x300},
 	/* PC300/RSV or PC300/X21, 1 chan */
-	{0x120e, 0x301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x301},
+	{PCI_VDEVICE(CYCLADES, 0x301), 0x301},
 	/* PC300/TE, 2 chan */
-	{0x120e, 0x310, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x310},
+	{PCI_VDEVICE(CYCLADES, 0x310), 0x310},
 	/* PC300/TE, 1 chan */
-	{0x120e, 0x311, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x311},
+	{PCI_VDEVICE(CYCLADES, 0x311), 0x311},
 	/* PC300/TE-M, 2 chan */
-	{0x120e, 0x320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x320},
+	{PCI_VDEVICE(CYCLADES, 0x320), 0x320},
 	/* PC300/TE-M, 1 chan */
-	{0x120e, 0x321, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x321},
+	{PCI_VDEVICE(CYCLADES, 0x321), 0x321},
 	/* End of table */
 	{0,},
 };
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index 60ece54..c57f168 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -482,14 +482,10 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 
 
 static struct pci_device_id pc300_pci_tbl[] __devinitdata = {
-	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_RX_1, PCI_ANY_ID,
-	  PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_RX_2, PCI_ANY_ID,
-	  PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_TE_1, PCI_ANY_ID,
-	  PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_TE_2, PCI_ANY_ID,
-	  PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VDEVICE(CYCLADES, PCI_DEVICE_ID_PC300_RX_1), 0 },
+	{ PCI_VDEVICE(CYCLADES, PCI_DEVICE_ID_PC300_RX_2), 0 },
+	{ PCI_VDEVICE(CYCLADES, PCI_DEVICE_ID_PC300_TE_1), 0 },
+	{ PCI_VDEVICE(CYCLADES, PCI_DEVICE_ID_PC300_TE_2), 0 },
 	{ 0, }
 };
 
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index e4ad7b6..3bde117 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -815,12 +815,9 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 }
 
 static struct pci_device_id wanxl_pci_tbl[] __devinitdata = {
-	{ PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_SBE_WANXL100, PCI_ANY_ID,
-	  PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_SBE_WANXL200, PCI_ANY_ID,
-	  PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_SBE_WANXL400, PCI_ANY_ID,
-	  PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VDEVICE(SBE, PCI_DEVICE_ID_SBE_WANXL100), 0 },
+	{ PCI_VDEVICE(SBE, PCI_DEVICE_ID_SBE_WANXL200), 0 },
+	{ PCI_VDEVICE(SBE, PCI_DEVICE_ID_SBE_WANXL400), 0 },
 	{ 0, }
 };
 
-- 
1.6.3.1.10.g659a0.dirty

