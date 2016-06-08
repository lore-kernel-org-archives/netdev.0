From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/6] virtio_net: add _UAPI prefix to virtio_net header guards
Date: Wed,  8 Jun 2016 16:09:17 +0300
Message-ID: <1465391362-18437-2-git-send-email-rppt@linux.vnet.ibm.com>
References: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
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

This gives better namespacing and prevents conflicts with no-uapi version
of virtio_net header that will be introduced in the following patch.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/uapi/linux/virtio_net.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index ec32293..75cf581 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -1,5 +1,5 @@
-#ifndef _LINUX_VIRTIO_NET_H
-#define _LINUX_VIRTIO_NET_H
+#ifndef _UAPI_LINUX_VIRTIO_NET_H
+#define _UAPI_LINUX_VIRTIO_NET_H
 /* This header is BSD licensed so anyone can use the definitions to implement
  * compatible drivers/servers.
  *
@@ -242,4 +242,4 @@ struct virtio_net_ctrl_mq {
 #define VIRTIO_NET_CTRL_GUEST_OFFLOADS   5
 #define VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET        0
 
-#endif /* _LINUX_VIRTIO_NET_H */
+#endif /* _UAPI_LINUX_VIRTIO_NET_H */
-- 
1.9.1
