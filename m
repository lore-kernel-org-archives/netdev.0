From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/10] ixgbe: fix some multiline hw_dbg prints
Date: Wed, 12 Mar 2014 19:31:29 -0700
Message-ID: <1394677890-11043-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25571 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242AbaCMCb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 22:31:57 -0400
In-Reply-To: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes some formatting on multilined print messages, so that
the text of the print appears on a single line, which aids in grepping
the sourcecode for where the error came from.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 446df3c..3bc9b67 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -512,7 +512,7 @@ out:
  *
  * Disables link, should be called during D3 power down sequence.
  *
- */
+ **/
 static void ixgbe_stop_mac_link_on_d3_82599(struct ixgbe_hw *hw)
 {
 	u32 autoc2_reg;
@@ -1005,8 +1005,7 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 
 out:
 	if (link_up && (link_speed == IXGBE_LINK_SPEED_1GB_FULL))
-		hw_dbg(hw, "Smartspeed has downgraded the link speed from "
-		       "the maximum advertised\n");
+		hw_dbg(hw, "Smartspeed has downgraded the link speed from the maximum advertised\n");
 	return status;
 }
 
@@ -1114,8 +1113,7 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 				if (!(links_reg & IXGBE_LINKS_KX_AN_COMP)) {
 					status =
 					        IXGBE_ERR_AUTONEG_NOT_COMPLETE;
-					hw_dbg(hw, "Autoneg did not "
-					       "complete.\n");
+					hw_dbg(hw, "Autoneg did not complete.\n");
 				}
 			}
 		}
-- 
1.8.3.1
