From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/12] tg3: Add more partno entries for
 fallback path
Date: Wed, 17 Feb 2010 17:16:58 -0800
Message-ID: <1266455825-16150-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3081 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754880Ab0BRBRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds 57765 asic partno entries for the path executed if VPD
is not present in NVRAM.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 11ee44b..c9974a7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12659,8 +12659,24 @@ out_not_found:
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
 		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57788)
 		strcpy(tp->board_part_number, "BCM57788");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57761)
+		strcpy(tp->board_part_number, "BCM57761");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57765)
 		strcpy(tp->board_part_number, "BCM57765");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57781)
+		strcpy(tp->board_part_number, "BCM57781");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57785)
+		strcpy(tp->board_part_number, "BCM57785");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57791)
+		strcpy(tp->board_part_number, "BCM57791");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57795)
+		strcpy(tp->board_part_number, "BCM57795");
 	else
 		strcpy(tp->board_part_number, "none");
 }
-- 
1.6.4.4


