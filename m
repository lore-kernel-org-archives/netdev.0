From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] fm10k: use 8bit notation instead of 10bit notation for diagram
Date: Wed, 20 Apr 2016 23:09:23 -0700
Message-ID: <1461218969-68578-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647AbcDUGJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:36 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The diagram represents bit layout of the multi-bit VLAN update message
format. Typically these diagrams are drawn using some power of 2 as the
base, to more easily grasp where fields split. Although the numbers
above can make it somewhat easy to understand which bit you're looking
at, it makes the break points not line up. Re-draw the numbers using
base 8, and mark the bit values every 8 bits at the top. This should
make it more easy to grasp the table quickly.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 865f5c2..ffe9805 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -219,8 +219,8 @@ static s32 fm10k_update_vlan_pf(struct fm10k_hw *hw, u32 vid, u8 vsi, bool set)
 
 	/* VLAN multi-bit write:
 	 * The multi-bit write has several parts to it.
-	 *    3			  2		      1			  0
-	 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+	 *               24              16               8               0
+	 *  7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
 	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 	 * | RSVD0 |         Length        |C|RSVD0|        VLAN ID        |
 	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-- 
2.5.5
