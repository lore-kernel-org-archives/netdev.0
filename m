From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] ixgbe: add default setup_link for x550em_a MAC type
Date: Tue, 18 Apr 2017 16:01:57 -0700
Message-ID: <20170418230205.37223-8-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58032 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757418AbdDRXCO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:14 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add default setting for mac->ops.setup_link on x550em_a MAC types.
This fixes a link issue on KR parts.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index af579c21e57f..04d6c744b936 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3795,7 +3795,7 @@ static struct ixgbe_mac_operations mac_ops_x550em_a = {
 	.get_media_type		= ixgbe_get_media_type_X550em,
 	.get_san_mac_addr	= NULL,
 	.get_wwn_prefix		= NULL,
-	.setup_link		= NULL, /* defined later */
+	.setup_link		= &ixgbe_setup_mac_link_X540,
 	.get_link_capabilities	= ixgbe_get_link_capabilities_X550em,
 	.get_bus_info		= ixgbe_get_bus_info_X550em,
 	.setup_sfp		= ixgbe_setup_sfp_modules_X550em,
-- 
2.12.2
