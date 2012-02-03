From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] ixgbe: Fix typo in ixgbe_common.h
Date: Fri,  3 Feb 2012 03:15:03 -0800
Message-ID: <1328267703-9638-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53720 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756050Ab2BCLPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 06:15:20 -0500
In-Reply-To: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masanari Iida <standby24x7@gmail.com>

Correct spelling "packtetbuf_num" to "packetbuf_num" in
drivers/net/ethernet/intel/ixgbe/ixgbe_common.h

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 5ccea80..2c834c4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -75,7 +75,7 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
-s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packtetbuf_num);
+s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num);
 s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw);
 
 s32 ixgbe_validate_mac_addr(u8 *mac_addr);
-- 
1.7.7.6
