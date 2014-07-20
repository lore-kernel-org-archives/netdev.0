From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 17/30] e1000: remove unnecessary break after
	return
Date: Sun, 20 Jul 2014 16:25:18 +0200
Message-ID: <1405866332-24652-8-git-send-email-fabf@skynet.be>
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
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 3 ---
 drivers/net/ethernet/intel/e1000/e1000_hw.c      | 2 --
 2 files changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index d50f78a..cca5bca 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1316,7 +1316,6 @@ static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 	case e1000_82547:
 	case e1000_82547_rev_2:
 		return e1000_integrated_phy_loopback(adapter);
-		break;
 	default:
 		/* Default PHY loopback work is to read the MII
 		 * control register and assert bit 14 (loopback mode).
@@ -1325,7 +1324,6 @@ static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 		phy_reg |= MII_CR_LOOPBACK;
 		e1000_write_phy_reg(hw, PHY_CTRL, phy_reg);
 		return 0;
-		break;
 	}
 
 	return 8;
@@ -1344,7 +1342,6 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 		case e1000_82545_rev_3:
 		case e1000_82546_rev_3:
 			return e1000_set_phy_loopback(adapter);
-			break;
 		default:
 			rctl = er32(RCTL);
 			rctl |= E1000_RCTL_LBM_TCVR;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index e9b07cc..1acf503 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -902,7 +902,6 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 	default:
 		e_dbg("Flow control param set incorrectly\n");
 		return -E1000_ERR_CONFIG;
-		break;
 	}
 
 	/* Since auto-negotiation is enabled, take the link out of reset (the
@@ -5041,7 +5040,6 @@ static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
 			break;
 		default:
 			return -E1000_ERR_PHY;
-			break;
 		}
 	} else if (hw->phy_type == e1000_phy_igp) {	/* For IGP PHY */
 		u16 cur_agc_value;
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
