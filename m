From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/15] i40e: whitespace paren and comment tweaks
Date: Tue,  7 Jan 2014 22:07:33 -0800
Message-ID: <1389161256-24599-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23587 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755148AbaAHGIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:08:49 -0500
In-Reply-To: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Addresses a few code format issues that have crept in over time.

Change-Id: I1a62cbd16b29a218a933b0f7176abe748f9615e8
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_common.c | 1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 8 ++++----
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 3ee5323..18a768f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -672,7 +672,7 @@ static bool i40e_asq_done(struct i40e_hw *hw)
 	/* AQ designers suggest use of head for better
 	 * timing reliability than DD bit
 	 */
-	return (rd32(hw, hw->aq.asq.head) == hw->aq.asq.next_to_use);
+	return rd32(hw, hw->aq.asq.head) == hw->aq.asq.next_to_use;
 
 }
 
@@ -682,7 +682,7 @@ static bool i40e_asq_done(struct i40e_hw *hw)
  *  @desc: prefilled descriptor describing the command (non DMA mem)
  *  @buff: buffer to use for indirect commands
  *  @buff_size: size of buffer for indirect commands
- *  @opaque: pointer to info to be used in async cleanup
+ *  @cmd_details: pointer to command details structure
  *
  *  This is the main send command driver routine for the Admin Queue send
  *  queue.  It runs the queue, cleans the queue, etc
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 7e34de1..d564910 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -406,6 +406,7 @@ i40e_status i40e_pf_reset(struct i40e_hw *hw)
 	}
 
 	i40e_clear_pxe_mode(hw);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 4ac712e..bcf0317 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -89,7 +89,7 @@ typedef void (*I40E_ADMINQ_CALLBACK)(struct i40e_hw *, struct i40e_aq_desc *);
 #define I40E_QTX_CTL_VF_QUEUE	0x0
 #define I40E_QTX_CTL_PF_QUEUE	0x2
 
-/* debug masks */
+/* debug masks - set these bits in hw->debug_mask to control output */
 enum i40e_debug_mask {
 	I40E_DEBUG_INIT			= 0x00000001,
 	I40E_DEBUG_RELEASE		= 0x00000002,
@@ -103,10 +103,10 @@ enum i40e_debug_mask {
 	I40E_DEBUG_DCB			= 0x00000400,
 	I40E_DEBUG_DIAG			= 0x00000800,
 
-	I40E_DEBUG_AQ_MESSAGE		= 0x01000000, /* for i40e_debug() */
+	I40E_DEBUG_AQ_MESSAGE		= 0x01000000,
 	I40E_DEBUG_AQ_DESCRIPTOR	= 0x02000000,
 	I40E_DEBUG_AQ_DESC_BUFFER	= 0x04000000,
-	I40E_DEBUG_AQ_COMMAND		= 0x06000000, /* for i40e_debug_aq() */
+	I40E_DEBUG_AQ_COMMAND		= 0x06000000,
 	I40E_DEBUG_AQ			= 0x0F000000,
 
 	I40E_DEBUG_USER			= 0xF0000000,
@@ -520,7 +520,7 @@ enum i40e_rx_desc_status_bits {
 
 #define I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT  I40E_RX_DESC_STATUS_TSYNVALID_SHIFT
 #define I40E_RXD_QW1_STATUS_TSYNVALID_MASK	(0x1UL << \
-					     I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT)
+					 I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT)
 
 enum i40e_rx_desc_fltstat_values {
 	I40E_RX_DESC_FLTSTAT_NO_DATA	= 0,
-- 
1.8.3.1
