From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/23] netfilter: nf_tables: remove unused struct members
Date: Fri, 18 Dec 2015 21:26:38 +0100
Message-ID: <1450470409-31427-13-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58063 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965199AbbLRUeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 00EA113BC2A
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 744B6DA86D
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id DE68AD1DA2
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:59 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 4bd7508..101d7d7 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -19,8 +19,6 @@ struct nft_pktinfo {
 	const struct net_device		*out;
 	u8				pf;
 	u8				hook;
-	u8				nhoff;
-	u8				thoff;
 	u8				tprot;
 	/* for x_tables compatibility */
 	struct xt_action_param		xt;
-- 
2.1.4
