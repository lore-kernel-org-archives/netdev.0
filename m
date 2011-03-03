From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 15/24] ixgbe: cleanup X540 PHY reset function pointer
Date: Thu,  3 Mar 2011 05:03:40 -0800
Message-ID: <1299157429-15878-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49621 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758206Ab1CCNEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:23 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The X540 PHY reset pointer isn't currently used which is a good thing as it
wouldn't work as implemented.  On top of that the X540 firmware is written
with the assumption that is does not need to be reset for proper
initialization so it's not needed.  I'm just assigning the pointer at NULL
as the current implementation is rather misleading.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_x540.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index a6f06d5..3229398 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -712,7 +712,7 @@ static struct ixgbe_phy_operations phy_ops_X540 = {
 	.identify               = &ixgbe_identify_phy_generic,
 	.identify_sfp           = &ixgbe_identify_sfp_module_generic,
 	.init			= NULL,
-	.reset                  = &ixgbe_reset_phy_generic,
+	.reset                  = NULL,
 	.read_reg               = &ixgbe_read_phy_reg_generic,
 	.write_reg              = &ixgbe_write_phy_reg_generic,
 	.setup_link             = &ixgbe_setup_phy_link_generic,
-- 
1.7.4

