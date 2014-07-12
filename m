From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 2/9] ixgbe: remove unnecessary break after
	goto
Date: Sat, 12 Jul 2014 20:09:41 +0200
Message-ID: <1405188597-2815-3-git-send-email-fabf@skynet.be>
References: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Fabian Frederick <fabf@skynet.be>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	joe@perches.com, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405188597-2815-1-git-send-email-fabf@skynet.be>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  | 4 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 --
 3 files changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 1560933..206171f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -430,7 +430,6 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw)
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = IXGBE_ERR_CONFIG;
 		goto out;
-		break;
 	}
 
 	/* Set 802.3x based flow control settings. */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index bc7c924..0373a5b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -432,7 +432,6 @@ static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 	default:
 		status = IXGBE_ERR_LINK_SETUP;
 		goto out;
-		break;
 	}
 
 	if (hw->phy.multispeed_fiber) {
@@ -2035,7 +2034,6 @@ static u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 		else if (pma_pmd_10g_parallel == IXGBE_AUTOC_10G_XAUI)
 			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_XAUI;
 		goto out;
-		break;
 	case IXGBE_AUTOC_LMS_10G_SERIAL:
 		if (pma_pmd_10g_serial == IXGBE_AUTOC2_10G_KR) {
 			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_KR;
@@ -2052,10 +2050,8 @@ static u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 		if (autoc & IXGBE_AUTOC_KR_SUPP)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_KR;
 		goto out;
-		break;
 	default:
 		goto out;
-		break;
 	}
 
 sfp_check:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 4e5385a..3f318c5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -216,7 +216,6 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw)
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = IXGBE_ERR_CONFIG;
 		goto out;
-		break;
 	}
 
 	if (hw->mac.type != ixgbe_mac_X540) {
@@ -2179,7 +2178,6 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw)
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = IXGBE_ERR_CONFIG;
 		goto out;
-		break;
 	}
 
 	/* Set 802.3x based flow control settings. */
-- 
1.9.1


------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
