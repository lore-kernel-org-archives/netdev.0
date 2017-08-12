From: Colin King <colin.king@canonical.com>
Subject: [PATCH] virtio-net: make array guest_offloads static
Date: Sat, 12 Aug 2017 22:45:53 +0100
Message-ID: <20170812214553.6073-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S . Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
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

From: Colin Ian King <colin.king@canonical.com>

The array guest_offloads is local to the source and does not need to
be in global scope, so make it static. Also tweak formatting.

Cleans up sparse warnings:
symbol 'guest_offloads' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/virtio_net.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e90de2186ffc..a3f3c66b4530 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -57,10 +57,12 @@ DECLARE_EWMA(pkt_len, 0, 64)
 
 #define VIRTNET_DRIVER_VERSION "1.0.0"
 
-const unsigned long guest_offloads[] = { VIRTIO_NET_F_GUEST_TSO4,
-					 VIRTIO_NET_F_GUEST_TSO6,
-					 VIRTIO_NET_F_GUEST_ECN,
-					 VIRTIO_NET_F_GUEST_UFO };
+static const unsigned long guest_offloads[] = {
+	VIRTIO_NET_F_GUEST_TSO4,
+	VIRTIO_NET_F_GUEST_TSO6,
+	VIRTIO_NET_F_GUEST_ECN,
+	VIRTIO_NET_F_GUEST_UFO
+};
 
 struct virtnet_stats {
 	struct u64_stats_sync tx_syncp;
-- 
2.11.0
