From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: sch_plug: plug_qdisc_ops is static
Date: Mon, 13 Feb 2012 16:40:45 +0100
Message-ID: <1329147645.2494.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64712 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab2BMPkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 10:40:49 -0500
Received: by wgbdt10 with SMTP id dt10so5017711wgb.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 07:40:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/sched/sch_plug.c:211:18: warning: symbol 'plug_qdisc_ops' was not
declared. Should it be static?

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_plug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index ba7b737..89f8fcf 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -208,7 +208,7 @@ static int plug_change(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
-struct Qdisc_ops plug_qdisc_ops = {
+static struct Qdisc_ops plug_qdisc_ops __read_mostly = {
 	.id          =       "plug",
 	.priv_size   =       sizeof(struct plug_sched_data),
 	.enqueue     =       plug_enqueue,
