From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/10] ixgbe: fix checkpatch style of blank line after declaration
Date: Fri, 23 May 2014 05:59:09 -0700
Message-ID: <1400849956-8387-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28124 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbaEWM7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 08:59:30 -0400
In-Reply-To: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
