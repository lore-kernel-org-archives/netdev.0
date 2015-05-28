From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e/i40evf: Remove unneeded TODO
Date: Thu, 28 May 2015 04:25:33 -0700
Message-ID: <1432812339-17129-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56315 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754001AbbE1LZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:55 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

There's no need for a counter so remove the TODO comment.

Change-ID: I3321dda04934c4f5fda9b279ab666192bda44214
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 ---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index fc4ec82..78ab8b5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1653,9 +1653,6 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(rx_error & (1 << I40E_RX_DESC_ERROR_RXE_SHIFT))) {
 			dev_kfree_skb_any(skb);
-			/* TODO: shouldn't we increment a counter indicating the
-			 * drop?
-			 */
 			continue;
 		}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 09cc2d7..1c79a08 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1128,9 +1128,6 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(rx_error & (1 << I40E_RX_DESC_ERROR_RXE_SHIFT))) {
 			dev_kfree_skb_any(skb);
-			/* TODO: shouldn't we increment a counter indicating the
-			 * drop?
-			 */
 			continue;
 		}
 
-- 
2.1.0
