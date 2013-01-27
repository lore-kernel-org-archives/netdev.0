From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] e1000e: add comment to spinlock_t definition
Date: Sun, 27 Jan 2013 02:39:50 -0800
Message-ID: <1359283193-2043-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43564 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756534Ab3A0KkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:40:05 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index c7bc610..e6b9483 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -372,7 +372,7 @@ struct e1000_adapter {
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
 
-	spinlock_t stats64_lock;
+	spinlock_t stats64_lock;	/* protects statistics counters */
 	struct e1000_hw_stats stats;
 	struct e1000_phy_info phy_info;
 	struct e1000_phy_stats phy_stats;
-- 
1.7.11.7
