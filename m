From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove unneeded includes (hamradio)
Date: Wed, 17 Sep 2003 15:24:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917152433.2b253a0c.rddunlap@osdl.org>
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

diff -Nur linux-2.6.0-test5-bk1/drivers/net/hamradio/baycom_par.c linux/drivers/net/hamradio/baycom_par.c


 linux-260-test5-kj-rddunlap/drivers/net/hamradio/baycom_par.c     |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/hamradio/baycom_ser_fdx.c |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/hamradio/baycom_ser_hdx.c |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/hamradio/hdlcdrv.c        |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/hamradio/yam.c            |    1 -
 5 files changed, 5 deletions(-)

diff -puN drivers/net/hamradio/baycom_par.c~drivers_net_hamradio drivers/net/hamradio/baycom_par.c
--- linux-260-test5-kj/drivers/net/hamradio/baycom_par.c~drivers_net_hamradio	2003-09-11 10:41:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/hamradio/baycom_par.c	2003-09-11 10:41:54.000000000 -0700
@@ -68,7 +68,6 @@
 
 /*****************************************************************************/
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
diff -puN drivers/net/hamradio/baycom_ser_fdx.c~drivers_net_hamradio drivers/net/hamradio/baycom_ser_fdx.c
--- linux-260-test5-kj/drivers/net/hamradio/baycom_ser_fdx.c~drivers_net_hamradio	2003-09-11 10:41:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/hamradio/baycom_ser_fdx.c	2003-09-11 10:41:54.000000000 -0700
@@ -71,7 +71,6 @@
 
 /*****************************************************************************/
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/ioport.h>
 #include <linux/string.h>
diff -puN drivers/net/hamradio/baycom_ser_hdx.c~drivers_net_hamradio drivers/net/hamradio/baycom_ser_hdx.c
--- linux-260-test5-kj/drivers/net/hamradio/baycom_ser_hdx.c~drivers_net_hamradio	2003-09-11 10:41:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/hamradio/baycom_ser_hdx.c	2003-09-11 10:41:54.000000000 -0700
@@ -61,7 +61,6 @@
 
 /*****************************************************************************/
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/ioport.h>
 #include <linux/string.h>
diff -puN drivers/net/hamradio/hdlcdrv.c~drivers_net_hamradio drivers/net/hamradio/hdlcdrv.c
--- linux-260-test5-kj/drivers/net/hamradio/hdlcdrv.c~drivers_net_hamradio	2003-09-11 10:41:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/hamradio/hdlcdrv.c	2003-09-11 10:41:54.000000000 -0700
@@ -43,7 +43,6 @@
 /*****************************************************************************/
 
 #include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/net.h>
diff -puN drivers/net/hamradio/yam.c~drivers_net_hamradio drivers/net/hamradio/yam.c
--- linux-260-test5-kj/drivers/net/hamradio/yam.c~drivers_net_hamradio	2003-09-11 10:41:53.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/hamradio/yam.c	2003-09-11 10:41:54.000000000 -0700
@@ -74,7 +74,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
-#include <linux/version.h>
 #include <asm/uaccess.h>
 #include <linux/init.h>
 

_
