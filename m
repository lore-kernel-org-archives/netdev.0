From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] igb: fix a typo in igb_reset_q_vector()
Date: Tue, 21 Apr 2015 16:20:33 -0700
Message-ID: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34321 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964880AbbDUXUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 19:20:41 -0400
Received: by pdbqa5 with SMTP id qa5so255675591pdb.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 16:20:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 5536d2102a2d ("igb: Combine q_vector and ring allocation into a single function")
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8457d03..85bbeb2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1036,7 +1036,7 @@ static void igb_reset_q_vector(struct igb_adapter *adapter, int v_idx)
 		adapter->tx_ring[q_vector->tx.ring->queue_index] = NULL;
 
 	if (q_vector->rx.ring)
-		adapter->tx_ring[q_vector->rx.ring->queue_index] = NULL;
+		adapter->rx_ring[q_vector->rx.ring->queue_index] = NULL;
 
 	netif_napi_del(&q_vector->napi);
 
-- 
1.8.3.1
