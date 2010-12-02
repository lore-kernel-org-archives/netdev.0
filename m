From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH v2 3/4] ipv6: use ND_REACHABLE_TIME and ND_RETRANS_TIMER instead
 of magic number
Date: Thu, 02 Dec 2010 12:05:12 +0800
Message-ID: <4CF71AF8.9050205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49245 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756891Ab0LBEG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 23:06:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ND_REACHABLE_TIME and ND_RETRANS_TIMER have defined 
since v2.6.12-rc2, but never been used.
So use them instead of magic number.

This patch also changes original code style to read comfortably .

Thank YOSHIFUJI Hideaki for pointing it out.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/ndisc.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 998d6d2..e18f841 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -141,18 +141,18 @@ struct neigh_table nd_tbl = {
 	.proxy_redo =	pndisc_redo,
 	.id =		"ndisc_cache",
 	.parms = {
-		.tbl =			&nd_tbl,
-		.base_reachable_time =	30 * HZ,
-		.retrans_time =	 1 * HZ,
-		.gc_staletime =	60 * HZ,
-		.reachable_time =		30 * HZ,
-		.delay_probe_time =	 5 * HZ,
-		.queue_len =		 3,
-		.ucast_probes =	 3,
-		.mcast_probes =	 3,
-		.anycast_delay =	 1 * HZ,
-		.proxy_delay =		(8 * HZ) / 10,
-		.proxy_qlen =		64,
+		.tbl			= &nd_tbl,
+		.base_reachable_time	= ND_REACHABLE_TIME,
+		.retrans_time		= ND_RETRANS_TIMER,
+		.gc_staletime		= 60 * HZ,
+		.reachable_time		= ND_REACHABLE_TIME,
+		.delay_probe_time	= 5 * HZ,
+		.queue_len		= 3,
+		.ucast_probes		= 3,
+		.mcast_probes		= 3,
+		.anycast_delay		= 1 * HZ,
+		.proxy_delay		= (8 * HZ) / 10,
+		.proxy_qlen		= 64,
 	},
 	.gc_interval =	  30 * HZ,
 	.gc_thresh1 =	 128,
-- 
1.6.3.3
