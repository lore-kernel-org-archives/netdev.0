From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 19/30] e1000e: remove unnecessary break after
	return
Date: Sun, 20 Jul 2014 16:25:20 +0200
Message-ID: <1405866332-24652-10-git-send-email-fabf@skynet.be>
References: <1405866332-24652-1-git-send-email-fabf@skynet.be>
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
In-Reply-To: <1405866332-24652-1-git-send-email-fabf@skynet.be>
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
 drivers/net/ethernet/intel/e1000e/82571.c   | 4 ----
 drivers/net/ethernet/intel/e1000e/ethtool.c | 2 --
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 1 -
 drivers/net/ethernet/intel/e1000e/mac.c     | 1 -
 4 files changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 218481e..dc79ed8 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -95,7 +95,6 @@ static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 		break;
 	default:
 		return -E1000_ERR_PHY;
-		break;
 	}
 
 	/* This can only be done after all function pointers are setup. */
@@ -422,7 +421,6 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 		break;
 	case e1000_82573:
 		return e1000e_get_phy_id(hw);
-		break;
 	case e1000_82574:
 	case e1000_82583:
 		ret_val = e1e_rphy(hw, MII_PHYSID1, &phy_id);
@@ -440,7 +438,6 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 		break;
 	default:
 		return -E1000_ERR_PHY;
-		break;
 	}
 
 	return 0;
@@ -1458,7 +1455,6 @@ static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw)
 		break;
 	default:
 		return -E1000_ERR_PHY;
-		break;
 	}
 
 	if (ret_val)
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 815e26c..865ce45 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1521,11 +1521,9 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 		switch (hw->mac.type) {
 		case e1000_80003es2lan:
 			return e1000_set_es2lan_mac_loopback(adapter);
-			break;
 		case e1000_82571:
 		case e1000_82572:
 			return e1000_set_82571_fiber_loopback(adapter);
-			break;
 		default:
 			rctl = er32(RCTL);
 			rctl |= E1000_RCTL_LBM_TCVR;
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 8894ab8..f236861 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -572,7 +572,6 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		break;
 	default:
 		return -E1000_ERR_PHY;
-		break;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 8c386f3a..30b74d5 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -787,7 +787,6 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 	default:
 		e_dbg("Flow control param set incorrectly\n");
 		return -E1000_ERR_CONFIG;
-		break;
 	}
 
 	ew32(TXCW, txcw);
-- 
1.9.1


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
