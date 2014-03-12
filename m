From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] ixgbe: fixup header for ixgbe_set_rxpba_82598
Date: Tue, 11 Mar 2014 22:53:36 -0700
Message-ID: <1394603618-1044-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9113 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120AbaCLFxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:44 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The header above this function did not match the function prototype.
This patch rewords the comment to specify the correct parameters.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index e61aa1f..f8ebe58 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1241,14 +1241,14 @@ static void ixgbe_set_lan_id_multi_port_pcie_82598(struct ixgbe_hw *hw)
 }
 
 /**
- * ixgbe_set_rxpba_82598 - Configure packet buffers
+ * ixgbe_set_rxpba_82598 - Initialize RX packet buffer
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
- *
- * Configure packet buffers.
- */
-static void ixgbe_set_rxpba_82598(struct ixgbe_hw *hw, int num_pb, u32 headroom,
-				  int strategy)
+ * @num_pb: number of packet buffers to allocate
+ * @headroom: reserve n KB of headroom
+ * @strategy: packet buffer allocation strategy
+ **/
+static void ixgbe_set_rxpba_82598(struct ixgbe_hw *hw, int num_pb,
+				  u32 headroom, int strategy)
 {
 	u32 rxpktsize = IXGBE_RXPBSIZE_64KB;
 	u8  i = 0;
-- 
1.8.3.1
