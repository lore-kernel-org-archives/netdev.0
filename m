From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] e1000e: Cleanup checkpatch extra space
Date: Wed, 23 Apr 2014 04:15:21 -0700
Message-ID: <1398251726-13638-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181AbaDWLPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:37 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Fixing "WARNING:SPACING: Unnecessary space before function pointer arguments"

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 1471c54..e27e609 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -265,10 +265,10 @@ struct e1000_adapter {
 	u32 tx_hwtstamp_timeouts;
 
 	/* Rx */
-	bool (*clean_rx) (struct e1000_ring *ring, int *work_done,
-			  int work_to_do) ____cacheline_aligned_in_smp;
-	void (*alloc_rx_buf) (struct e1000_ring *ring, int cleaned_count,
-			      gfp_t gfp);
+	bool (*clean_rx)(struct e1000_ring *ring, int *work_done,
+			 int work_to_do) ____cacheline_aligned_in_smp;
+	void (*alloc_rx_buf)(struct e1000_ring *ring, int cleaned_count,
+			     gfp_t gfp);
 	struct e1000_ring *rx_ring;
 
 	u32 rx_int_delay;
-- 
1.9.0
