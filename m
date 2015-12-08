From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 1/6] Revert "VSOCK: fix returnvar.cocci warnings"
Date: Tue,  8 Dec 2015 19:57:31 +0800
Message-ID: <1449575856-28507-2-git-send-email-stefanha@redhat.com>
References: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Cc: Matt Benjamin <mbenjamin@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, kvm@vger.kernel.org,
	Christoffer Dall <christoffer.dall@linaro.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, matt.ma@linaro.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438AbbLHL5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 06:57:48 -0500
In-Reply-To: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 0d76d6e8b2507983a2cae4c09880798079007421.

Keep virtio-vsock out-of-tree until the virtio-vsock device
specification is finalized.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 drivers/vhost/vsock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 64bcb10..65b1cf8 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -56,7 +56,8 @@ struct vhost_vsock {
 
 static u32 vhost_transport_get_local_cid(void)
 {
-	return VHOST_VSOCK_DEFAULT_HOST_CID;
+	u32 cid = VHOST_VSOCK_DEFAULT_HOST_CID;
+	return cid;
 }
 
 static struct vhost_vsock *vhost_vsock_get(u32 guest_cid)
-- 
2.5.0
