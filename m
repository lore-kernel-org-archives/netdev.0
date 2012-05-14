From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 2/6] netfilter: decnet: switch hook PFs to nfproto
Date: Mon, 14 May 2012 14:56:35 +0100
Message-ID: <1337003799-2517-2-git-send-email-alban.crequy@collabora.co.uk>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48685 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756740Ab2ENN5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:57:07 -0400
In-Reply-To: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFPROTO_* constants were usually equal to PF_* constants but it is not
necessary and it will waste less memory if we don't do so (see commit 7e9c6e
"netfilter: Introduce NFPROTO_* constants")

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 net/decnet/netfilter/dn_rtmsg.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 1531135..7fb7250 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -118,7 +118,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 
 static struct nf_hook_ops dnrmg_ops __read_mostly = {
 	.hook		= dnrmg_hook,
-	.pf		= PF_DECnet,
+	.pf		= NFPROTO_DECNET,
 	.hooknum	= NF_DN_ROUTE,
 	.priority	= NF_DN_PRI_DNRTMSG,
 };
-- 
1.7.2.5
