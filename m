From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH] xen-netback: remove duplicated function definition
Date: Sat,  4 Jul 2015 03:33:00 +0800
Message-ID: <1435951980-16265-1-git-send-email-liang.z.li@intel.com>
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	Liang Li <liang.z.li@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two duplicated xenvif_zerocopy_callback() definitions.
Remove one of them.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 drivers/net/xen-netback/common.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 8a495b3..c6cb85a 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -325,9 +325,6 @@ static inline pending_ring_idx_t nr_pending_reqs(struct xenvif_queue *queue)
 		queue->pending_prod + queue->pending_cons;
 }
 
-/* Callback from stack when TX packet can be released */
-void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
-
 irqreturn_t xenvif_interrupt(int irq, void *dev_id);
 
 extern bool separate_tx_rx_irq;
-- 
1.9.1
