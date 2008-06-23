From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove CONFIG_NET_SCH_RR
Date: Mon, 23 Jun 2008 20:47:02 +0300
Message-ID: <20080623174702.GD4756@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "Robert P. J. Day" <rpjday@crashcourse.ca>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:57836 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760594AbYFWRs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 13:48:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d62733c8e437fdb58325617c4b3331769ba82d70
([SCHED]: Qdisc changes and sch_rr added for multiqueue)
added a NET_SCH_RR option that was unused since the code
went unconditionally into sch_prio.

Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
572f329b3e8fc3648f7585e36291fcd30dd7daec diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 82adfe6..9437b27 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -106,17 +106,6 @@ config NET_SCH_PRIO
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_prio.
 
-config NET_SCH_RR
-	tristate "Multi Band Round Robin Queuing (RR)"
-	select NET_SCH_PRIO
-	---help---
-	  Say Y here if you want to use an n-band round robin packet
-	  scheduler.
-
-	  The module uses sch_prio for its framework and is aliased as
-	  sch_rr, so it will load sch_prio, although it is referred
-	  to using sch_rr.
-
 config NET_SCH_RED
 	tristate "Random Early Detection (RED)"
 	---help---

