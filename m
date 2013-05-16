From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH 2/5] net: davinci_emac: remove unwanted header inclusion and sort the alphabetically
Date: Thu, 16 May 2013 13:00:35 +0530
Message-ID: <1368689438-23889-3-git-send-email-prabhakar.csengg@gmail.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad, Prabhakar <prabhakar.csengg@gmail.com>

This patch removes unwanted header inclusion and sorts them alphabetically

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   42 +++++++-------------------------
 1 files changed, 9 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 860e15d..609f6d1 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -29,43 +29,19 @@
  *     PHY layer usage
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/errno.h>
-#include <linux/in.h>
-#include <linux/ioport.h>
-#include <linux/slab.h>
-#include <linux/mm.h>
+#include <linux/clk.h>
+#include <linux/davinci_emac.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/io.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/ethtool.h>
-#include <linux/highmem.h>
-#include <linux/proc_fs.h>
-#include <linux/ctype.h>
-#include <linux/spinlock.h>
-#include <linux/dma-mapping.h>
-#include <linux/clk.h>
-#include <linux/platform_device.h>
-#include <linux/semaphore.h>
+#include <linux/of_net.h>
 #include <linux/phy.h>
-#include <linux/bitops.h>
-#include <linux/io.h>
-#include <linux/uaccess.h>
+#include <linux/platform_device.h>
 #include <linux/pm_runtime.h>
-#include <linux/davinci_emac.h>
-#include <linux/of.h>
-#include <linux/of_address.h>
-#include <linux/of_irq.h>
-#include <linux/of_net.h>
-
-#include <asm/irq.h>
-#include <asm/page.h>
 
 #include "davinci_cpdma.h"
 
-- 
1.7.4.1
