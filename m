From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [lanai] ioctl only meant for debugging (from mitch@sfgoth.com)
Date: Mon, 22 Sep 2003 13:03:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309221703.h8MH3tkT009109@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pleae apply to 2.4. --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1115  -> 1.1116 
#	 drivers/atm/lanai.c	1.4     -> 1.5    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/22	chas@relax.cmf.nrl.navy.mil	1.1116
# [ATM]: [lanai] ioctl only meant for debugging (from mitch@sfgoth.com)
# --------------------------------------------
#
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	Mon Sep 22 13:01:23 2003
+++ b/drivers/atm/lanai.c	Mon Sep 22 13:01:23 2003
@@ -2574,6 +2574,7 @@
 /* NOTE: these are all DEBUGGING ONLY currently */
 static int lanai_ioctl(struct atm_dev *atmdev, unsigned int cmd, void *arg)
 {
+#if 0
 	int result = 0;
 	struct lanai_dev *lanai = (struct lanai_dev *) atmdev->dev_data;
 	switch(cmd) {
@@ -2653,6 +2654,10 @@
 			result = -EINVAL;
 	}
 	return result;
+#else /* !0 */
+	(void) atmdev; (void) cmd; (void) arg;  /* no compiler warnings */
+	return -ENOIOCTLCMD;
+#endif /* 0 */
 }
 
 static int lanai_send(struct atm_vcc *atmvcc, struct sk_buff *skb)
