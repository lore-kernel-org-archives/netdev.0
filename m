From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next RFC 4/5] xen-netback: Fix indentations
Date: Wed, 30 Oct 2013 00:50:19 +0000
Message-ID: <1383094220-14775-5-git-send-email-zoltan.kiss@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've left intentionally these indentations in this way, to improve readability of previous patches.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/netback.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index c91dd36..204fa46 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -882,8 +882,8 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 
 	for (shinfo->nr_frags = start; shinfo->nr_frags < nr_slots;
 	     shinfo->nr_frags++, txp++, gop++) {
-				index = pending_index(vif->pending_cons++);
-				pending_idx = vif->pending_ring[index];
+		index = pending_index(vif->pending_cons++);
+		pending_idx = vif->pending_ring[index];
 		xenvif_tx_create_gop(vif, pending_idx, txp, gop);
 		frag_set_pending_idx(&frags[shinfo->nr_frags], pending_idx);
 	}
@@ -929,7 +929,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		tx_info = &vif->pending_tx_info[pending_idx];
 
 		/* Check error status: if okay then remember grant handle. */
-			newerr = (++gop)->status;
+		newerr = (++gop)->status;
 
 		if (likely(!newerr)) {
 			if (vif->grant_tx_handle[pending_idx] !=
@@ -1717,10 +1717,10 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
 
-		pending_tx_info = &vif->pending_tx_info[pending_idx];
-		make_tx_response(vif, &pending_tx_info->req, status);
-		index = pending_index(vif->pending_prod++);
-		vif->pending_ring[index] = pending_idx;
+	pending_tx_info = &vif->pending_tx_info[pending_idx];
+	make_tx_response(vif, &pending_tx_info->req, status);
+	index = pending_index(vif->pending_prod++);
+	vif->pending_ring[index] = pending_idx;
 }
 
 void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
