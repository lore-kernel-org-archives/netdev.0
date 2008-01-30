From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH][net/sched/sch_teql.c] duplicate IFF_BROADCAST in FMASK, remove
 2nd
Date: Wed, 30 Jan 2008 15:36:44 +0100
Message-ID: <47A08B7C.9010205@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760650AbYA3OhB@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Untested patch below, please confirm it's the right fix (should it be some
other IFF_*?)
--
duplicate IFF_BROADCAST, remove 2nd

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index c0ed06d..a53acf4 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -71,7 +71,7 @@ struct teql_sched_data
 
 #define NEXT_SLAVE(q) (((struct teql_sched_data*)qdisc_priv(q))->next)
 
-#define FMASK (IFF_BROADCAST|IFF_POINTOPOINT|IFF_BROADCAST)
+#define FMASK (IFF_BROADCAST|IFF_POINTOPOINT)
 
 /* "teql*" qdisc routines */
 
