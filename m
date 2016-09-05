From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/29] netfilter: physdev: add missed blank
Date: Mon,  5 Sep 2016 12:58:17 +0200
Message-ID: <1473073124-5015-3-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35070 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932226AbcIEK64 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:58:56 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B64092EFEA7
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A61A81150D9
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9D15F114D6B
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:52 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_physdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index e5f1898..bb33598 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -107,8 +107,8 @@ static int physdev_mt_check(const struct xt_mtchk_param *par)
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
 	    par->hook_mask & ((1 << NF_INET_LOCAL_OUT) |
 	    (1 << NF_INET_FORWARD) | (1 << NF_INET_POST_ROUTING))) {
-		pr_info("using --physdev-out and --physdev-is-out are only"
-			"supported in the FORWARD and POSTROUTING chains with"
+		pr_info("using --physdev-out and --physdev-is-out are only "
+			"supported in the FORWARD and POSTROUTING chains with "
 			"bridged traffic.\n");
 		if (par->hook_mask & (1 << NF_INET_LOCAL_OUT))
 			return -EINVAL;
-- 
2.1.4
