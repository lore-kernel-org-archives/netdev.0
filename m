From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][2.4] export try_atm_clip_ops not atm_clip_ops_mutex
Date: Tue, 29 Jul 2003 13:57:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307291759.h6THxlsG028613@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.4 -- thanks

[atm]: export try_atm_clip_ops not atm_clip_ops_mutex

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1037  -> 1.1038 
#	    net/atm/common.c	1.29    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/22	chas@relax.cmf.nrl.navy.mil	1.1038
# export try_atm_clip_ops not atm_clip_ops_mutex
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Tue Jul 29 13:58:11 2003
+++ b/net/atm/common.c	Tue Jul 29 13:58:11 2003
@@ -124,7 +124,7 @@
 
 #ifdef CONFIG_ATM_CLIP_MODULE
 EXPORT_SYMBOL(atm_clip_ops);
-EXPORT_SYMBOL(atm_clip_ops_mutex);
+EXPORT_SYMBOL(try_atm_clip_ops);
 EXPORT_SYMBOL(atm_clip_ops_set);
 #endif
 #endif
