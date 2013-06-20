From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost-net: make more functions static
Date: Thu, 20 Jun 2013 14:55:19 +0300
Message-ID: <20130620115519.GA5301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

Make two more functions static - they only have local callers.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Will be merged through the vhost tree - no need to apply
directly.

 drivers/vhost/net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 534adb0..4c5de87 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -167,7 +167,7 @@ static void vhost_net_clear_ubuf_info(struct vhost_net *n)
 	}
 }
 
-int vhost_net_set_ubuf_info(struct vhost_net *n)
+static int vhost_net_set_ubuf_info(struct vhost_net *n)
 {
 	bool zcopy;
 	int i;
@@ -188,7 +188,7 @@ err:
 	return -ENOMEM;
 }
 
-void vhost_net_vq_reset(struct vhost_net *n)
+static void vhost_net_vq_reset(struct vhost_net *n)
 {
 	int i;
 
-- 
MST
