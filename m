From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH]  [ATM]: [uPD98402] convert to new-style module
Date: Sun, 21 Sep 2003 10:47:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211447.h8LEl1kT023772@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.  --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1443  -> 1.1444 
#	drivers/atm/uPD98402.c	1.6     -> 1.7    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/21	chas@relax.cmf.nrl.navy.mil	1.1444
# uPD98402.c:
#   [ATM]: [uPD98402] convert to new-style module
# --------------------------------------------
#
diff -Nru a/drivers/atm/uPD98402.c b/drivers/atm/uPD98402.c
--- a/drivers/atm/uPD98402.c	Sun Sep 21 10:40:29 2003
+++ b/drivers/atm/uPD98402.c	Sun Sep 21 10:40:29 2003
@@ -254,22 +254,13 @@
 }
 
 
-#ifdef MODULE
 MODULE_LICENSE("GPL");
 
 EXPORT_SYMBOL(uPD98402_init);
 
- 
-int init_module(void)
+static __init int uPD98402_module_init(void)
 {
-	MOD_INC_USE_COUNT;
 	return 0;
 }
-
-
-void cleanup_module(void)
-{
-	/* Nay */
-}
- 
-#endif
+module_init(uPD98402_module_init);
+/* module_exit not defined so not unloadable */
