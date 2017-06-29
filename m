From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/29] netfilter: ctnetlink: delete extra spaces
Date: Fri, 30 Jun 2017 00:52:59 +0200
Message-ID: <1498776807-11124-2-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57568 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752071AbdF2Wxj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E4A23BDF49
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D1583D1CA3
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6CE8DDA7F1
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:23 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: linzhang <xiaolou4617@gmail.com>

This patch cleans up extra spaces.

Signed-off-by: linzhang <xiaolou4617@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9799a50bc604..f08604dd1a59 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -636,11 +636,11 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	if (events & (1 << IPCT_DESTROY)) {
 		type = IPCTNL_MSG_CT_DELETE;
 		group = NFNLGRP_CONNTRACK_DESTROY;
-	} else  if (events & ((1 << IPCT_NEW) | (1 << IPCT_RELATED))) {
+	} else if (events & ((1 << IPCT_NEW) | (1 << IPCT_RELATED))) {
 		type = IPCTNL_MSG_CT_NEW;
 		flags = NLM_F_CREATE|NLM_F_EXCL;
 		group = NFNLGRP_CONNTRACK_NEW;
-	} else  if (events) {
+	} else if (events) {
 		type = IPCTNL_MSG_CT_NEW;
 		group = NFNLGRP_CONNTRACK_UPDATE;
 	} else
-- 
2.1.4
