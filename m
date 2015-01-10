From: Vincenzo Maffione <v.maffione@gmail.com>
Subject: [PATCH net] drivers: net: xen-netfront: remove residual dead code
Date: Sat, 10 Jan 2015 10:20:25 +0100
Message-ID: <1420881625-4935-1-git-send-email-v.maffione@gmail.com>
Cc: xen-devel@lists.xenproject.org, david.vrabel@citrix.com,
	boris.ostrovsky@oracle.com, konrad.wilk@oracle.com,
	Vincenzo Maffione <v.maffione@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35673 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbbAJIWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 03:22:18 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so11712459wgh.8
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 00:22:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes some unused arrays from the netfront private
data structures. These arrays were used in "flip" receive mode.

Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>
---
 drivers/net/xen-netfront.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 22bcb4e..a4e5048 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -144,10 +144,6 @@ struct netfront_queue {
 	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
 	grant_ref_t gref_rx_head;
 	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
-
-	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
-	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
-	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
 };
 
 struct netfront_info {
-- 
2.2.1
