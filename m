From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] drivers/net/wireless/tiacx/: add missing #include <linux/vmalloc.h>'a
Date: Fri, 11 Nov 2005 21:07:35 +0100
Message-ID: <20051111200735.GO5376@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751132AbVKKUHk@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is required for always getting the vmalloc()/vfree() prototypes.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/wireless/tiacx/common.c |    1 +
 drivers/net/wireless/tiacx/pci.c    |    1 +
 drivers/net/wireless/tiacx/usb.c    |    1 +
 3 files changed, 3 insertions(+)

--- linux-2.6.14-mm2-full/drivers/net/wireless/tiacx/common.c.old	2005-11-11 20:51:52.000000000 +0100
+++ linux-2.6.14-mm2-full/drivers/net/wireless/tiacx/common.c	2005-11-11 20:52:07.000000000 +0100
@@ -45,6 +45,7 @@
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
 #include <linux/pm.h>
+#include <linux/vmalloc.h>
 #if WIRELESS_EXT >= 13
 #include <net/iw_handler.h>
 #endif /* WE >= 13 */
--- linux-2.6.14-mm2-full/drivers/net/wireless/tiacx/pci.c.old	2005-11-11 21:04:38.000000000 +0100
+++ linux-2.6.14-mm2-full/drivers/net/wireless/tiacx/pci.c	2005-11-11 21:05:09.000000000 +0100
@@ -52,6 +52,7 @@
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <linux/pm.h>
+#include <linux/vmalloc.h>
 
 #include "acx.h"
 
--- linux-2.6.14-mm2-full/drivers/net/wireless/tiacx/usb.c.old	2005-11-11 21:06:13.000000000 +0100
+++ linux-2.6.14-mm2-full/drivers/net/wireless/tiacx/usb.c	2005-11-11 21:06:31.000000000 +0100
@@ -64,6 +64,7 @@
 #if WIRELESS_EXT >= 13
 #include <net/iw_handler.h>
 #endif
+#include <linux/vmalloc.h>
 
 #include "acx.h"
 
