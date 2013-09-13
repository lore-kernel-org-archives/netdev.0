From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/6] e1000e: cleanup boolean comparison to true
Date: Fri, 13 Sep 2013 14:12:09 -0700
Message-ID: <1379106730-14994-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860Ab3IMVMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 17:12:20 -0400
In-Reply-To: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Removing a comparison to the boolean value true where simply interrogating
the lvalue will produce the same result.

Signed-off-by: David Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e87e9b0..4ef7867 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4868,7 +4868,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			 */
 			if ((hw->phy.type == e1000_phy_igp_3 ||
 			     hw->phy.type == e1000_phy_bm) &&
-			    (hw->mac.autoneg == true) &&
+			    hw->mac.autoneg &&
 			    (adapter->link_speed == SPEED_10 ||
 			     adapter->link_speed == SPEED_100) &&
 			    (adapter->link_duplex == HALF_DUPLEX)) {
-- 
1.8.3.1
