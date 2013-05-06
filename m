From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: drop virtio_net.h dependency
Date: Mon, 6 May 2013 13:37:34 +0300
Message-ID: <20130506103734.GA12481@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
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

There's no net specific code in vhost.c anymore,
don't include the virtio_net.h header.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This is on top of Asias' patches, already queued so
just FYI.

 drivers/vhost/vhost.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index de9441a..dcde269 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -13,7 +13,6 @@
 
 #include <linux/eventfd.h>
 #include <linux/vhost.h>
-#include <linux/virtio_net.h>
 #include <linux/mm.h>
 #include <linux/mmu_context.h>
 #include <linux/miscdevice.h>
-- 
MST
