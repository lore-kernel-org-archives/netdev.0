From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/5 net-next] tg3: Add EEE support for 5717 B0
Date: Thu, 14 Feb 2013 14:13:39 -0800
Message-ID: <1360880022-12856-2-git-send-email-mchan@broadcom.com>
References: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4441 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934964Ab3BNV4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 16:56:31 -0500
In-Reply-To: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chip supports Energy Efficient Ethernet.

Signed-off-by: Michael Chan <mchan@broadocm.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6e676a7..3004d69 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14514,7 +14514,7 @@ static int tg3_phy_probe(struct tg3 *tp)
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5762 ||
-	     (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 &&
+	     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
 	      tp->pci_chip_rev_id != CHIPREV_ID_5717_A0) ||
 	     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
 	      tp->pci_chip_rev_id != CHIPREV_ID_57765_A0)))
-- 
1.7.1
