From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] ixgbe : Fix typo in ixgbe_common.h
Date: Sat, 21 Jan 2012 22:49:34 +0900
Message-ID: <1327153774-2092-1-git-send-email-standby24x7@gmail.com>
Cc: standby24x7@gmail.com, trivial@kernel.org,
	linux-kernel@vger.kernel.org
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from i118-21-156-233.s30.a048.ap.plala.or.jp ([118.21.156.233]:60993
	"EHLO rinabert.homeip.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751547Ab2AUNuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 08:50:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct spelling "packtetbuf_num" to "packetbuf_num" in
drivers/net/ethernet/intel/ixgbe/ixgbe_common.h

Signed-off-by: Masanari Iida<standby24x7@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 863f9c1..4c9a4c8 100644
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
1.7.6.5
