From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] igb/ixgbe: Fix typo in igb_build_skb and/or ixgbe_build_skb code comment
Date: Fri, 17 Mar 2017 12:58:18 -0700
Message-ID: <20170317195818.74912-14-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21553 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751272AbdCQT63 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:29 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There was a typo that I had left in the code comments for the igb and ixgbe
functions that enabled build_skb support.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 79f39a785dca..26a821fcd220 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7041,7 +7041,7 @@ static struct sk_buff *igb_build_skb(struct igb_ring *rx_ring,
 	prefetch(va + L1_CACHE_BYTES);
 #endif
 
-	/* build an skb to around the page buffer */
+	/* build an skb around the page buffer */
 	skb = build_skb(va - IGB_SKB_PAD, truesize);
 	if (unlikely(!skb))
 		return NULL;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d45477db0227..852a2e7e25ed 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2122,7 +2122,7 @@ static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
 	prefetch(va + L1_CACHE_BYTES);
 #endif
 
-	/* build an skb to around the page buffer */
+	/* build an skb around the page buffer */
 	skb = build_skb(va - IXGBE_SKB_PAD, truesize);
 	if (unlikely(!skb))
 		return NULL;
-- 
2.12.0
