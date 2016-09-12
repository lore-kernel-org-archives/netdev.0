From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 04/15] bnx2: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:35 -0400
Message-ID: <1473689026-6983-5-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Dept-HSGLinuxNICDev@qlogic.com,
        Sony Chacko <sony.chacko@qlogic.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/broadcom/bnx2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 8fc3f3c137f8..ecd357dbb1d4 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -50,7 +50,7 @@
 #include <linux/log2.h>
 #include <linux/aer.h>
 
-#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
+#if IS_ENABLED(CONFIG_CNIC)
 #define BCM_CNIC 1
 #include "cnic_if.h"
 #endif
-- 
2.7.4
