From: kaber@trash.net
Subject: [PATCH 08/79] netfilter: nf_nat: define nat_pptp_info as needed
Date: Wed, 19 Jan 2011 20:14:08 +0100
Message-ID: <1295464519-21763-9-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51975 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552Ab1ASTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:26 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_nat.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index e966092..aff80b1 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -56,7 +56,9 @@ struct nf_nat_multi_range_compat {
 /* per conntrack: nat application helper private data */
 union nf_conntrack_nat_help {
 	/* insert nat helper private data here */
+#if defined(CONFIG_NF_NAT_PPTP) || defined(CONFIG_NF_NAT_PPTP_MODULE)
 	struct nf_nat_pptp nat_pptp_info;
+#endif
 };
 
 struct nf_conn;
-- 
1.7.2.3

