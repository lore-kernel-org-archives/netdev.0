From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/9] igb: make local functions static
Date: Thu, 19 Jan 2012 00:13:26 -0800
Message-ID: <1326960814-16976-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7452 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907Ab2ASINw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:52 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Sparse caught two functions that were only being used in one file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c  |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 73aac08..36450d3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -151,7 +151,7 @@ void igb_clear_vfta_i350(struct e1000_hw *hw)
  *  Writes value at the given offset in the register array which stores
  *  the VLAN filter table.
  **/
-void igb_write_vfta_i350(struct e1000_hw *hw, u32 offset, u32 value)
+static void igb_write_vfta_i350(struct e1000_hw *hw, u32 offset, u32 value)
 {
 	int i;
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 01e5e89..92fd642 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4003,8 +4003,8 @@ set_itr_now:
 	}
 }
 
-void igb_tx_ctxtdesc(struct igb_ring *tx_ring, u32 vlan_macip_lens,
-		     u32 type_tucmd, u32 mss_l4len_idx)
+static void igb_tx_ctxtdesc(struct igb_ring *tx_ring, u32 vlan_macip_lens,
+			    u32 type_tucmd, u32 mss_l4len_idx)
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	u16 i = tx_ring->next_to_use;
@@ -5623,7 +5623,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-void igb_ring_irq_enable(struct igb_q_vector *q_vector)
+static void igb_ring_irq_enable(struct igb_q_vector *q_vector)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct e1000_hw *hw = &adapter->hw;
-- 
1.7.7.5
