From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] vhost: remove unnecessary forward declarations in
	vhost.h
Date: Thu, 27 Nov 2014 14:41:21 +0800
Message-ID: <1417070481-10331-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 3eda654..7d039ef 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -12,8 +12,6 @@
 #include <linux/virtio_ring.h>
 #include <linux/atomic.h>
 
-struct vhost_device;
-
 struct vhost_work;
 typedef void (*vhost_work_fn_t)(struct vhost_work *work);
 
@@ -54,8 +52,6 @@ struct vhost_log {
 	u64 len;
 };
 
-struct vhost_virtqueue;
-
 /* The virtqueue structure describes a queue attached to a device. */
 struct vhost_virtqueue {
 	struct vhost_dev *dev;
-- 
1.9.1
