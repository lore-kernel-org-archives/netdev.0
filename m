From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] e1000e: cleanup - remove inapplicable comment
Date: Thu, 23 Aug 2012 02:56:43 -0700
Message-ID: <1345715813-20757-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59883 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758295Ab2HWJ45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:56:57 -0400
In-Reply-To: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 46c3b1f..e4d8041 100644
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
