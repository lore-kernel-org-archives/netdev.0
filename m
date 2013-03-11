From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] vhost-blk: remove unused variable
Date: Mon, 11 Mar 2013 22:39:27 +0800
Message-ID: <CAPgLHd-eRBB2xCP7-ZswjfEKXPY29G1Nv71DzGo_-=TVym8MNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33177 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab3CKOj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 10:39:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The variable vq is initialized but never used
otherwise, so remove the unused variable.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/vhost/blk.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/vhost/blk.c b/drivers/vhost/blk.c
index 658c5f9..d9b245b 100644
--- a/drivers/vhost/blk.c
+++ b/drivers/vhost/blk.c
@@ -419,8 +419,6 @@ static void vhost_blk_handle_guest_kick(struct vhost_work *work)
 /* Host kick us for I/O completion */
 static void vhost_blk_handle_host_kick(struct vhost_work *work)
 {
-
-	struct vhost_virtqueue *vq;
 	struct vhost_blk_req *req;
 	struct llist_node *llnode;
 	struct vhost_blk *blk;
@@ -429,7 +427,6 @@ static void vhost_blk_handle_host_kick(struct vhost_work *work)
 	int ret;
 
 	blk = container_of(work, struct vhost_blk, work);
-	vq = &blk->vq;
 
 	llnode = llist_del_all(&blk->llhead);
 	added = false;
