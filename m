From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: add pci ids
Date: Fri, 12 Sep 2008 06:55:14 -0700
Message-ID: <1221227714-8382-1-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:43239 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751521AbYILNzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 09:55:17 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define old and new pci vendor and device ids.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   18 +++++++++---------
 include/linux/pci_ids.h              |   10 ++++++++++
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 008fd66..0f8ea2c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -77,18 +77,18 @@ static irqreturn_t netxen_msi_intr(int irq, void *data);
 
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
-	{PCI_DEVICE(0x4040, (device)), \
+	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
 static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
-	ENTRY(0x0001),
-	ENTRY(0x0002),
-	ENTRY(0x0003),
-	ENTRY(0x0004),
-	ENTRY(0x0005),
-	ENTRY(0x0024),
-	ENTRY(0x0025),
-	ENTRY(0x0100),
+	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
+	ENTRY(PCI_DEVICE_ID_NX2031_10GCX4),
+	ENTRY(PCI_DEVICE_ID_NX2031_4GCU),
+	ENTRY(PCI_DEVICE_ID_NX2031_IMEZ),
+	ENTRY(PCI_DEVICE_ID_NX2031_HMEZ),
+	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT),
+	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT2),
+	ENTRY(PCI_DEVICE_ID_NX3031),
 	{0,}
 };
 
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index f1624b3..97dfb11 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2244,6 +2244,16 @@
 #define PCI_DEVICE_ID_3DLABS_PERMEDIA2	0x0007
 #define PCI_DEVICE_ID_3DLABS_PERMEDIA2V	0x0009
 
+#define PCI_VENDOR_ID_NETXEN		0x4040
+#define PCI_DEVICE_ID_NX2031_10GXSR	0x0001
+#define PCI_DEVICE_ID_NX2031_10GCX4	0x0002
+#define PCI_DEVICE_ID_NX2031_4GCU	0x0003
+#define PCI_DEVICE_ID_NX2031_IMEZ	0x0004
+#define PCI_DEVICE_ID_NX2031_HMEZ	0x0005
+#define PCI_DEVICE_ID_NX2031_XG_MGMT	0x0024
+#define PCI_DEVICE_ID_NX2031_XG_MGMT2	0x0025
+#define PCI_DEVICE_ID_NX3031		0x0100
+
 #define PCI_VENDOR_ID_AKS		0x416c
 #define PCI_DEVICE_ID_AKS_ALADDINCARD	0x0100
 
-- 
1.5.4.3

