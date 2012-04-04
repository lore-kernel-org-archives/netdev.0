From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] e1000e: Minor comment clean-up.
Date: Wed,  4 Apr 2012 00:55:54 -0700
Message-ID: <1333526160-24937-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39155 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755081Ab2DDH4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 03:56:04 -0400
In-Reply-To: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Move the first phrase of a multi-line comment to the second line.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2c38a65..6b63388 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1053,7 +1053,8 @@ static void e1000_print_hw_hang(struct work_struct *work)
 
 	if (!adapter->tx_hang_recheck &&
 	    (adapter->flags2 & FLAG2_DMA_BURST)) {
-		/* May be block on write-back, flush and detect again
+		/*
+		 * May be block on write-back, flush and detect again
 		 * flush pending descriptor writebacks to memory
 		 */
 		ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
-- 
1.7.7.6
