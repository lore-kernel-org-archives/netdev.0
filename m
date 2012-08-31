From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] e1000e: cleanup - remove inapplicable comment
Date: Thu, 30 Aug 2012 22:16:10 -0700
Message-ID: <1346390174-30449-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14908 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab2HaFQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 01:16:42 -0400
In-Reply-To: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Early Receive has been disabled in the driver so this comment is no longer
applicable.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index fb6c813..c35d354 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3446,7 +3446,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 			/*
 			 * if short on Rx space, Rx wins and must trump Tx
-			 * adjustment or use Early Receive if available
+			 * adjustment
 			 */
 			if (pba < min_rx_space)
 				pba = min_rx_space;
-- 
1.7.11.4
