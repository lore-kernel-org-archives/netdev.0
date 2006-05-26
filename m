From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 1/3] tg3: Add 5786 PCI ID
Date: Fri, 26 May 2006 15:55:23 -0700
Message-ID: <1148684123.3930.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:20996 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751744AbWE0Ame
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 20:42:34 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add PCI ID for BCM5786 which is a variant of 5787.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 49ad60b..3de5a62 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -229,6 +229,8 @@ static struct pci_device_id tg3_pci_tbl[
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5755M,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5786,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787M,
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index d6fe048..bef7ea1 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1886,6 +1886,7 @@
 #define PCI_DEVICE_ID_TIGON3_5751F	0x167e
 #define PCI_DEVICE_ID_TIGON3_5787M	0x1693
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696
+#define PCI_DEVICE_ID_TIGON3_5786	0x169a
 #define PCI_DEVICE_ID_TIGON3_5787	0x169b
 #define PCI_DEVICE_ID_TIGON3_5788	0x169c
 #define PCI_DEVICE_ID_TIGON3_5789	0x169d


