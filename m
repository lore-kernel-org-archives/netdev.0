From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 1/4] net: mvneta: sort the headers in alphabetic order
Date: Wed, 20 Jan 2016 16:06:20 +0800
Message-ID: <1453277183-5412-2-git-send-email-jszhang@marvell.com>
References: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, devicetree@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
 <mw@semihalf.com>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Sorting the headers in alphabetic order will help to reduce the conflict
when adding new headers in the future.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index fabc8df..79e0c7d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -11,28 +11,28 @@
  * warranty of any kind, whether express or implied.
  */
 
-#include <linux/kernel.h>
-#include <linux/netdevice.h>
+#include <linux/clk.h>
+#include <linux/cpu.h>
 #include <linux/etherdevice.h>
-#include <linux/platform_device.h>
-#include <linux/skbuff.h>
-#include <linux/inetdevice.h>
+#include <linux/kernel.h>
 #include <linux/mbus.h>
 #include <linux/module.h>
-#include <linux/interrupt.h>
+#include <linux/netdevice.h>
 #include <linux/if_vlan.h>
-#include <net/ip.h>
-#include <net/ipv6.h>
+#include <linux/inetdevice.h>
+#include <linux/interrupt.h>
 #include <linux/io.h>
-#include <net/tso.h>
 #include <linux/of.h>
+#include <linux/of_address.h>
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
-#include <linux/of_address.h>
 #include <linux/phy.h>
-#include <linux/clk.h>
-#include <linux/cpu.h>
+#include <linux/platform_device.h>
+#include <linux/skbuff.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/tso.h>
 
 /* Registers */
 #define MVNETA_RXQ_CONFIG_REG(q)                (0x1400 + ((q) << 2))
-- 
2.7.0.rc3
