From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] virtio-net: fix leaking of ctx array
Date: Fri,  7 Jul 2017 19:56:09 +0800
Message-ID: <1499428569-1608-1-git-send-email-jasowang@redhat.com>
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes: commit d45b897b11ea ("virtio_net: allow specifying context for rx")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2e69bcd..99a26a9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2229,6 +2229,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 	kfree(names);
 	kfree(callbacks);
 	kfree(vqs);
+	kfree(ctx);
 
 	return 0;
 
-- 
2.7.4
