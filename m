From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 2/6] isdn/hardware/eicon: add missing header dependencies
Date: Sat, 24 Sep 2016 13:18:12 +0800
Message-ID: <1474694292-1142-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: mac@melware.de, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/isdn/hardware/eicon/diva.c:655:6: warning: no previous prototype for 'xdiFreeFile' [-Wmissing-prototypes]

In fact, this function is declared in
drivers/isdn/hardware/eicon/helpers.h,
so this patch adds missing header dependencies.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hardware/eicon/diva.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/isdn/hardware/eicon/diva.c b/drivers/isdn/hardware/eicon/diva.c
index 9693add..ad32552 100644
--- a/drivers/isdn/hardware/eicon/diva.c
+++ b/drivers/isdn/hardware/eicon/diva.c
@@ -17,6 +17,7 @@
 #include "xdi_adapter.h"
 #include "diva_pci.h"
 #include "diva.h"
+#include "helpers.h"
 
 #ifdef CONFIG_ISDN_DIVAS_PRIPCI
 #include "os_pri.h"
-- 
2.7.4
