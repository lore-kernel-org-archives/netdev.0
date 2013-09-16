From: Avinash Kumar <avi.kp.137@gmail.com>
Subject: [PATCH 4/4] drivers: net: phy: cicada.c: clears warning Use #include <linux/io.h> instead of <asm/io.h>
Date: Mon, 16 Sep 2013 21:39:41 +0530
Message-ID: <1379347781-7145-1-git-send-email-avi.kp.137@gmail.com>
Cc: linux-kernel@vger.kernel.org, Avinash Kumar <avi.kp.137@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

clears following warnings :
WARNING: Use include <linux/io.h> instead of <asm/io.h>
WARNING: Use include <linux/uaccess.h> instead of <asm/uaccess.h>

Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>
---
 drivers/net/phy/cicada.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index db472ff..313a037 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -30,9 +30,9 @@
 #include <linux/ethtool.h>
 #include <linux/phy.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 /* Cicada Extended Control Register 1 */
 #define MII_CIS8201_EXT_CON1           0x17
-- 
1.7.10.4
