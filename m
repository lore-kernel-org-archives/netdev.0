From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove (or add) unneeded includes
 (drivers/net/wan)
Date: Wed, 17 Sep 2003 15:23:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917152323.3c77de29.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks,
--
~Randy


From: Randy Hron <rwhron@earthlink.net>

 linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-comx.c    |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-locomx.c  |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-mixcom.c  |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-munich.c  |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/comx-proto-fr.c   |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/comx-proto-lapb.c |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/comx-proto-ppp.c  |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/comx.c            |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/cycx_x25.c        |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/dlci.c            |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/dscc4.c           |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/lmc/lmc_ver.h     |    2 ++
 linux-260-test5-kj-rddunlap/drivers/net/wan/pc300_drv.c       |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/pc300_tty.c       |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_chdlc.c      |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_fr.c         |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_ft1.c        |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_ppp.c        |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_x25.c        |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/sdladrv.c         |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/sdlamain.c        |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wan/wanpipe_multppp.c |    1 -
 22 files changed, 2 insertions(+), 21 deletions(-)

diff -puN drivers/net/wan/comx.c~drivers_net_wan drivers/net/wan/comx.c
--- linux-260-test5-kj/drivers/net/wan/comx.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx.c	2003-09-11 10:40:53.000000000 -0700
@@ -55,7 +55,6 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 
 #include <linux/types.h>
 #include <linux/jiffies.h>
diff -puN drivers/net/wan/comx-hw-comx.c~drivers_net_wan drivers/net/wan/comx-hw-comx.c
--- linux-260-test5-kj/drivers/net/wan/comx-hw-comx.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-comx.c	2003-09-11 10:40:53.000000000 -0700
@@ -51,7 +51,6 @@
 #define VERSION "0.87"
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
diff -puN drivers/net/wan/comx-hw-locomx.c~drivers_net_wan drivers/net/wan/comx-hw-locomx.c
--- linux-260-test5-kj/drivers/net/wan/comx-hw-locomx.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-locomx.c	2003-09-11 10:40:53.000000000 -0700
@@ -38,7 +38,6 @@
 
 #include <linux/interrupt.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
diff -puN drivers/net/wan/comx-hw-mixcom.c~drivers_net_wan drivers/net/wan/comx-hw-mixcom.c
--- linux-260-test5-kj/drivers/net/wan/comx-hw-mixcom.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-mixcom.c	2003-09-11 10:40:53.000000000 -0700
@@ -41,7 +41,6 @@
 
 #include <linux/interrupt.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
diff -puN drivers/net/wan/comx-hw-munich.c~drivers_net_wan drivers/net/wan/comx-hw-munich.c
--- linux-260-test5-kj/drivers/net/wan/comx-hw-munich.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx-hw-munich.c	2003-09-11 10:40:53.000000000 -0700
@@ -30,7 +30,6 @@
 #include <linux/config.h>
 #include <linux/ctype.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
diff -puN drivers/net/wan/comx-proto-fr.c~drivers_net_wan drivers/net/wan/comx-proto-fr.c
--- linux-260-test5-kj/drivers/net/wan/comx-proto-fr.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx-proto-fr.c	2003-09-11 10:40:53.000000000 -0700
@@ -37,7 +37,6 @@
 #define VERSION "0.73"
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/jiffies.h>
 #include <linux/netdevice.h>
diff -puN drivers/net/wan/comx-proto-lapb.c~drivers_net_wan drivers/net/wan/comx-proto-lapb.c
--- linux-260-test5-kj/drivers/net/wan/comx-proto-lapb.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx-proto-lapb.c	2003-09-11 10:40:53.000000000 -0700
@@ -24,7 +24,6 @@
 #define VERSION "0.80"
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
diff -puN drivers/net/wan/comx-proto-ppp.c~drivers_net_wan drivers/net/wan/comx-proto-ppp.c
--- linux-260-test5-kj/drivers/net/wan/comx-proto-ppp.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/comx-proto-ppp.c	2003-09-11 10:40:53.000000000 -0700
@@ -34,7 +34,6 @@
 #define VERSION "0.23"
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/jiffies.h>
 #include <linux/netdevice.h>
diff -puN drivers/net/wan/cycx_x25.c~drivers_net_wan drivers/net/wan/cycx_x25.c
--- linux-260-test5-kj/drivers/net/wan/cycx_x25.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/cycx_x25.c	2003-09-11 10:40:53.000000000 -0700
@@ -78,7 +78,6 @@
 
 #define CYCLOMX_X25_DEBUG 1
 
-#include <linux/version.h>
 #include <linux/errno.h>	/* return codes */
 #include <linux/if_arp.h>       /* ARPHRD_HWX25 */
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
diff -puN drivers/net/wan/dlci.c~drivers_net_wan drivers/net/wan/dlci.c
--- linux-260-test5-kj/drivers/net/wan/dlci.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/dlci.c	2003-09-11 10:40:53.000000000 -0700
@@ -40,7 +40,6 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/string.h>
-#include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
diff -puN drivers/net/wan/dscc4.c~drivers_net_wan drivers/net/wan/dscc4.c
--- linux-260-test5-kj/drivers/net/wan/dscc4.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/dscc4.c	2003-09-11 10:40:53.000000000 -0700
@@ -80,7 +80,6 @@
  * - misc crapectomy.
  */
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/errno.h>
diff -puN drivers/net/wan/lmc/lmc_ver.h~drivers_net_wan drivers/net/wan/lmc/lmc_ver.h
--- linux-260-test5-kj/drivers/net/wan/lmc/lmc_ver.h~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/lmc/lmc_ver.h	2003-09-11 10:40:53.000000000 -0700
@@ -1,3 +1,5 @@
+#include <linux/version.h>
+
 #ifndef _IF_LMC_LINUXVER_
 #define _IF_LMC_LINUXVER_
 
diff -puN drivers/net/wan/pc300_drv.c~drivers_net_wan drivers/net/wan/pc300_drv.c
--- linux-260-test5-kj/drivers/net/wan/pc300_drv.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/pc300_drv.c	2003-09-11 10:40:53.000000000 -0700
@@ -227,7 +227,6 @@ static char rcsid[] = 
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/if.h>
-#include <linux/version.h>
 
 #include <net/syncppp.h>
 #include <net/arp.h>
diff -puN drivers/net/wan/pc300_tty.c~drivers_net_wan drivers/net/wan/pc300_tty.c
--- linux-260-test5-kj/drivers/net/wan/pc300_tty.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/pc300_tty.c	2003-09-11 10:40:53.000000000 -0700
@@ -37,7 +37,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
 #include <linux/errno.h>
diff -puN drivers/net/wan/sdla_chdlc.c~drivers_net_wan drivers/net/wan/sdla_chdlc.c
--- linux-260-test5-kj/drivers/net/wan/sdla_chdlc.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_chdlc.c	2003-09-11 10:40:53.000000000 -0700
@@ -49,7 +49,6 @@
 *****************************************************************************/
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
diff -puN drivers/net/wan/sdladrv.c~drivers_net_wan drivers/net/wan/sdladrv.c
--- linux-260-test5-kj/drivers/net/wan/sdladrv.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/sdladrv.c	2003-09-11 10:40:53.000000000 -0700
@@ -91,7 +91,6 @@
 #if	defined(_LINUX_)	/****** Linux *******************************/
 
 #include <linux/config.h>
-#include <linux/version.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
diff -puN drivers/net/wan/sdla_fr.c~drivers_net_wan drivers/net/wan/sdla_fr.c
--- linux-260-test5-kj/drivers/net/wan/sdla_fr.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_fr.c	2003-09-11 10:40:53.000000000 -0700
@@ -139,7 +139,6 @@
 *****************************************************************************/
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
diff -puN drivers/net/wan/sdla_ft1.c~drivers_net_wan drivers/net/wan/sdla_ft1.c
--- linux-260-test5-kj/drivers/net/wan/sdla_ft1.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_ft1.c	2003-09-11 10:40:53.000000000 -0700
@@ -21,7 +21,6 @@
 *****************************************************************************/
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
diff -puN drivers/net/wan/sdlamain.c~drivers_net_wan drivers/net/wan/sdlamain.c
--- linux-260-test5-kj/drivers/net/wan/sdlamain.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/sdlamain.c	2003-09-11 10:40:53.000000000 -0700
@@ -46,7 +46,6 @@
 * Jan 02, 1997	Gene Kozin	Initial version.
 *****************************************************************************/
 
-#include <linux/version.h>
 #include <linux/config.h>	/* OS configuration options */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
diff -puN drivers/net/wan/sdla_ppp.c~drivers_net_wan drivers/net/wan/sdla_ppp.c
--- linux-260-test5-kj/drivers/net/wan/sdla_ppp.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_ppp.c	2003-09-11 10:40:53.000000000 -0700
@@ -91,7 +91,6 @@
 *****************************************************************************/
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
diff -puN drivers/net/wan/sdla_x25.c~drivers_net_wan drivers/net/wan/sdla_x25.c
--- linux-260-test5-kj/drivers/net/wan/sdla_x25.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/sdla_x25.c	2003-09-11 10:40:53.000000000 -0700
@@ -82,7 +82,6 @@
  *=====================================================*/
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
diff -puN drivers/net/wan/wanpipe_multppp.c~drivers_net_wan drivers/net/wan/wanpipe_multppp.c
--- linux-260-test5-kj/drivers/net/wan/wanpipe_multppp.c~drivers_net_wan	2003-09-11 10:40:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wan/wanpipe_multppp.c	2003-09-11 10:40:53.000000000 -0700
@@ -18,7 +18,6 @@
 *****************************************************************************/
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */

_
