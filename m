From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] r6040: remove unused includes
Date: Fri, 22 Aug 2008 10:20:50 +0200
Message-ID: <200808221020.50874.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:52088 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbYHVIVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 04:21:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes all unused includes we have in the r6040 driver.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 6531ff5..d453987 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -24,13 +24,9 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
-#include <linux/moduleparam.h>
-#include <linux/string.h>
 #include <linux/timer.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
-#include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
@@ -45,9 +41,6 @@
 #include <linux/bitops.h>
 #include <linux/io.h>
 #include <linux/irq.h>
-#include <linux/uaccess.h>
-
-#include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
 #define DRV_VERSION	"0.18"
