From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] e1000e: correct maximum frame size on i217/i218
Date: Sun, 27 Jan 2013 02:39:47 -0800
Message-ID: <1359283193-2043-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43564 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756531Ab3A0KkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:40:03 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The largest jumbo frame supported by the i217 and i218 hardware is 9018.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index c25678d..e0f41f0 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -4633,7 +4633,7 @@ const struct e1000_info e1000_pch_lpt_info = {
 	.flags2			= FLAG2_HAS_PHY_STATS
 				  | FLAG2_HAS_EEE,
 	.pba			= 26,
-	.max_hw_frame_size	= DEFAULT_JUMBO,
+	.max_hw_frame_size	= 9018,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
-- 
1.7.11.7
