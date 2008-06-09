From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/2] ixgbe: fix typo
Date: Mon, 09 Jun 2008 15:57:17 -0700
Message-ID: <20080609225658.1219.89600.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54520 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052AbYFIW53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 18:57:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define names were accidently transposed.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 6321b05..2f38e84 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -58,8 +58,8 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw);
 
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 {
-	hw->mac.num_rx_queues = IXGBE_82598_MAX_TX_QUEUES;
-	hw->mac.num_tx_queues = IXGBE_82598_MAX_RX_QUEUES;
+	hw->mac.num_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
+	hw->mac.num_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
 	hw->mac.num_rx_addrs = IXGBE_82598_RAR_ENTRIES;
 
 	/* PHY ops are filled in by default properly for Fiber only */

