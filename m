From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] htb: remove two unnecessary assignments
Date: Fri,  4 Jun 2010 19:33:33 +0800
Message-ID: <1275651213-3343-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:43812 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab0FDNdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 09:33:05 -0400
Received: by pvg16 with SMTP id 16so561642pvg.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 06:33:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove two unnecessary assignments

we don't need to assign NULL when initialize structure objects.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/sch_htb.c |    2 --
 1 file changed, 2 deletions(-)
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0b52b8d..4be8d04 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1550,7 +1550,6 @@ static const struct Qdisc_class_ops htb_class_ops = {
 };
 
 static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
-	.next		=	NULL,
 	.cl_ops		=	&htb_class_ops,
 	.id		=	"htb",
 	.priv_size	=	sizeof(struct htb_sched),
@@ -1561,7 +1560,6 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.init		=	htb_init,
 	.reset		=	htb_reset,
 	.destroy	=	htb_destroy,
-	.change		=	NULL /* htb_change */,
 	.dump		=	htb_dump,
 	.owner		=	THIS_MODULE,
 };
