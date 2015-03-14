From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queue 2/7] ixgbe: Clean up type inconsistency
Date: Fri, 13 Mar 2015 17:00:43 -0700
Message-ID: <1426291248-14739-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	<kernel-team@fb.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19112 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbbCNAAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 20:00:51 -0400
In-Reply-To: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Missed this when I created commit 6a14ee0cfb197 ("ixgbe: Add X550 support
function pointers").  Use a the __be* type to be consistent with how the
value is assigned.

CC: <kernel-team@fb.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 02dc62e..c3ddc94 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2462,8 +2462,8 @@ struct ixgbe_hic_read_shadow_ram {
 
 struct ixgbe_hic_write_shadow_ram {
 	union ixgbe_hic_hdr2 hdr;
-	u32 address;
-	u16 length;
+	__be32 address;
+	__be16 length;
 	u16 pad2;
 	u16 data;
 	u16 pad3;
-- 
1.9.3
