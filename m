From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove (or add) unneeded includes (drivers/net/)
Date: Wed, 17 Sep 2003 15:10:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917151026.54292548.rddunlap@osdl.org>
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

Thanks.
--
~Randy


From: Randy Hron <rwhron@earthlink.net>


 linux-260-test5-kj-rddunlap/drivers/net/3c515.c   |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/cs89x0.c  |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/ibmlana.c |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/mace.c    |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/ne2.c     |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/ni65.c    |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/rrunner.c |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/sb1000.c  |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/sis900.c  |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/sk_mca.h  |    2 ++
 linux-260-test5-kj-rddunlap/drivers/net/smc9194.c |    1 -
 11 files changed, 2 insertions(+), 10 deletions(-)

diff -puN drivers/net/3c515.c~version_net drivers/net/3c515.c
--- linux-260-test5-kj/drivers/net/3c515.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/3c515.c	2003-09-10 17:08:11.000000000 -0700
@@ -59,7 +59,6 @@ static int max_interrupt_work = 20;
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/isapnp.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
diff -puN drivers/net/cs89x0.c~version_net drivers/net/cs89x0.c
--- linux-260-test5-kj/drivers/net/cs89x0.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/cs89x0.c	2003-09-10 17:08:11.000000000 -0700
@@ -90,7 +90,6 @@
    or override something. */
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 
 /*
  * Set this to zero to disable DMA code
diff -puN drivers/net/ibmlana.c~version_net drivers/net/ibmlana.c
--- linux-260-test5-kj/drivers/net/ibmlana.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/ibmlana.c	2003-09-10 17:08:11.000000000 -0700
@@ -74,7 +74,6 @@ History:
 
  *************************************************************************/
 
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
diff -puN drivers/net/mace.c~version_net drivers/net/mace.c
--- linux-260-test5-kj/drivers/net/mace.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/mace.c	2003-09-10 17:08:11.000000000 -0700
@@ -7,7 +7,6 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff -puN drivers/net/ne2.c~version_net drivers/net/ne2.c
--- linux-260-test5-kj/drivers/net/ne2.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/ne2.c	2003-09-10 17:08:11.000000000 -0700
@@ -60,7 +60,6 @@
 static const char *version = "ne2.c:v0.91 Nov 16 1998 Wim Dumon <wimpie@kotnet.org>\n";
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
diff -puN drivers/net/ni65.c~version_net drivers/net/ni65.c
--- linux-260-test5-kj/drivers/net/ni65.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/ni65.c	2003-09-10 17:08:11.000000000 -0700
@@ -72,7 +72,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/version.h>
 #include <linux/module.h>
 
 #include <asm/bitops.h>
diff -puN drivers/net/rrunner.c~version_net drivers/net/rrunner.c
--- linux-260-test5-kj/drivers/net/rrunner.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/rrunner.c	2003-09-10 17:08:11.000000000 -0700
@@ -30,7 +30,6 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
diff -puN drivers/net/sb1000.c~version_net drivers/net/sb1000.c
--- linux-260-test5-kj/drivers/net/sb1000.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/sb1000.c	2003-09-10 17:08:11.000000000 -0700
@@ -35,7 +35,6 @@
 static char version[] = "sb1000.c:v1.1.2 6/01/98 (fventuri@mediaone.net)\n";
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/interrupt.h>
diff -puN drivers/net/sis900.c~version_net drivers/net/sis900.c
--- linux-260-test5-kj/drivers/net/sis900.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/sis900.c	2003-09-10 17:08:11.000000000 -0700
@@ -47,7 +47,6 @@
 */
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff -puN drivers/net/sk_mca.h~version_net drivers/net/sk_mca.h
--- linux-260-test5-kj/drivers/net/sk_mca.h~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/sk_mca.h	2003-09-10 17:08:11.000000000 -0700
@@ -1,3 +1,5 @@
+#include <linux/version.h>
+
 #ifndef _SK_MCA_INCLUDE_
 #define _SK_MCA_INCLUDE_
 
diff -puN drivers/net/smc9194.c~version_net drivers/net/smc9194.c
--- linux-260-test5-kj/drivers/net/smc9194.c~version_net	2003-09-10 17:08:11.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/smc9194.c	2003-09-10 17:08:11.000000000 -0700
@@ -58,7 +58,6 @@ static const char version[] =
 	"smc9194.c:v0.14 12/15/00 by Erik Stahlman (erik@vt.edu)\n";
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>

_
