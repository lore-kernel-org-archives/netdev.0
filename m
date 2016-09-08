From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] vhost: mark vhost_process_iotlb_msg() static
Date: Thu,  8 Sep 2016 16:56:45 +0800
Message-ID: <1473325005-9423-1-git-send-email-baoyou.xie@linaro.org>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/vhost/vhost.c:937:5: warning: no previous prototype for 'vhost_process_iotlb_msg' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/vhost/vhost.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c6f2d89..bf045ac 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -934,8 +934,8 @@ static int umem_access_ok(u64 uaddr, u64 size, int access)
 	return 0;
 }
 
-int vhost_process_iotlb_msg(struct vhost_dev *dev,
-			    struct vhost_iotlb_msg *msg)
+static int vhost_process_iotlb_msg(struct vhost_dev *dev,
+				   struct vhost_iotlb_msg *msg)
 {
 	int ret = 0;
 
-- 
2.7.4
