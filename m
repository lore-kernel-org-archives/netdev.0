From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6 PKT_SCHED] Remove unneeded line
Date: Fri, 24 Sep 2004 18:28:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924162826.GB4079@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove unneeded line.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc2-bk7.orig/net/sched/sch_sfq.c	2004-09-21 23:27:31.000000000 +0200
+++ linux-2.6.9-rc2-bk7/net/sched/sch_sfq.c	2004-09-24 18:20:54.000000000 +0200
@@ -372,7 +372,6 @@
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
 	q->perturbation = net_random()&0x1F;
-	q->perturb_timer.expires = jiffies + q->perturb_period;
 
 	if (q->perturb_period) {
 		q->perturb_timer.expires = jiffies + q->perturb_period;
