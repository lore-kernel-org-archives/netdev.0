From: kaber@trash.net
Subject: [PATCH 03/18] netfilter: nf_nat: add missing nla_policy entry for CTA_NAT_PROTO attribute
Date: Thu, 24 Nov 2011 17:57:14 +0100
Message-ID: <1322153850-10533-4-git-send-email-kaber@trash.net>
References: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47957 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756672Ab1KXQ5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 11:57:34 -0500
In-Reply-To: <1322153850-10533-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
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
1.7.1
