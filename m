From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: change ifdef inlanai_ioctl
Date: Thu, 16 Oct 2003 07:22:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310161122.h9GBMWkT010658@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1442  -> 1.1443 
#	 drivers/atm/lanai.c	1.31    -> 1.32   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/13	chas@relax.cmf.nrl.navy.mil	1.1443
# [ATM]: change ifdef in lanai_ioctl
# --------------------------------------------
#
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	Wed Oct 15 14:49:49 2003
+++ b/drivers/atm/lanai.c	Wed Oct 15 14:49:49 2003
@@ -2432,11 +2432,11 @@
 	return result;
 }
 
+#if 0
 /* ioctl operations for card */
 /* NOTE: these are all DEBUGGING ONLY currently */
 static int lanai_ioctl(struct atm_dev *atmdev, unsigned int cmd, void *arg)
 {
-#if 0
 	int result = 0;
 	struct lanai_dev *lanai = (struct lanai_dev *) atmdev->dev_data;
 	switch(cmd) {
@@ -2514,11 +2514,10 @@
 			result = -ENOIOCTLCMD;
 	}
 	return result;
+}
 #else /* !0 */
-	(void) atmdev; (void) cmd; (void) arg;	/* no compiler warnings */
-	return -ENOIOCTLCMD;
+#define lanai_ioctl NULL
 #endif /* 0 */
-}
 
 static int lanai_send(struct atm_vcc *atmvcc, struct sk_buff *skb)
 {
