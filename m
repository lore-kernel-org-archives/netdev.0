From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/10] igb/ixgbe: remove return statements for void functions
Date: Fri, 23 May 2014 05:59:15 -0700
Message-ID: <1400849956-8387-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43071 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752445AbaEWM7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 08:59:36 -0400
In-Reply-To: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove useless return statements for void functions which do not need
it.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_nvm.c     | 1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c | 2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c   | 1 -
 3 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.c b/drivers/net/ethernet/intel/igb/e1000_nvm.c
index 92bcdbe..e8280d0 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.c
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.c
@@ -798,5 +798,4 @@ etrack_id:
 		fw_vers->etrack_id = (eeprom_verh << NVM_ETRACK_SHIFT)
 			| eeprom_verl;
 	}
-	return;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 0ddd9a7..1560933 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1278,8 +1278,6 @@ static void ixgbe_set_rxpba_82598(struct ixgbe_hw *hw, int num_pb,
 	/* Setup Tx packet buffer sizes */
 	for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_TXPBSIZE(i), IXGBE_TXPBSIZE_40KB);
-
-	return;
 }
 
 static struct ixgbe_mac_operations mac_ops_82598 = {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 86b00a0..a689ee0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -389,7 +389,6 @@ static void ixgbe_dcb_read_rtrup2tc_82599(struct ixgbe_hw *hw, u8 *map)
 	for (i = 0; i < MAX_USER_PRIORITY; i++)
 		map[i] = IXGBE_RTRUP2TC_UP_MASK &
 			(reg >> (i * IXGBE_RTRUP2TC_UP_SHIFT));
-	return;
 }
 
 void ixgbe_dcb_read_rtrup2tc(struct ixgbe_hw *hw, u8 *map)
-- 
1.9.0
