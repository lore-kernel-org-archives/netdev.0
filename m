From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/25) sk98: remove unneeded include's
Date: Mon, 15 Nov 2004 15:23:23 -0800
Message-ID: <20041115152323.08f670b3@zqx3.pdx.osdl.net>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove extraneous header includes

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:23:03 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:23:03 -08:00
@@ -39,9 +39,6 @@
 #ifndef __INC_SKDRV1ST_H
 #define __INC_SKDRV1ST_H
 
-/* Check kernel version */
-#include <linux/version.h>
-
 typedef struct s_AC	SK_AC;
 
 /* Set card versions */
@@ -62,8 +59,6 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
-#include <linux/ioport.h>
-#include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/bitops.h>
@@ -75,7 +70,7 @@
 
 #include <linux/init.h>
 #include <asm/uaccess.h>
-#include <net/checksum.h>
+
 
 #define SK_CS_CALCULATE_CHECKSUM
 #ifndef CONFIG_X86_64
