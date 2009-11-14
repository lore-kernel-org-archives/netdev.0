From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [net-next 2/2] iwmc3200top: simplify the driver version
Date: Sat, 14 Nov 2009 20:36:36 +0200
Message-ID: <1258223796-8486-2-git-send-email-tomas.winkler@intel.com>
References: <1258223796-8486-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com,
	Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1258223796-8486-1-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drop the version parts not needed for in-tree driver

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/misc/iwmc3200top/main.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/misc/iwmc3200top/main.c b/drivers/misc/iwmc3200top/main.c
index a1ce97e..02b3dad 100644
--- a/drivers/misc/iwmc3200top/main.c
+++ b/drivers/misc/iwmc3200top/main.c
@@ -41,21 +41,7 @@
 #define DRIVER_DESCRIPTION "Intel(R) IWMC 3200 Top Driver"
 #define DRIVER_COPYRIGHT "Copyright (c) 2008 Intel Corporation."
 
-#define IWMCT_VERSION "0.1.62"
-
-#ifdef REPOSITORY_LABEL
-#define RL REPOSITORY_LABEL
-#else
-#define RL local
-#endif
-
-#ifdef CONFIG_IWMC3200TOP_DEBUG
-#define VD "-d"
-#else
-#define VD
-#endif
-
-#define DRIVER_VERSION IWMCT_VERSION "-"  __stringify(RL) VD
+#define DRIVER_VERSION  "0.1.62"
 
 MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
 MODULE_VERSION(DRIVER_VERSION);
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

