From: Aaron Conole <aconole@redhat.com>
Subject: [PATCH -next 1/2] virtio: Start feature MTU support
Date: Thu,  2 Jun 2016 11:43:30 -0400
Message-ID: <1464882211-18723-2-git-send-email-aconole@redhat.com>
References: <1464882211-18723-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1464882211-18723-1-git-send-email-aconole@redhat.com>
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

This commit adds the feature bit and associated mtu device entry for the
virtio network device. Future commits will make use of these bits to
support negotiated MTU.

Signed-off-by: Aaron Conole <aconole@redhat.com>
---
 include/uapi/linux/virtio_net.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index ec32293..751ff59 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -73,6 +73,8 @@ struct virtio_net_config {
 	 * Legal values are between 1 and 0x8000
 	 */
 	__u16 max_virtqueue_pairs;
+	/* Default maximum transmit unit advice */
+	__u16 mtu;
 } __attribute__((packed));
 
 /*
-- 
2.5.5
