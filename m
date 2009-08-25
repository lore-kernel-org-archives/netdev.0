From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/12] tg3: Add 57788, remove 57720
Date: Tue, 25 Aug 2009 13:08:42 -0700
Message-ID: <1251232429.25407@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1683 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756167AbZHYUgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:36:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the 57788 and removes support for the 57720
which was never released.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    5 ++++-
 drivers/net/tg3.h |    2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 356b5d0..9ae3320 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -223,7 +223,7 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57780)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57760)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57790)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57720)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57788)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -11525,6 +11525,9 @@ out_not_found:
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
 		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790)
 		strcpy(tp->board_part_number, "BCM57790");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57788)
+		strcpy(tp->board_part_number, "BCM57788");
 	else
 		strcpy(tp->board_part_number, "none");
 }
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index bb8591e..636008c 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -43,7 +43,7 @@
 #define  TG3PCI_DEVICE_TIGON3_57780	 0x1692
 #define  TG3PCI_DEVICE_TIGON3_57760	 0x1690
 #define  TG3PCI_DEVICE_TIGON3_57790	 0x1694
-#define  TG3PCI_DEVICE_TIGON3_57720	 0x168c
+#define  TG3PCI_DEVICE_TIGON3_57788	 0x1691
 /* 0x04 --> 0x64 unused */
 #define TG3PCI_MSI_DATA			0x00000064
 /* 0x66 --> 0x68 unused */
-- 
1.6.3.3


