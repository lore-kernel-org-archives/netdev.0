From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 37/41]bnx2x: Moving includes
Date: Thu, 12 Feb 2009 20:38:25 +0200
Message-ID: <1234463905.1863.169.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755690AbZBLSix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 37/41]bnx2x: Moving includes

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    6 ++++++
 drivers/net/bnx2x_link.c |    4 ----
 drivers/net/bnx2x_main.c |    5 +----
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index bec5aff..5eb35a6 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -29,6 +29,12 @@
 
 #define BNX2X_NEW_NAPI
 
+
+#include "bnx2x_reg.h"
+#include "bnx2x_fw_defs.h"
+#include "bnx2x_hsi.h"
+#include "bnx2x_link.h"
+
 /* error/debug prints */
 
 #define DRV_MODULE_NAME		"bnx2x"
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 39db995..5a17c7c 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -22,10 +22,6 @@
 #include <linux/ethtool.h>
 #include <linux/mutex.h>
 
-#include "bnx2x_reg.h"
-#include "bnx2x_fw_defs.h"
-#include "bnx2x_hsi.h"
-#include "bnx2x_link.h"
 #include "bnx2x.h"
 
 /********************************************************/
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 78f628a..3f84027 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -50,10 +50,7 @@
 #include <linux/zlib.h>
 #include <linux/io.h>
 
-#include "bnx2x_reg.h"
-#include "bnx2x_fw_defs.h"
-#include "bnx2x_hsi.h"
-#include "bnx2x_link.h"
+
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-- 
1.5.4.3




