From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] w90p910_ether: include linux/interrupt.h
Date: Tue, 12 Sep 2017 14:31:48 +0200
Message-ID: <20170912123227.3418786-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
 linux-kernel@vger.kernel.org
To: Wan ZongShun <mcuos.com@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

A randconfig build caused a compile failure:

drivers/net/ethernet/nuvoton/w90p910_ether.c: In function 'w90p910_ether_close':
drivers/net/ethernet/nuvoton/w90p910_ether.c:580:2: error: implicit declaration of function 'free_irq'; did you mean 'free_uid'? [-Werror=implicit-function-declaration]

Adding the correct include fixes the problem.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/nuvoton/w90p910_ether.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 89ab786da25f..4a67c55aa9f1 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -11,6 +11,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/mii.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-- 
2.9.0
