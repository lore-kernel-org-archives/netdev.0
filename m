From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  15/15] e1000e: resolve checkpatch JIFFIES_COMPARISON warning
Date: Wed, 21 Aug 2013 01:23:36 -0700
Message-ID: <1377073416-7872-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:18759 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022Ab3HUIYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 04:24:20 -0400
In-Reply-To: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

WARNING:JIFFIES_COMPARISON: Comparing jiffies is almost always wrong;
prefer time_after, time_before and friends

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index e4ebd7d..a8633b8 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1665,7 +1665,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 			ret_val = 13;	/* ret_val is the same as mis-compare */
 			break;
 		}
-		if (jiffies >= (time + 20)) {
+		if (time_after(jiffies, time + 20)) {
 			ret_val = 14;	/* error code for time out error */
 			break;
 		}
-- 
1.8.3.1
