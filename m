From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test4 SEQ_START_TOKEN drivers/net (5/6)
Date: Fri, 05 Sep 2003 18:48:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062812890.16851.171.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN linux-2.6.0-test4/drivers/net/pppoe.c SEQ_START_TOKEN/drivers/net/pppoe.c
-- linux-2.6.0-test4/drivers/net/pppoe.c	2003-08-22 16:57:18.000000000 -0700
+++ SEQ_START_TOKEN/drivers/net/pppoe.c	2003-09-04 19:46:59.000000000 -0700
@@ -986,7 +986,7 @@
 	struct pppox_opt *po;
 	char *dev_name;
 
-	if (v == (void *)1) {
+	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "Id       Address              Device\n");
 		goto out;
 	}
@@ -1025,7 +1025,7 @@
 	loff_t l = *pos;
 
 	read_lock_bh(&pppoe_hash_lock);
-	return l ? pppoe_get_idx(--l) : (void *)1;
+	return l ? pppoe_get_idx(--l) : SEQ_START_TOKEN;
 }
 
 static void *pppoe_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -1033,7 +1033,7 @@
 	struct pppox_opt *po;
 
 	++*pos;
-	if (v == (void *)1) {
+	if (v == SEQ_START_TOKEN) {
 		po = pppoe_get_idx(0);
 		goto out;
 	}
