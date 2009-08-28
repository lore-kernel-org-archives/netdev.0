From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 02/17] tg3: Add new 5785 10/100 only device ID
Date: Fri, 28 Aug 2009 15:28:45 -0700
Message-ID: <1251585278.29666@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2439 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbZH2Wem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new device ID for those 5785 devices that will only
use 10/100 phys.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c       |    3 ++-
 drivers/net/tg3.h       |    2 ++
 include/linux/pci_ids.h |    1 -
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ab3159e..d43b30b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -219,7 +219,8 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761E)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5761S)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5761SE)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5785)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5785_G)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5785_F)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57780)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57760)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57790)},
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 60b12ab..1c9495d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -44,6 +44,8 @@
 #define  TG3PCI_DEVICE_TIGON3_57760	 0x1690
 #define  TG3PCI_DEVICE_TIGON3_57790	 0x1694
 #define  TG3PCI_DEVICE_TIGON3_57788	 0x1691
+#define  TG3PCI_DEVICE_TIGON3_5785_G	 0x1699 /* GPHY */
+#define  TG3PCI_DEVICE_TIGON3_5785_F	 0x16a0 /* 10/100 only */
 /* 0x04 --> 0x64 unused */
 #define TG3PCI_MSI_DATA			0x00000064
 /* 0x66 --> 0x68 unused */
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index fdc3110..8549254 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2064,7 +2064,6 @@
 #define PCI_DEVICE_ID_TIGON3_5787M	0x1693
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696
 #define PCI_DEVICE_ID_TIGON3_5784	0x1698
-#define PCI_DEVICE_ID_TIGON3_5785	0x1699
 #define PCI_DEVICE_ID_TIGON3_5786	0x169a
 #define PCI_DEVICE_ID_TIGON3_5787	0x169b
 #define PCI_DEVICE_ID_TIGON3_5788	0x169c
-- 
1.6.3.3


