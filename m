From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 2/3] virtio_net: Trivial coding style fix
Date: Tue, 27 May 2008 12:20:46 +0100
Message-ID: <1211887247-31979-3-git-send-email-markmc@redhat.com>
References: <1211887247-31979-1-git-send-email-markmc@redhat.com>
 <1211887247-31979-2-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail10.svc.cra.dublin.eircom.net ([159.134.118.26]:45467 "HELO
	mail10.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756825AbYE0L1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 07:27:30 -0400
In-Reply-To: <1211887247-31979-2-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fe7cdf2..50e6e59 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -94,7 +94,7 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 
 	if (hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
 		pr_debug("Needs csum!\n");
-		if (!skb_partial_csum_set(skb,hdr->csum_start,hdr->csum_offset))
+		if (!skb_partial_csum_set(skb, hdr->csum_start, hdr->csum_offset))
 			goto frame_err;
 	}
 
-- 
1.5.4.1

