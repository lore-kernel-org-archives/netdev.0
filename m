From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] NET: Remove dead net/sched/Makefile entry for sch_hpfq.o.
Date: Mon, 26 Mar 2007 19:10:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0703261907320.24253@CPE00045a9c397f-CM001225dbafb6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:36202 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbXCZXTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 19:19:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove the worthless net/sched/Makefile entry for the non-existent
source file sch_hpfq.c.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

diff --git a/net/sched/Makefile b/net/sched/Makefile
index ff2d6e5..020767a 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -17,7 +17,6 @@ obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
-obj-$(CONFIG_NET_SCH_HPFQ)	+= sch_hpfq.o
 obj-$(CONFIG_NET_SCH_HFSC)	+= sch_hfsc.o
 obj-$(CONFIG_NET_SCH_RED)	+= sch_red.o
 obj-$(CONFIG_NET_SCH_GRED)	+= sch_gred.o

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
