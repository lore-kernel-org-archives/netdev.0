From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: remove c99ism
Date: Sun, 16 Jan 2005 00:25:54 +0100
Message-ID: <20050115232554.GS26856@postel.suug.ch>
References: <20050115144010.33182075.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050115144010.33182075.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Andrew Morton <20050115144010.33182075.akpm@osdl.org> 2005-01-15 14:40
> net/sched/cls_api.c: In function `tcf_exts_validate':
> net/sched/cls_api.c:489: parse error before `int'
> net/sched/cls_api.c:493: `act' undeclared (first use in this function)
> net/sched/cls_api.c:493: (Each undeclared identifier is reported only once
> net/sched/cls_api.c:493: for each function it appears in.)
> net/sched/cls_api.c:494: `err' undeclared (first use in this function)

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11-rc1-bk2.orig/net/sched/cls_api.c	2005-01-16 00:04:40.000000000 +0100
+++ linux-2.6.11-rc1-bk2/net/sched/cls_api.c	2005-01-15 23:56:48.000000000 +0100
@@ -486,10 +486,9 @@
 	memset(exts, 0, sizeof(*exts));
 	
 #ifdef CONFIG_NET_CLS_ACT
-	int err;
-	struct tc_action *act;
-
 	if (map->police && tb[map->police-1]) {
+		int err;
+		struct tc_action *act;
 		act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
 			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
 		if (act == NULL)
@@ -498,6 +497,8 @@
 		act->type = TCA_OLD_COMPAT;
 		exts->action = act;
 	} else if (map->action && tb[map->action-1]) {
+		int err;
+		struct tc_action *act;
 		act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
 			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
 		if (act == NULL)
