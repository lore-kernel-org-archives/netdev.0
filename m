From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove unneeded includes (sk98lin)
Date: Wed, 17 Sep 2003 15:30:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917153003.5b5ecae5.rddunlap@osdl.org>
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

--
~Randy


From: Randy Hron <rwhron@earthlink.net>

 linux-260-test5-kj-rddunlap/drivers/net/sk98lin/h/skdrv1st.h |    4 ----
 linux-260-test5-kj-rddunlap/drivers/net/sk98lin/skge.c       |    1 -
 2 files changed, 5 deletions(-)

diff -puN drivers/net/sk98lin/h/skdrv1st.h~version_sk98lin drivers/net/sk98lin/h/skdrv1st.h
--- linux-260-test5-kj/drivers/net/sk98lin/h/skdrv1st.h~version_sk98lin	2003-09-10 17:09:09.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/sk98lin/h/skdrv1st.h	2003-09-10 17:09:09.000000000 -0700
@@ -107,9 +107,6 @@
 #ifndef __INC_SKDRV1ST_H
 #define __INC_SKDRV1ST_H
 
-/* Check kernel version */
-#include <linux/version.h>
-
 typedef struct s_AC	SK_AC;
 
 /* Set card versions */
@@ -135,7 +132,6 @@ typedef struct s_AC	SK_AC;
 #error You must compile this driver with "-O".
 #endif
 
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
diff -puN drivers/net/sk98lin/skge.c~version_sk98lin drivers/net/sk98lin/skge.c
--- linux-260-test5-kj/drivers/net/sk98lin/skge.c~version_sk98lin	2003-09-10 17:09:09.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/sk98lin/skge.c	2003-09-10 17:09:09.000000000 -0700
@@ -361,7 +361,6 @@
  *	<linux/module.h>
  *
  *	"h/skdrv1st.h"
- *		<linux/version.h>
  *		<linux/types.h>
  *		<linux/kernel.h>
  *		<linux/string.h>

_
