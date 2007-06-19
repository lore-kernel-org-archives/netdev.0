From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/04]: Remove unnecessary includes
Date: Tue, 19 Jun 2007 17:02:23 +0200 (MEST)
Message-ID: <20070619150205.30997.74530.sendpatchset@localhost.localdomain>
References: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60164 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbXFSPCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 11:02:25 -0400
In-Reply-To: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Remove unnecessary includes

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ca29df065c5d0caa69cde99f9cf1775d63b3468d
tree 102917a89c4c3e63f9ba1d586bd112614f8c6614
parent f18cfcd1e11aabd3c0b606c7f3265634b5261e88
author Patrick McHardy <kaber@trash.net> Tue, 19 Jun 2007 16:54:18 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 19 Jun 2007 16:54:18 +0200

 net/sched/act_api.c       |   10 ----------
 net/sched/act_gact.c      |   11 -----------
 net/sched/act_ipt.c       |   12 ------------
 net/sched/act_mirred.c    |   12 ------------
 net/sched/act_pedit.c     |   11 -----------
 net/sched/act_police.c    |   10 ----------
 net/sched/act_simple.c    |    1 -
 net/sched/cls_api.c       |   10 ----------
 net/sched/cls_basic.c     |    1 -
 net/sched/cls_fw.c        |   19 +------------------
 net/sched/cls_route.c     |   20 +++-----------------
 net/sched/cls_rsvp.c      |   17 +----------------
 net/sched/cls_rsvp6.c     |   16 ----------------
 net/sched/cls_tcindex.c   |    3 ---
 net/sched/cls_u32.c       |   18 +-----------------
 net/sched/ematch.c        |    2 --
 net/sched/sch_api.c       |   12 ------------
 net/sched/sch_atm.c       |    3 ---
 net/sched/sch_blackhole.c |    1 -
 net/sched/sch_cbq.c       |   18 +-----------------
 net/sched/sch_dsmark.c    |    1 -
 net/sched/sch_fifo.c      |    1 -
 net/sched/sch_generic.c   |    8 --------
 net/sched/sch_gred.c      |    1 -
 net/sched/sch_hfsc.c      |    3 ---
 net/sched/sch_htb.c       |   18 +-----------------
 net/sched/sch_ingress.c   |    9 +--------
 net/sched/sch_netem.c     |    2 --
 net/sched/sch_prio.c      |   16 ----------------
 net/sched/sch_red.c       |    1 -
 net/sched/sch_sfq.c       |   18 ++----------------
 net/sched/sch_tbf.c       |   19 +------------------
 net/sched/sch_teql.c      |   18 ++----------------
 33 files changed, 14 insertions(+), 308 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 32cc191..feef366 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -11,23 +11,13 @@
  *
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
-#include <net/sock.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
 #include <net/netlink.h>
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 7517f37..a9631e4 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -10,26 +10,15 @@
  *
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/proc_fs.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_gact.h>
 #include <net/tc_act/tc_gact.h>
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 00b05f4..6b407ec 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -11,27 +11,15 @@
  * Copyright:	Jamal Hadi Salim (2002-4)
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <asm/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/proc_fs.h>
-#include <linux/kmod.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_ipt.h>
 #include <net/tc_act/tc_ipt.h>
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index de21c92..5795789 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -12,31 +12,19 @@
  *
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <asm/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/proc_fs.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_mirred.h>
 
-#include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 
 #define MIRRED_TAB_MASK     7
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 6f8684b..b46fab5 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -9,26 +9,15 @@
  * Authors:	Jamal Hadi Salim (2002-4)
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <asm/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/proc_fs.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_pedit.h>
 #include <net/tc_act/tc_pedit.h>
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 3e8716d..d204038 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -10,25 +10,15 @@
  * 		J Hadi Salim (action changes)
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/module.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
-#include <net/sock.h>
 #include <net/act_api.h>
 #include <net/netlink.h>
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 36e1eda..fb84ef3 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -13,7 +13,6 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <net/netlink.h>
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index ebf94ed..36b72aa 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -14,26 +14,16 @@
  *
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/netlink.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
 
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index c885412..8dbcf27 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -13,7 +13,6 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
 #include <linux/errno.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index bbec4a0..8adbd6a 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -19,29 +19,12 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <linux/netfilter.h>
-#include <net/ip.h>
-#include <net/netlink.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
+#include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index cc941d0..0a8409c 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -10,28 +10,14 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/netlink.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
+#include <net/dst.h>
+#include <net/route.h>
+#include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
diff --git a/net/sched/cls_rsvp.c b/net/sched/cls_rsvp.c
index 0a683c0..cbb5e0d 100644
--- a/net/sched/cls_rsvp.c
+++ b/net/sched/cls_rsvp.c
@@ -10,27 +10,12 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
+#include <net/ip.h>
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
diff --git a/net/sched/cls_rsvp6.c b/net/sched/cls_rsvp6.c
index 93b6abe..dd08aea 100644
--- a/net/sched/cls_rsvp6.c
+++ b/net/sched/cls_rsvp6.c
@@ -10,28 +10,12 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
 #include <linux/ipv6.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 #include <net/netlink.h>
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 47ac0c5..2314820 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -9,12 +9,9 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/netdevice.h>
-#include <net/ip.h>
 #include <net/act_api.h>
 #include <net/netlink.h>
 #include <net/pkt_cls.h>
-#include <net/route.h>
 
 
 /*
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index c7a347b..77961e2 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -30,30 +30,14 @@
  *	nfmark match added by Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
 #include <linux/rtnetlink.h>
-#include <net/ip.h>
-#include <net/netlink.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
+#include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 63146d3..2483739 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -84,9 +84,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/mm.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <net/pkt_cls.h>
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 0f9e1c7..d92ea26 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -19,30 +19,18 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/kmod.h>
 #include <linux/list.h>
-#include <linux/bitops.h>
 #include <linux/hrtimer.h>
 
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 
-#include <asm/processor.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-
 static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n, u32 clid,
 			struct Qdisc *old, struct Qdisc *new);
 static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 16fe802..54b92d2 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -8,15 +8,12 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
-#include <linux/interrupt.h>
 #include <linux/atmdev.h>
 #include <linux/atmclip.h>
-#include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/file.h> /* for fput */
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-#include <net/sock.h>
 
 
 extern struct socket *sockfd_lookup(int fd, int *err); /* @@@ fix this */
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index cb0c456..f914fc4 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -14,7 +14,6 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index b093d8f..b184c35 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -11,28 +11,12 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/netlink.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 3c6fd18..4d2c233 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -9,7 +9,6 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
-#include <linux/netdevice.h> /* for pkt_sched */
 #include <linux/rtnetlink.h>
 #include <net/pkt_sched.h>
 #include <net/dsfield.h>
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index c2689f4..c264308 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -13,7 +13,6 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5f65d03..1022d3c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -11,27 +11,19 @@
  *              - Ingress support
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
 #include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/rcupdate.h>
 #include <linux/list.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 
 #define SCHED_TX_DROP -2
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index fa1b4fe..3cc6dda 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -21,7 +21,6 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 #include <net/red.h>
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 7130a24..874452c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -53,7 +53,6 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#include <linux/jiffies.h>
 #include <linux/compiler.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
@@ -62,13 +61,11 @@
 #include <linux/list.h>
 #include <linux/rbtree.h>
 #include <linux/init.h>
-#include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
-#include <asm/system.h>
 #include <asm/div64.h>
 
 /*
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 944ad18..387e3e1 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -28,32 +28,16 @@
  * $Id: sch_htb.c,v 1.25 2003/12/07 11:08:25 devik Exp devik $
  */
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
 #include <linux/list.h>
 #include <linux/compiler.h>
+#include <linux/rbtree.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
-#include <linux/rbtree.h>
 
 /* HTB algorithm.
     Author: devik@cdi.cz
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index f8b9f1c..cd0aab6 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -9,21 +9,14 @@
 
 #include <linux/module.h>
 #include <linux/types.h>
+#include <linux/list.h>
 #include <linux/skbuff.h>
-#include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter.h>
-#include <linux/smp.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-#include <asm/byteorder.h>
-#include <asm/uaccess.h>
-#include <linux/kmod.h>
-#include <linux/stat.h>
-#include <linux/interrupt.h>
-#include <linux/list.h>
 
 
 #undef DEBUG_INGRESS
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5d9d8bc..9e5e87e 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -14,11 +14,9 @@
  */
 
 #include <linux/module.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 6d7542c..0c8dcf5 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -12,28 +12,12 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>
 
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 00db53e..9b95fef 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -17,7 +17,6 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 96dfdf7..9579573 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -10,31 +10,17 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
 #include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
 #include <linux/init.h>
-#include <net/ip.h>
-#include <net/netlink.h>
 #include <linux/ipv6.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
+#include <net/ip.h>
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 5386295..22e431d 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -13,29 +13,12 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/jiffies.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/netlink.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index f05ad9a..559fe04 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -9,30 +9,17 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
 #include <linux/if_arp.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
 #include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
 #include <linux/init.h>
-#include <net/ip.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
 #include <linux/moduleparam.h>
-#include <net/sock.h>
+#include <net/dst.h>
+#include <net/neighbour.h>
 #include <net/pkt_sched.h>
 
 /*
@@ -225,7 +212,6 @@ static int teql_qdisc_init(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
-/* "teql*" netdevice routines */
 
 static int
 __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *dev)
