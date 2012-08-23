From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] e1000e: cleanup strict checkpatch check
Date: Thu, 23 Aug 2012 02:56:42 -0700
Message-ID: <1345715813-20757-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48088 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758232Ab2HWJ45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:56:57 -0400
In-Reply-To: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

CHECK: multiple assignments should be avoided

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 2e76f06..c11ac27 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1942,7 +1942,8 @@ static int e1000_set_coalesce(struct net_device *netdev,
 		return -EINVAL;
 
 	if (ec->rx_coalesce_usecs == 4) {
-		adapter->itr = adapter->itr_setting = 4;
+		adapter->itr_setting = 4;
+		adapter->itr = adapter->itr_setting;
 	} else if (ec->rx_coalesce_usecs <= 3) {
 		adapter->itr = 20000;
 		adapter->itr_setting = ec->rx_coalesce_usecs;
-- 
1.7.11.4
