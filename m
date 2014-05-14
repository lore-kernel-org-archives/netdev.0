From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbe: fix checkpatch style of blank line after declaration
Date: Wed, 14 May 2014 01:54:16 -0700
Message-ID: <1400057663-4578-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40067 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753485AbaENIyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:37 -0400
In-Reply-To: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes checkpatch warnings in ixgbe, by adding a blank line
between declaration and code blocks.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 323ecb1..272f2e7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1271,6 +1271,7 @@ s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw)
 {
 	int i;
 	u32 fdirctrl = IXGBE_READ_REG(hw, IXGBE_FDIRCTRL);
+
 	fdirctrl &= ~IXGBE_FDIRCTRL_INIT_DONE;
 
 	/*
@@ -1651,6 +1652,7 @@ void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
 static u32 ixgbe_get_fdirtcpm_82599(union ixgbe_atr_input *input_mask)
 {
 	u32 mask = ntohs(input_mask->formatted.dst_port);
+
 	mask <<= IXGBE_FDIRTCPM_DPORTM_SHIFT;
 	mask |= ntohs(input_mask->formatted.src_port);
 	mask = ((mask & 0x55555555) << 1) | ((mask & 0xAAAAAAAA) >> 1);
-- 
1.9.0
