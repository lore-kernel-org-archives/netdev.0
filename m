From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH]  [ATM]: [he] make code more readable with list_for_each_entry (from Domen Puncer <domen@coderock.org>)
Date: Tue, 21 Sep 2004 16:30:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409212030.i8LKUMug010619@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com, Domen Puncer <domen@coderock.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave,

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/17 21:09:56-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [he] make code more readable with list_for_each_entry (from Domen Puncer <domen@coderock.org>)
# 
# drivers/atm/he.c
#   2004/09/17 21:08:45-04:00 chas@relax.cmf.nrl.navy.mil +2 -3
# 
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2004-09-21 13:48:06 -04:00
+++ b/drivers/atm/he.c	2004-09-21 13:48:06 -04:00
@@ -1963,7 +1963,7 @@
 	struct he_tpd *tpd;
 	int slot, updated = 0;
 #ifdef USE_TPD_POOL
-	struct list_head *p;
+	struct he_tpd *__tpd;
 #endif
 
 	/* 2.1.6 transmit buffer return queue */
@@ -1978,8 +1978,7 @@
 			TBRQ_MULTIPLE(he_dev->tbrq_head) ? " MULTIPLE" : "");
 #ifdef USE_TPD_POOL
 		tpd = NULL;
-		list_for_each(p, &he_dev->outstanding_tpds) {
-			struct he_tpd *__tpd = list_entry(p, struct he_tpd, entry);
+		list_for_each_entry(__tpd, &he_dev->outstanding_tpds, entry) {
 			if (TPD_ADDR(__tpd->status) == TBRQ_TPD(he_dev->tbrq_head)) {
 				tpd = __tpd;
 				list_del(&__tpd->entry);
