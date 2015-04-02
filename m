From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 02/12] net: dsa: mv88e6xxx: Move switch product IDs into common include file
Date: Thu,  2 Apr 2015 03:21:49 +0200
Message-ID: <1427937719-11630-3-git-send-email-andrew@lunn.ch>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35728 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751863AbbDBB0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:26:05 -0400
In-Reply-To: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

This will let us use the switch product IDs in the common source code.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6131.c |  6 ------
 drivers/net/dsa/mv88e6171.c |  4 ----
 drivers/net/dsa/mv88e6xxx.h | 36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 0252d51c0a74..f0dea2d1581e 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -17,12 +17,6 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-/* Switch product IDs */
-#define ID_6085		0x04a0
-#define ID_6095		0x0950
-#define ID_6131		0x1060
-#define ID_6131_B2	0x1066
-
 static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 {
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 18cfead83dc9..639bd83b76c7 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -17,10 +17,6 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-/* Switch product IDs */
-#define ID_6171	0x1710
-#define ID_6172	0x1720
-
 static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 {
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index aaf239aba726..aca48792db4b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -11,6 +11,42 @@
 #ifndef __MV88E6XXX_H
 #define __MV88E6XXX_H
 
+/* switch product IDs */
+
+#define ID_6085		0x04a0
+#define ID_6095		0x0950
+
+#define ID_6123		0x1210
+#define ID_6123_A1	0x1212
+#define ID_6123_A2	0x1213
+
+#define ID_6131		0x1060
+#define ID_6131_B2	0x1066
+
+#define ID_6152		0x1a40
+#define ID_6155		0x1a50
+
+#define ID_6161		0x1610
+#define ID_6161_A1	0x1612
+#define ID_6161_A2	0x1613
+
+#define ID_6165		0x1650
+#define ID_6165_A1	0x1652
+#define ID_6165_A2	0x1653
+
+#define ID_6171		0x1710
+#define ID_6172		0x1720
+#define ID_6176		0x1760
+
+#define ID_6182		0x1a60
+#define ID_6185		0x1a70
+
+#define ID_6352		0x3520
+#define ID_6352_A0	0x3521
+#define ID_6352_A1	0x3522
+
+/* Registers */
+
 #define REG_PORT(p)		(0x10 + (p))
 #define REG_GLOBAL		0x1b
 #define REG_GLOBAL2		0x1c
-- 
2.1.4
