From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 06/12] net: use linux/of_{device,platform}.h instead of asm
Date: Thu, 3 Jul 2008 11:28:35 +1000
Message-ID: <20080703112835.c082177b.sfr@canb.auug.org.au>
References: <20080523161627.a75d5010.sfr@canb.auug.org.au>
	<20080523162854.2e6ea8f0.sfr@canb.auug.org.au>
	<4864737D.80306@garzik.org>
	<C87095E8-991D-4730-8C5A-B132A3157727@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <C87095E8-991D-4730-8C5A-B132A3157727@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi Kumar,

On Wed, 2 Jul 2008 02:55:29 -0500 Kumar Gala <galak@kernel.crashing.org> wrote:
>
> I'll pick it up (since it mainly touches fsl enet controllers) if you  
> can repost it.  I seem to have lost the patch.

Here you go.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

Date: Fri, 23 May 2008 16:28:54 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Jeff Garzik <jeff@garzik.org>
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
Subject: [PATCH 06/12] net: use linux/of_{device,platform}.h instead of asm

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/fs_enet/fs_enet-main.c |    2 +-
 drivers/net/fs_enet/mac-scc.c      |    2 +-
 drivers/net/fs_enet/mii-fec.c      |    2 +-
 drivers/net/ibm_newemac/core.h     |    2 +-
 drivers/net/ucc_geth.c             |    2 +-
 drivers/net/ucc_geth_mii.c         |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 67b4b07..1231048 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -43,7 +43,7 @@
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_platform.h>
+#include <linux/of_platform.h>
 #endif
 
 #include "fs_enet.h"
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index d7ca319..e3557ec 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -44,7 +44,7 @@
 #endif
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_platform.h>
+#include <linux/of_platform.h>
 #endif
 
 #include "fs_enet.h"
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index f0014cf..8f6a43b 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -37,7 +37,7 @@
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_platform.h>
+#include <linux/of_platform.h>
 #endif
 
 #include "fs_enet.h"
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 1683db9..2230904 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -33,8 +33,8 @@
 #include <linux/netdevice.h>
 #include <linux/dma-mapping.h>
 #include <linux/spinlock.h>
+#include <linux/of_platform.h>
 
-#include <asm/of_platform.h>
 #include <asm/io.h>
 #include <asm/dcr.h>
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index ca0bdac..1fb504c 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -28,8 +28,8 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/workqueue.h>
+#include <linux/of_platform.h>
 
-#include <asm/of_platform.h>
 #include <asm/uaccess.h>
 #include <asm/irq.h>
 #include <asm/io.h>
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 9404747..6d9e7ad 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -36,8 +36,8 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/fsl_devices.h>
+#include <linux/of_platform.h>
 
-#include <asm/of_platform.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
-- 
1.5.5.1
