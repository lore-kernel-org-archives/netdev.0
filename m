From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [zatm] correct way to prevent module unload (from shemminger@osdl.org)
Date: Sun, 21 Sep 2003 10:48:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211448.h8LEmtkT023791@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1442  -> 1.1443 
#	  drivers/atm/zatm.c	1.20    -> 1.21   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/16	chas@relax.cmf.nrl.navy.mil	1.1443
# [ATM]: [zatm] correct way to prevent module unload (from shemminger@osdl.org)
# --------------------------------------------
#
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	Sun Sep 21 09:36:31 2003
+++ b/drivers/atm/zatm.c	Sun Sep 21 09:36:31 2003
@@ -1617,11 +1617,10 @@
 out:
 	kfree(zatm_dev);
 
-	/* XXX: currently the driver is not unloadable.. */
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
 MODULE_LICENSE("GPL");
 
 module_init(zatm_module_init);
+/* module_exit not defined so not unloadable */
