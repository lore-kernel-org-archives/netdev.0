From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v6 36/46] vhost/net: suppress compiler warning
Date: Thu, 27 Nov 2014 22:10:49 +0200
Message-ID: <1417118789-18231-37-git-send-email-mst@redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1417118789-18231-1-git-send-email-mst@redhat.com>
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

len is always initialized since function is called with size > 0.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 984242e..54ffbb0 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -501,7 +501,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 	int headcount = 0;
 	unsigned d;
 	int r, nlogs = 0;
-	u32 len;
+	u32 uninitialized_var(len);
 
 	while (datalen > 0 && headcount < quota) {
 		if (unlikely(seg >= UIO_MAXIOV)) {
-- 
MST
