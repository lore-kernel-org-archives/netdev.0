From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [uPD98402] exported symbols should not be marked __init
Date: Sun, 21 Sep 2003 10:48:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211448.h8LEmTkT023785@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1444  -> 1.1445 
#	drivers/atm/uPD98402.c	1.7     -> 1.8    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/21	chas@relax.cmf.nrl.navy.mil	1.1445
# uPD98402.c:
#   [ATM]: [uPD98402] exported symbols should not be marked __init
# --------------------------------------------
#
diff -Nru a/drivers/atm/uPD98402.c b/drivers/atm/uPD98402.c
--- a/drivers/atm/uPD98402.c	Sun Sep 21 10:42:35 2003
+++ b/drivers/atm/uPD98402.c	Sun Sep 21 10:42:35 2003
@@ -246,7 +246,7 @@
 };
 
 
-int __init uPD98402_init(struct atm_dev *dev)
+int uPD98402_init(struct atm_dev *dev)
 {
 DPRINTK("phy_init\n");
 	dev->phy = &uPD98402_ops;
