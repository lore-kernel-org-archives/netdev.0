From: Andy King <acking@vmware.com>
Subject: [PATCH 1/4] VSOCK: get rid of EXPORT_SYMTAB
Date: Mon, 18 Feb 2013 08:04:10 -0800
Message-ID: <1361203453-1347-2-git-send-email-acking@vmware.com>
References: <1361203453-1347-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Dmitry Torokhov <dtor@vmware.com>,
	davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1361203453-1347-1-git-send-email-acking@vmware.com>
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

From: Dmitry Torokhov <dtor@vmware.com>

This is the default behavior for a looooooong time.

Acked-by: Andy King <acking@vmware.com>
Signed-off-by: Dmitry Torokhov <dtor@vmware.com>
---
 net/vmw_vsock/af_vsock.c       |    2 --
 net/vmw_vsock/vmci_transport.c |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 54bb7bd..a8efe5a 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -76,8 +76,6 @@
  */
 
 #include <linux/types.h>
-
-#define EXPORT_SYMTAB
 #include <linux/bitops.h>
 #include <linux/cred.h>
 #include <linux/init.h>
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index e8a87cf..a70ace8 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -14,8 +14,6 @@
  */
 
 #include <linux/types.h>
-
-#define EXPORT_SYMTAB
 #include <linux/bitops.h>
 #include <linux/cred.h>
 #include <linux/init.h>
-- 
1.7.4.1
