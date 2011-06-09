From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH] net: emaclite: Add missing linux/interrupt.h header
Date: Thu,  9 Jun 2011 10:15:33 +0200
Message-ID: <1307607333-24612-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michal Simek <monstr@monstr.eu>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Log:
drivers/net/xilinx_emaclite.c: In function 'xemaclite_open':
drivers/net/xilinx_emaclite.c:961: error: implicit declaration of function 'request_irq'
drivers/net/xilinx_emaclite.c: In function 'xemaclite_close':
drivers/net/xilinx_emaclite.c:995: error: implicit declaration of function 'free_irq'
make[2]: *** [drivers/net/xilinx_emaclite.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

Signed-off-by: Michal Simek <monstr@monstr.eu>
---
 drivers/net/xilinx_emaclite.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 372572c..9cb4cdc 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -26,6 +26,7 @@
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
 #include <linux/phy.h>
+#include <linux/interrupt.h>
 
 #define DRIVER_NAME "xilinx_emaclite"
 
-- 
1.5.5.6
