From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 1/2] vhost-vsock: remove unused vq variable
Date: Wed,  7 Dec 2016 17:52:18 +0800
Message-ID: <1481104340-77035-1-git-send-email-bergwolf@gmail.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, Peng Tao <bergwolf@gmail.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34255 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbcLGJzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:55:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 drivers/vhost/vsock.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 0c23b55..3e01d58 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -195,7 +195,6 @@ static int
 vhost_transport_send_pkt(struct virtio_vsock_pkt *pkt)
 {
 	struct vhost_vsock *vsock;
-	struct vhost_virtqueue *vq;
 	int len = pkt->len;
 
 	/* Find the vhost_vsock according to guest context id  */
@@ -205,8 +204,6 @@ vhost_transport_send_pkt(struct virtio_vsock_pkt *pkt)
 		return -ENODEV;
 	}
 
-	vq = &vsock->vqs[VSOCK_VQ_RX];
-
 	if (pkt->reply)
 		atomic_inc(&vsock->queued_replies);
 
-- 
2.7.4
