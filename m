From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: get atm_guess_pdu2truesize() right
Date: Wed, 07 Apr 2004 08:05:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404071205.i37C58MO020742@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 and 2.4 kernels. 

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1331.3.3 -> 1.1331.3.4
#	include/linux/atmdev.h	1.13    -> 1.14   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/04/07	chas@relax.cmf.nrl.navy.mil	1.1331.3.4
# [ATM]: get atm_guess_pdu2truesize() right
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Wed Apr  7 08:01:57 2004
+++ b/include/linux/atmdev.h	Wed Apr  7 08:01:57 2004
@@ -411,9 +411,9 @@
  *
  */
 
-static inline int atm_guess_pdu2truesize(int pdu_size)
+static inline int atm_guess_pdu2truesize(int size)
 {
-	return ((pdu_size+15) & ~15) + sizeof(struct sk_buff);
+	return (SKB_DATA_ALIGN(size) + sizeof(struct skb_shared_info));
 }
 
 
