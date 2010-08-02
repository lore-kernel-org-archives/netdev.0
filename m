From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 08/14] tg3: Remove 5720, 5750, and 5750M
Date: Mon, 2 Aug 2010 14:26:02 -0700
Message-ID: <1280784368-4226-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3021 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755460Ab0HBV0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These devices were never released to the public.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c       |    3 ---
 include/linux/pci_ids.h |    3 ---
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a52f52f..32e3a3d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -221,12 +221,9 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901_2)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5704S_2)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705F)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5720)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5721)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5722)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5750)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5750M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751F)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5752)},
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index ae66851..9ac60da 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2053,7 +2053,6 @@
 #define PCI_DEVICE_ID_NX2_57711E	0x1650
 #define PCI_DEVICE_ID_TIGON3_5705	0x1653
 #define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
-#define PCI_DEVICE_ID_TIGON3_5720	0x1658
 #define PCI_DEVICE_ID_TIGON3_5721	0x1659
 #define PCI_DEVICE_ID_TIGON3_5722	0x165a
 #define PCI_DEVICE_ID_TIGON3_5723	0x165b
@@ -2067,13 +2066,11 @@
 #define PCI_DEVICE_ID_TIGON3_5754M	0x1672
 #define PCI_DEVICE_ID_TIGON3_5755M	0x1673
 #define PCI_DEVICE_ID_TIGON3_5756	0x1674
-#define PCI_DEVICE_ID_TIGON3_5750	0x1676
 #define PCI_DEVICE_ID_TIGON3_5751	0x1677
 #define PCI_DEVICE_ID_TIGON3_5715	0x1678
 #define PCI_DEVICE_ID_TIGON3_5715S	0x1679
 #define PCI_DEVICE_ID_TIGON3_5754	0x167a
 #define PCI_DEVICE_ID_TIGON3_5755	0x167b
-#define PCI_DEVICE_ID_TIGON3_5750M	0x167c
 #define PCI_DEVICE_ID_TIGON3_5751M	0x167d
 #define PCI_DEVICE_ID_TIGON3_5751F	0x167e
 #define PCI_DEVICE_ID_TIGON3_5787F	0x167f
-- 
1.7.1


