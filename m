From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NET] mis-spellings in net/core/neighbour.c
Date: Tue, 23 Dec 2003 17:02:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031223.170257.69290968.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I found several typoes / mis-spellings in net/core/neighbour.c.

===== neighbour.c 1.20 vs edited =====
--- 1.20/net/core/neighbour.c	Tue Oct 21 14:59:11 2003
+++ edited/neighbour.c	Tue Dec 23 16:50:15 2003
@@ -98,7 +98,7 @@
 /*
  * It is random distribution in the interval (1/2)*base...(3/2)*base.
  * It corresponds to default IPv6 settings and is not overridable,
- * because it is really reasonbale choice.
+ * because it is really reasonable choice.
  */
 
 unsigned long neigh_rand_reach_time(unsigned long base)
@@ -120,7 +120,7 @@
 		while ((n = *np) != NULL) {
 			/* Neighbour record may be discarded if:
 			   - nobody refers to it.
-			   - it is not premanent
+			   - it is not permanent
 			   - (NEW and probably wrong)
 			     INCOMPLETE entries are kept at least for
 			     n->parms->retrans_time, otherwise we could
@@ -510,7 +510,7 @@
 {
 	struct hh_cache *hh;
 
-	NEIGH_PRINTK2("neigh %p is suspecteded.\n", neigh);
+	NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
 
 	neigh->output = neigh->ops->output;
 
@@ -537,7 +537,7 @@
 
 /*
    Transitions NUD_STALE <-> NUD_REACHABLE do not occur
-   when fast path is built: we have no timers assotiated with
+   when fast path is built: we have no timers associated with
    these states, we do not have time to check state when sending.
    neigh_periodic_timer check periodically neigh->confirmed
    time and moves NUD_REACHABLE -> NUD_STALE.
@@ -962,7 +962,7 @@
 
 /* This function can be used in contexts, where only old dev_queue_xmit
    worked, f.e. if you want to override normal output path (eql, shaper),
-   but resoltution is not made yet.
+   but resolution is not made yet.
  */
 
 int neigh_compat_output(struct sk_buff *skb)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
