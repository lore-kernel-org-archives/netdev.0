From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/ne.c: fix warning with -Wundef
Date: Fri, 22 Jul 2005 23:42:23 +0200
Message-ID: <20050722214223.GW3160@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262201AbVGVVpO@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following warning with -Wundef:

<--  snip  -->

...
  CC      drivers/net/ne.o
drivers/net/ne.c:134:7: warning: "CONFIG_PLAT_OAKS32R" is not defined
...

<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc3-mm1-full/drivers/net/ne.c.old	2005-07-22 18:24:32.000000000 +0200
+++ linux-2.6.13-rc3-mm1-full/drivers/net/ne.c	2005-07-22 18:24:50.000000000 +0200
@@ -131,7 +131,7 @@
 
 #ifdef CONFIG_PLAT_MAPPI
 #  define DCR_VAL 0x4b
-#elif CONFIG_PLAT_OAKS32R
+#elif defined(CONFIG_PLAT_OAKS32R)
 #  define DCR_VAL 0x48
 #else
 #  define DCR_VAL 0x49
