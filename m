From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v5 35/45] vhost/net: suppress compiler warning
Date: Thu, 27 Nov 2014 14:32:58 +0200
Message-ID: <1417091078-24611-36-git-send-email-mst@redhat.com>
References: <1417091078-24611-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417091078-24611-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
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
