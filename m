From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 06/33] arcnet: Use include/linux path for asm
Date: Tue, 22 Sep 2015 11:01:47 +0200
Message-ID: <1442912534-10821-7-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54047 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use the preferred kernel include path for asm paths.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rimi.c     | 2 +-
 drivers/net/arcnet/com20020-isa.c | 2 +-
 drivers/net/arcnet/com20020-pci.c | 2 +-
 drivers/net/arcnet/com20020.c     | 2 +-
 drivers/net/arcnet/com20020_cs.c  | 2 +-
 drivers/net/arcnet/com90io.c      | 2 +-
 drivers/net/arcnet/com90xx.c      | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 6eedd6b..88e6157 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -33,7 +33,7 @@
 #include <linux/bootmem.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <linux/arcdevice.h>
 
 #define VERSION "arcnet: RIM I (entirely mem-mapped) support\n"
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index b8129360..d829e60 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -39,7 +39,7 @@
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 
 #define VERSION "arcnet: COM20020 ISA support (by David Woodhouse et al.)\n"
 
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 06621e9..72334b5 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -40,7 +40,7 @@
 #include <linux/com20020.h>
 #include <linux/list.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 
 #define VERSION "arcnet: COM20020 PCI support\n"
 
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 48a45d3..bdf883f 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -37,7 +37,7 @@
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 
 #define VERSION "arcnet: COM20020 chipset support (by David Woodhouse et al.)\n"
 
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 532410b..437b456 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -45,7 +45,7 @@
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 
 #define VERSION "arcnet: COM20020 PCMCIA support loaded.\n"
 
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 1742fa7..3233346 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -34,7 +34,7 @@
 #include <linux/bootmem.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <linux/arcdevice.h>
 
 #define VERSION "arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)\n"
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 2e29084..0b7bc86 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -32,7 +32,7 @@
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/slab.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <linux/arcdevice.h>
 
 #define VERSION "arcnet: COM90xx chipset support\n"
-- 
2.5.1
