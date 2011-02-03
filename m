From: David Miller <davem@davemloft.net>
Subject: [PATCH] sch_choke: Need linux/vmalloc.h
Date: Wed, 02 Feb 2011 23:08:00 -0800 (PST)
Message-ID: <20110202.230800.193713185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752432Ab1BCHHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 02:07:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

This fixes the build on sparc64.

 net/sched/sch_choke.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index a1cec18..ee1e209 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/reciprocal_div.h>
+#include <linux/vmalloc.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
 #include <net/red.h>
-- 
1.7.4

