From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NET: spelling correction
Date: Wed, 11 Feb 2004 03:28:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211.032834.11028832.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: spelling correction for net/core

===== net/core/dev.c 1.129 vs edited =====
--- 1.129/net/core/dev.c	Sat Feb  7 10:56:41 2004
+++ edited/net/core/dev.c	Wed Feb 11 02:46:09 2004
@@ -134,7 +134,7 @@
  *             sure which should go first, but I bet it won't make much
  *             difference if we are running VLANs.  The good news is that
  *             this protocol won't be in the list unless compiled in, so
- *             the average user (w/out VLANs) will not be adversly affected.
+ *             the average user (w/out VLANs) will not be adversely affected.
  *             --BLG
  *
  *		0800	IP
@@ -892,7 +892,7 @@
 /*
  * Some old buggy device drivers change get_stats after registering
  * the device.  Try and trap them here.
- * This can be elimnated when all devices are known fixed.
+ * This can be eliminated when all devices are known fixed.
  */
 static inline int get_stats_changed(struct net_device *dev)
 {
@@ -1375,7 +1375,7 @@
 
 		if (dev->xmit_lock_owner != cpu) {
 			/*
-			 * The spin_lock effectivly does a preempt lock, but 
+			 * The spin_lock effectively does a preempt lock, but 
 			 * we are about to drop that...
 			 */
 			preempt_disable();
@@ -1426,7 +1426,7 @@
 int netdev_max_backlog = 300;
 int weight_p = 64;            /* old backlog weight */
 /* These numbers are selected based on intuition and some
- * experimentatiom, if you have more scientific way of doing this
+ * experimentation, if you have more scientific way of doing this
  * please go ahead and fix things.
  */
 int no_cong_thresh = 10;
===== net/core/wireless.c 1.15 vs edited =====
--- 1.15/net/core/wireless.c	Mon Sep 29 07:29:53 2003
+++ edited/net/core/wireless.c	Wed Feb 11 02:52:12 2004
@@ -378,7 +378,7 @@
  *
  * Note : our current commit strategy is currently pretty dumb,
  * but we will be able to improve on that...
- * The goal is to try to agreagate as many changes as possible
+ * The goal is to try to aggregate as many changes as possible
  * before doing the commit. Drivers that will define a commit handler
  * are usually those that need a reset after changing parameters, so
  * we want to minimise the number of reset.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
