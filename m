From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] e1000e: cleanup: remove unused #define
Date: Mon, 28 Jan 2013 01:04:24 -0800
Message-ID: <1359363869-32391-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47947 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389Ab3A1JEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:39 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

All references to E1000_ERT_2048 have been removed.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 4ffb62b..c7d5c5b 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -78,9 +78,6 @@ struct e1000_info;
 #define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */
 #define E1000_MAX_ITR_USECS		10000 /* 100    irq/sec */
 
-/* Early Receive defines */
-#define E1000_ERT_2048			0x100
-
 #define E1000_FC_PAUSE_TIME		0x0680 /* 858 usec */
 
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
-- 
1.7.11.7
