From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Remove useless line in cbq_dump_class
Date: Mon, 4 Oct 2004 00:14:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003221452.GL14344@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove useless line in cbq_dump_class probably introduced by
copy&paste from cbq_dump.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc3-bk3.orig/net/sched/sch_cbq.c	2004-10-04 00:03:47.000000000 +0200
+++ linux-2.6.9-rc3-bk3/net/sched/sch_cbq.c	2004-10-04 00:07:32.000000000 +0200
@@ -1675,7 +1675,6 @@
 	cl->xstats.undertime = 0;
 	if (!PSCHED_IS_PASTPERFECT(cl->undertime))
 		cl->xstats.undertime = PSCHED_TDIFF(cl->undertime, q->now);
-	q->link.xstats.avgidle = q->link.avgidle;
 	if (cbq_copy_xstats(skb, &cl->xstats)) {
 		spin_unlock_bh(&sch->dev->queue_lock);
 		goto rtattr_failure;
