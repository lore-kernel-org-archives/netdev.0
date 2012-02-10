From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] e1000e: replace '1' with 'true' for boolean get_link_status
Date: Fri, 10 Feb 2012 00:08:56 -0800
Message-ID: <1328861337-12810-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3668 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757927Ab2BJIJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 03:09:03 -0500
In-Reply-To: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    6 +++---
 drivers/net/ethernet/intel/e1000e/phy.c    |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7ccd5f3..f868fb8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1652,7 +1652,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 	 */
 
 	if (icr & E1000_ICR_LSC) {
-		hw->mac.get_link_status = 1;
+		hw->mac.get_link_status = true;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on cable
 		 * disconnect (LSC) before accessing any PHY registers
@@ -1718,7 +1718,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	 */
 
 	if (icr & E1000_ICR_LSC) {
-		hw->mac.get_link_status = 1;
+		hw->mac.get_link_status = true;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on cable
 		 * disconnect (LSC) before accessing any PHY registers
@@ -1775,7 +1775,7 @@ static irqreturn_t e1000_msix_other(int irq, void *data)
 	if (icr & E1000_ICR_OTHER) {
 		if (!(icr & E1000_ICR_LSC))
 			goto no_link_interrupt;
-		hw->mac.get_link_status = 1;
+		hw->mac.get_link_status = true;
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index e8ad080..6f44c3f 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1141,7 +1141,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 		}
 	}
 
-	hw->mac.get_link_status = 1;
+	hw->mac.get_link_status = true;
 
 	return ret_val;
 }
-- 
1.7.7.6
