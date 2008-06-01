From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 13/13]bnx2x: add BCM57711 and new features
Date: Sun, 01 Jun 2008 11:13:22 -0400
Message-ID: <1212333202.6967.132.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eliezer Tamir" <eliezert@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2506 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138AbYFAPNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jun 2008 11:13:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to thank Eliezer Tamir again for his two years of bringing
up the bnx2x and maintaining it up until now. From this point, I will
take the bnx2x maintenance

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 MAINTAINERS              |    4 ++--
 drivers/net/bnx2x.h      |    3 ++-
 drivers/net/bnx2x_init.h |    3 ++-
 drivers/net/bnx2x_main.c |    5 +++--
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index bc1c008..7738f31 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1002,8 +1002,8 @@ L:	netdev@vger.kernel.org
 S:	Supported
 
 BROADCOM BNX2X 10 GIGABIT ETHERNET DRIVER
-P:	Eliezer Tamir
-M:	eliezert@broadcom.com
+P:	Eilon Greenstein
+M:	eilong@broadcom.com
 L:	netdev@vger.kernel.org
 S:	Supported
 
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4e3e18d..8433ebe 100755
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  */
 
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index a01fd8a..42713ff 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  */
 
 #ifndef BNX2X_INIT_H
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f093174..03294a7 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
  * Slowpath rework by Vladislav Zolotarov
@@ -76,7 +77,7 @@ static char version[] __devinitdata =
 	"Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
-MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
+MODULE_AUTHOR("Eliezer Tamir");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
-- 
1.5.5




