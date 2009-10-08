From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] netlink: fix typo in initialization
Date: Thu, 8 Oct 2009 09:23:23 +0200
Message-ID: <20091008072323.GA3255@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbZJHHXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 03:23:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9ef1d4c7c7aca1cd436612b6ca785b726ffb8ed8 introduced a typo in
initialization. This patch fixes this.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6a53694..7cf6c0f 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -350,7 +350,7 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm__pad1 = 0;
-	tcm->tcm__pad1 = 0;
+	tcm->tcm__pad2 = 0;
 	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
 	tcm->tcm_parent = tp->classid;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
