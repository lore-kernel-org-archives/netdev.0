From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next]  hhf: make qdisc ops static
Date: Thu, 26 Dec 2013 10:09:05 -0800
Message-ID: <20131226100905.00ac74a2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Terry Lam <vtlam@google.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:54750 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505Ab3LZSJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:09:11 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so8519098pab.39
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 10:09:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This module shouldn't be randomly exporting symbols 

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/sched/sch_hhf.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/net/sched/sch_hhf.c	2013-12-24 15:14:54.398175948 -0800
+++ b/net/sched/sch_hhf.c	2013-12-24 15:16:02.409262185 -0800
@@ -711,7 +711,7 @@ static int hhf_dump_stats(struct Qdisc *
 	return gnet_stats_copy_app(d, &st, sizeof(st));
 }
 
-struct Qdisc_ops hhf_qdisc_ops __read_mostly = {
+static struct Qdisc_ops hhf_qdisc_ops __read_mostly = {
 	.id		=	"hhf",
 	.priv_size	=	sizeof(struct hhf_sched_data),
 
@@ -727,7 +727,6 @@ struct Qdisc_ops hhf_qdisc_ops __read_mo
 	.dump_stats	=	hhf_dump_stats,
 	.owner		=	THIS_MODULE,
 };
-EXPORT_SYMBOL(hhf_qdisc_ops);
 
 static int __init hhf_module_init(void)
 {
