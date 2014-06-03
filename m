From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] igb: use mac loopback for i354 backplane
Date: Tue,  3 Jun 2014 00:45:06 -0700
Message-ID: <1401781509-6435-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52586 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932398AbaFCHre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2014 03:47:34 -0400
In-Reply-To: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

We can't know what PHY is to be used for i354 backplane, so use MAC
loopback for ethtool tests.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a84297c..0716dbe 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1665,8 +1665,8 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 		(hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
 		(hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
 		(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP) ||
-		(hw->device_id == E1000_DEV_ID_I354_SGMII)) {
-
+		(hw->device_id == E1000_DEV_ID_I354_SGMII) ||
+		(hw->device_id == E1000_DEV_ID_I354_BACKPLANE_2_5GBPS)) {
 			/* Enable DH89xxCC MPHY for near end loopback */
 			reg = rd32(E1000_MPHY_ADDR_CTL);
 			reg = (reg & E1000_MPHY_ADDR_CTL_OFFSET_MASK) |
-- 
1.9.3
