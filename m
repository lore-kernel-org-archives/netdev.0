From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  8/9] igb: Add ethtool offline tests for i354
Date: Tue,  1 Oct 2013 04:33:55 -0700
Message-ID: <1380627236-3190-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47745 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371Ab3JALeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:34:04 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Fujinaka, Todd" <todd.fujinaka@intel.com>

Add the ethtool offline tests for i354 devices.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 48cbc83..e4c77c0 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1656,7 +1656,8 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 		if ((hw->device_id == E1000_DEV_ID_DH89XXCC_SGMII) ||
 		(hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
 		(hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
-		(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP)) {
+		(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP) ||
+		(hw->device_id == E1000_DEV_ID_I354_SGMII)) {
 
 			/* Enable DH89xxCC MPHY for near end loopback */
 			reg = rd32(E1000_MPHY_ADDR_CTL);
@@ -1722,7 +1723,8 @@ static void igb_loopback_cleanup(struct igb_adapter *adapter)
 	if ((hw->device_id == E1000_DEV_ID_DH89XXCC_SGMII) ||
 	(hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
 	(hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
-	(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP)) {
+	(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP) ||
+	(hw->device_id == E1000_DEV_ID_I354_SGMII)) {
 		u32 reg;
 
 		/* Disable near end loopback on DH89xxCC */
-- 
1.8.3.1
