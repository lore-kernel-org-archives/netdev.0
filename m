From: pablo@netfilter.org
Subject: [PATCH 12/19] netfilter: nf_nat: add missing nla_policy entry for CTA_NAT_PROTO attribute
Date: Sun, 25 Dec 2011 02:57:28 +0100
Message-ID: <1324778255-2830-13-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56016 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758031Ab1LYB6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:58:09 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 76600f8..610eb44 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -622,6 +622,7 @@ static int nfnetlink_parse_nat_proto(struct nlattr *attr,
 static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
 	[CTA_NAT_MINIP]		= { .type = NLA_U32 },
 	[CTA_NAT_MAXIP]		= { .type = NLA_U32 },
+	[CTA_NAT_PROTO]		= { .type = NLA_NESTED },
 };
 
 static int
-- 
1.7.2.5
