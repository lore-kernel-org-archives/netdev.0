From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] horizon: make reset function not __init
Date: Mon, 23 Feb 2004 20:19:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402240119.i1O1JCg5028269@ginger.cmf.nrl.navy.mil>
References: <20040219154941.0d0f5a7a.rddunlap@osdl.org>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, "Randy.Dunlap" <rddunlap@osdl.org>
In-reply-to: Your message of "Thu, 19 Feb 2004 15:49:41 PST."
             <20040219154941.0d0f5a7a.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.  --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1551  -> 1.1552 
#	drivers/atm/horizon.c	1.14    -> 1.15   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/23	chas@relax.cmf.nrl.navy.mil	1.1552
# [ATM]: horizon: make reset function not __init (from Randy Dunlap <rddunlap@osdl.org>)
# --------------------------------------------
#
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	Mon Feb 23 20:10:49 2004
+++ b/drivers/atm/horizon.c	Mon Feb 23 20:10:49 2004
@@ -1802,7 +1802,7 @@
 
 /********** reset a card **********/
 
-static void __init hrz_reset (const hrz_dev * dev) {
+static void hrz_reset (const hrz_dev * dev) {
   u32 control_0_reg = rd_regl (dev, CONTROL_0_REG);
   
   // why not set RESET_HORIZON to one and wait for the card to
