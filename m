From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [firestream] allow module refcounting
Date: Sun, 21 Sep 2003 10:45:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211445.h8LEj1kT023729@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1440  -> 1.1441 
#	drivers/atm/firestream.c	1.25    -> 1.26   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/11	chas@relax.cmf.nrl.navy.mil	1.1441
# [ATM]: [firestream] allow module refcounting
# --------------------------------------------
#
diff -Nru a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c	Sun Sep 21 09:36:39 2003
+++ b/drivers/atm/firestream.c	Sun Sep 21 09:36:39 2003
@@ -1276,9 +1276,7 @@
 	.open =         fs_open,
 	.close =        fs_close,
 	.send =         fs_send,
-#if 0
 	.owner =        THIS_MODULE,
-#endif
 	/* ioctl:          fs_ioctl, */
 	/* getsockopt:     fs_getsockopt, */
 	/* setsockopt:     fs_setsockopt, */
