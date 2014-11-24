From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 27/41] vhost: make features 64 bit
Date: Mon, 24 Nov 2014 13:54:32 +0200
Message-ID: <1416829787-14252-28-git-send-email-mst@redhat.com>
References: <1416829787-14252-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, rusty@au1.ibm.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1416829787-14252-1-git-send-email-mst@redhat.com>
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

We need to use bit 32 for virtio 1.0

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b9032e8..1f321fd 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -106,7 +106,7 @@ struct vhost_virtqueue {
 	/* Protected by virtqueue mutex. */
 	struct vhost_memory *memory;
 	void *private_data;
-	unsigned acked_features;
+	u64 acked_features;
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
-- 
MST
