From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/1][ATM]: sk_atm() conversion missed subtle change of vcc
Date: Thu, 14 Apr 2005 13:48:06 -0400
Message-ID: <200504141748.j3EHm6Q0022689@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/14 13:42:33-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: sk_atm() conversion missed subtle change of vcc
#   
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/signaling.c
#   2005/04/14 13:42:11-04:00 chas@relax.cmf.nrl.navy.mil +1 -0
#   [ATM]: sk_atm() conversion missed subtle change of vcc
#   
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	2005-04-14 13:47:32 -04:00
+++ b/net/atm/signaling.c	2005-04-14 13:47:32 -04:00
@@ -134,6 +134,7 @@
 			break;
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
+			sk = sk_atm(vcc);
 			DPRINTK("as_indicate!!!\n");
 			lock_sock(sk);
 			if (sk_acceptq_is_full(sk)) {
