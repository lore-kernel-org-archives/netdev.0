From: Asias He <asias@redhat.com>
Subject: [PATCH v2] vhost: Include linux/uio.h instead of linux/socket.h
Date: Mon, 19 Aug 2013 09:23:19 +0800
Message-ID: <1376875399-21945-1-git-send-email-asias@redhat.com>
References: <20130816.222946.421410239742571372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130816.222946.421410239742571372.davem@davemloft.net>
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

memcpy_fromiovec is moved from net/core/iovec.c to lib/iovec.c.
linux/uio.h provides the declaration for memcpy_fromiovec.

Include linux/uio.h instead of inux/socket.h for it.

Signed-off-by: Asias He <asias@redhat.com>
---
 drivers/vhost/vhost.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e58cf00..448efe0 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -13,7 +13,7 @@
 
 #include <linux/eventfd.h>
 #include <linux/vhost.h>
-#include <linux/socket.h> /* memcpy_fromiovec */
+#include <linux/uio.h>
 #include <linux/mm.h>
 #include <linux/mmu_context.h>
 #include <linux/miscdevice.h>
-- 
1.8.3.1
