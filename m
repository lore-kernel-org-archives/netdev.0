From: Liang Li <liang.z.li@intel.com>
Subject: [RESEND] xen-netback: remove duplicated function definition
Date: Mon,  6 Jul 2015 08:42:56 +0800
Message-ID: <1436143376-18457-1-git-send-email-liang.z.li@intel.com>
Cc: netdev@vger.kernel.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, xen-devel@lists.xenproject.org,
	davem@davemloft.net, Liang Li <liang.z.li@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13206 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbbGFAnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2015 20:43:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
