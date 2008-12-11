From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 1/1] SCHED: netem: Correct documentation comment in code.
Date: Thu, 11 Dec 2008 14:18:09 +0100
Message-ID: <1229001489.18280.179.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:38523 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755300AbYLKNSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 08:18:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The netem simulator is no longer limited by Linux timer resolution HZ.
Not since Patrick McHardy changed the QoS system to use hrtimer.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 net/sched/sch_netem.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a119599..98402f0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -46,9 +46,6 @@
 	 layering other disciplines.  It does not need to do bandwidth
 	 control either since that can be handled by using token
 	 bucket or other rate control.
-
-	 The simulator is limited by the Linux timer resolution
-	 and will create packet bursts on the HZ boundary (1ms).
 */
 
 struct netem_sched_data {
-- 
1.5.4.2


