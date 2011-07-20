From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/8] tg3: Add 5719 and 5720 to EEE_CAP list
Date: Wed, 20 Jul 2011 13:20:53 -0700
Message-ID: <1311193257-20531-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3700 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545Ab1GTUTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 16:19:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 5719 and the 5720 to the list of devices that are
EEE capable.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e0413bc..5110ea0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13142,7 +13142,9 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	}
 
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
-	    ((tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 &&
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720 ||
+	     (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 &&
 	      tp->pci_chip_rev_id != CHIPREV_ID_5717_A0) ||
 	     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
 	      tp->pci_chip_rev_id != CHIPREV_ID_57765_A0)))
-- 
1.7.3.4


