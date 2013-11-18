From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 3/3] vhost: fix the wrong log descriptions
Date: Mon, 18 Nov 2013 11:19:23 +0800
Message-ID: <1384744763-7476-3-git-send-email-zwu.kernel@gmail.com>
References: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41465 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959Ab3KRDU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 22:20:28 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Sun, 17 Nov 2013 22:20:27 -0500
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id EC8FBC9003E
	for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 22:20:23 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAI3KPIL66257056
	for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 03:20:25 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAI3KOia011034
	for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 22:20:25 -0500
In-Reply-To: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/vhost/vhost.c  |    2 +-
 drivers/vhost/vringh.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 78987e4..568d20f 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1241,7 +1241,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 
 	/* If their number is silly, that's an error. */
 	if (unlikely(head >= vq->num)) {
-		vq_err(vq, "Guest says index %u > %u is available",
+		vq_err(vq, "Guest says index %u > %u is unavailable",
 		       head, vq->num);
 		return -EINVAL;
 	}
diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index 5174eba..86ef6c4 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -57,7 +57,7 @@ static inline int __vringh_get_head(const struct vringh *vrh,
 	}
 
 	if (head >= vrh->vring.num) {
-		vringh_bad("Guest says index %u > %u is available",
+		vringh_bad("Guest says index %u > %u is unavailable",
 			   head, vrh->vring.num);
 		return -EINVAL;
 	}
-- 
1.7.6.5
