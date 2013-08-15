From: Asias He <asias@redhat.com>
Subject: [PATCH] vhost: Drop linux/socket.h
Date: Thu, 15 Aug 2013 11:20:16 +0800
Message-ID: <1376536816-10951-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
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

memcpy_fromiovec is moved to lib/iovec.c. No need to include
linux/socket.h for it.

Signed-off-by: Asias He <asias@redhat.com>
---
 drivers/vhost/vhost.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e58cf00..038c242 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -13,7 +13,6 @@
 
 #include <linux/eventfd.h>
 #include <linux/vhost.h>
-#include <linux/socket.h> /* memcpy_fromiovec */
 #include <linux/mm.h>
 #include <linux/mmu_context.h>
 #include <linux/miscdevice.h>
-- 
1.8.3.1
