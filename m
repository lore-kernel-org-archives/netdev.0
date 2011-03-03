From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 22/24] ixgbe: X540 Cleanup
Date: Thu,  3 Mar 2011 05:03:47 -0800
Message-ID: <1299157429-15878-23-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758216Ab1CCNE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:26 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Clean up commented out include file and use #define instead of hard coded
value for number of RAR entries.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_x540.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index fbc0a8b..11cb136 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -31,7 +31,6 @@
 
 #include "ixgbe.h"
 #include "ixgbe_phy.h"
-//#include "ixgbe_mbx.h"
 
 #define IXGBE_X540_MAX_TX_QUEUES 128
 #define IXGBE_X540_MAX_RX_QUEUES 128
@@ -201,7 +200,7 @@ mac_reset_top:
 	 * clear the multicast table.  Also reset num_rar_entries to 128,
 	 * since we modify this value when programming the SAN MAC address.
 	 */
-	hw->mac.num_rar_entries = 128;
+	hw->mac.num_rar_entries = IXGBE_X540_MAX_TX_QUEUES;
 	hw->mac.ops.init_rx_addrs(hw);
 
 	/* Store the permanent mac address */
-- 
1.7.4

