From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 13/24] ixgbe: Fill out PCIe speed and width enums with values
Date: Thu,  3 Mar 2011 05:03:38 -0800
Message-ID: <1299157429-15878-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49621 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758204Ab1CCNEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:23 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch fills in the values for bus speed and width of the
ixgbe_bus_speed and ixgbe_bus_width enums.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_type.h |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 5ede03c..a737b13 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2333,25 +2333,25 @@ enum ixgbe_bus_type {
 /* PCI bus speeds */
 enum ixgbe_bus_speed {
 	ixgbe_bus_speed_unknown = 0,
-	ixgbe_bus_speed_33,
-	ixgbe_bus_speed_66,
-	ixgbe_bus_speed_100,
-	ixgbe_bus_speed_120,
-	ixgbe_bus_speed_133,
-	ixgbe_bus_speed_2500,
-	ixgbe_bus_speed_5000,
+	ixgbe_bus_speed_33      = 33,
+	ixgbe_bus_speed_66      = 66,
+	ixgbe_bus_speed_100     = 100,
+	ixgbe_bus_speed_120     = 120,
+	ixgbe_bus_speed_133     = 133,
+	ixgbe_bus_speed_2500    = 2500,
+	ixgbe_bus_speed_5000    = 5000,
 	ixgbe_bus_speed_reserved
 };
 
 /* PCI bus widths */
 enum ixgbe_bus_width {
 	ixgbe_bus_width_unknown = 0,
-	ixgbe_bus_width_pcie_x1,
-	ixgbe_bus_width_pcie_x2,
+	ixgbe_bus_width_pcie_x1 = 1,
+	ixgbe_bus_width_pcie_x2 = 2,
 	ixgbe_bus_width_pcie_x4 = 4,
 	ixgbe_bus_width_pcie_x8 = 8,
-	ixgbe_bus_width_32,
-	ixgbe_bus_width_64,
+	ixgbe_bus_width_32      = 32,
+	ixgbe_bus_width_64      = 64,
 	ixgbe_bus_width_reserved
 };
 
-- 
1.7.4

