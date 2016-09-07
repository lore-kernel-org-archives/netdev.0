From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] qed: add missing header dependencies
Date: Wed,  7 Sep 2016 19:07:00 +0800
Message-ID: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 4 warnings when building kernel with W=1:
drivers/net/ethernet/qlogic/qed/qed_selftest.c:6:5: warning: no previous prototype for 'qed_selftest_memory' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_selftest.c:19:5: warning: no previous prototype for 'qed_selftest_interrupt' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_selftest.c:32:5: warning: no previous prototype for 'qed_selftest_register' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_selftest.c:55:5: warning: no previous prototype for 'qed_selftest_clock' [-Wmissing-prototypes]

In fact, these functions are declared in qed_selftest.h, so this patch
add missing header dependencies.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/qlogic/qed/qed_selftest.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_selftest.c b/drivers/net/ethernet/qlogic/qed/qed_selftest.c
index a342bfe..9b7678f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_selftest.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_selftest.c
@@ -2,6 +2,7 @@
 #include "qed_dev_api.h"
 #include "qed_mcp.h"
 #include "qed_sp.h"
+#include "qed_selftest.h"
 
 int qed_selftest_memory(struct qed_dev *cdev)
 {
-- 
2.7.4
