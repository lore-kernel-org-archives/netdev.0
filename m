From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1 of 5][ATM]: [fore200e] can't sleep in transmit routine
Date: Wed, 26 Jan 2005 11:56:46 -0500
Message-ID: <200501261656.j0QGujlu018849@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/24 13:21:28-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [fore200e] can't sleep in transmit routine
#   
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/fore200e.c
#   2005/01/24 13:21:10-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [fore200e] can't sleep in transmit routine
#   
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	2005-01-25 09:36:27 -05:00
+++ b/drivers/atm/fore200e.c	2005-01-25 09:36:27 -05:00
@@ -1779,7 +1779,7 @@
 
 	    /* retry once again? */
 	    if (--retry > 0) {
-		schedule();
+		udelay(50);
 		goto retry_here;
 	    }
 
