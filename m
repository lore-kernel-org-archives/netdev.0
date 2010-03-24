From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 8/9] net/intel: remove trailing space in
	messages
Date: Wed, 24 Mar 2010 18:57:35 +0100
Message-ID: <1269453456-13599-8-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Frans Pop <elendil@planet.nl>
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <201003241840.18701.elendil@planet.nl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Includes one minor indentation fix to placate checkpatch.

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: e1000-devel@lists.sourceforge.net
---
 drivers/net/e1000/e1000_hw.c       |    4 ++--
 drivers/net/eepro.c                |    4 ++--
 drivers/net/ixgbe/ixgbe_82599.c    |    2 +-
 drivers/net/ixgbe/ixgbe_main.c     |    6 +++---
 drivers/net/ixgbe/ixgbe_phy.c      |    4 ++--
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 8d7d87f..e2b6e6e 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -990,7 +990,7 @@ static s32 e1000_copper_link_preconfig(struct e1000_hw *hw)
 		DEBUGOUT("Error, did not detect valid phy.\n");
 		return ret_val;
 	}
-	DEBUGOUT1("Phy ID = %x \n", hw->phy_id);
+	DEBUGOUT1("Phy ID = %x\n", hw->phy_id);
 
 	/* Set PHY to class A mode (if necessary) */
 	ret_val = e1000_set_phy_mode(hw);
@@ -1680,7 +1680,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		DEBUGOUT1("M88E1000 PSCR: %x \n", phy_data);
+		DEBUGOUT1("M88E1000 PSCR: %x\n", phy_data);
 
 		/* Need to reset the PHY or these changes will be ignored */
 		mii_ctrl_reg |= MII_CR_RESET;
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 1b05bdf..15d6266 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -646,7 +646,7 @@ static void __init printEEPROMInfo(struct net_device *dev)
 	if (GetBit(Word,ee_PortTPE)) printk(KERN_DEBUG "TPE ");
 	if (GetBit(Word,ee_PortBNC)) printk(KERN_DEBUG "BNC ");
 	if (GetBit(Word,ee_PortAUI)) printk(KERN_DEBUG "AUI ");
-	printk(KERN_DEBUG "port(s) \n");
+	printk(KERN_DEBUG "port(s)\n");
 
 	Word = lp->word[6];
 	printk(KERN_DEBUG "Word6:\n");
@@ -766,7 +766,7 @@ static int __init eepro_probe1(struct net_device *dev, int autoprobe)
 	/* Grab the region so we can find another board if autoIRQ fails. */
 	if (!request_region(ioaddr, EEPRO_IO_EXTENT, DRV_NAME)) {
 		if (!autoprobe)
-			printk(KERN_WARNING "EEPRO: io-port 0x%04x in use \n",
+			printk(KERN_WARNING "EEPRO: io-port 0x%04x in use\n",
 				ioaddr);
 		return -EBUSY;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index b405a00..f894bb6 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1269,7 +1269,7 @@ s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw)
 	}
 	if (i >= IXGBE_FDIRCMD_CMD_POLL) {
 		hw_dbg(hw ,"Flow Director previous command isn't complete, "
-		       "aborting table re-initialization. \n");
+		       "aborting table re-initialization.\n");
 		return IXGBE_ERR_FDIR_REINIT_FAILED;
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d75c46f..7e4e950 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3460,12 +3460,12 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 		adapter->num_tx_queues = 1;
 #ifdef CONFIG_IXGBE_DCB
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			DPRINTK(PROBE, INFO, "FCoE enabled with DCB \n");
+			DPRINTK(PROBE, INFO, "FCoE enabled with DCB\n");
 			ixgbe_set_dcb_queues(adapter);
 		}
 #endif
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-			DPRINTK(PROBE, INFO, "FCoE enabled with RSS \n");
+			DPRINTK(PROBE, INFO, "FCoE enabled with RSS\n");
 			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
 			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 				ixgbe_set_fdir_queues(adapter);
@@ -5081,7 +5081,7 @@ static void ixgbe_fdir_reinit_task(struct work_struct *work)
 			        &(adapter->tx_ring[i]->reinit_state));
 	} else {
 		DPRINTK(PROBE, ERR, "failed to finish FDIR re-initialization, "
-		        "ignored adding FDIR ATR filters \n");
+			"ignored adding FDIR ATR filters\n");
 	}
 	/* Done FDIR Re-initialization, enable transmits */
 	netif_tx_start_all_queues(adapter->netdev);
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 1c1efd3..d6d5b84 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -475,7 +475,7 @@ s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw)
 			msleep(edata);
 			break;
 		case IXGBE_DATA_NL:
-			hw_dbg(hw, "DATA:  \n");
+			hw_dbg(hw, "DATA:\n");
 			data_offset++;
 			hw->eeprom.ops.read(hw, data_offset++,
 			                    &phy_offset);
@@ -491,7 +491,7 @@ s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw)
 			break;
 		case IXGBE_CONTROL_NL:
 			data_offset++;
-			hw_dbg(hw, "CONTROL: \n");
+			hw_dbg(hw, "CONTROL:\n");
 			if (edata == IXGBE_CONTROL_EOL_NL) {
 				hw_dbg(hw, "EOL\n");
 				end_data = true;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 19e93a4..7cacb12 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3480,7 +3480,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 
 	hw_dbg(hw, "MAC: %d\n", hw->mac.type);
 
-	hw_dbg(hw, "LRO is disabled \n");
+	hw_dbg(hw, "LRO is disabled\n");
 
 	hw_dbg(hw, "Intel(R) 82599 Virtual Function\n");
 	cards_found++;
-- 
1.6.6.1


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
