From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [lec] remove unnecessary inlines (from Adrian Bunk <bunk@fs.tum.de>)
Date: Tue, 27 Jul 2004 20:41:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407280041.i6S0fcMe010687@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com, carnil@cs.tut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1882  -> 1.1883 
#	       net/atm/lec.c	1.43    -> 1.44   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/07/27	chas@relax.cmf.nrl.navy.mil	1.1883
# [ATM]: [lec] remove unnecessary inlines (from Adrian Bunk <bunk@fs.tum.de>)
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Tue Jul 27 20:06:05 2004
+++ b/net/atm/lec.c	Tue Jul 27 20:06:05 2004
@@ -71,9 +71,9 @@
 static int lec_close(struct net_device *dev);
 static struct net_device_stats *lec_get_stats(struct net_device *dev);
 static void lec_init(struct net_device *dev);
-static inline struct lec_arp_table* lec_arp_find(struct lec_priv *priv,
+static struct lec_arp_table* lec_arp_find(struct lec_priv *priv,
                                                      unsigned char *mac_addr);
-static inline int lec_arp_remove(struct lec_priv *priv,
+static int lec_arp_remove(struct lec_priv *priv,
 				     struct lec_arp_table *to_remove);
 /* LANE2 functions */
 static void lane2_associate_ind (struct net_device *dev, u8 *mac_address,
@@ -1468,7 +1468,7 @@
 /*
  * Remove entry from lec_arp_table
  */
-static inline int 
+static int 
 lec_arp_remove(struct lec_priv *priv,
                struct lec_arp_table *to_remove)
 {
@@ -1755,7 +1755,7 @@
 /* 
  * Find entry by mac_address
  */
-static inline struct lec_arp_table*
+static struct lec_arp_table*
 lec_arp_find(struct lec_priv *priv,
              unsigned char *mac_addr)
 {
