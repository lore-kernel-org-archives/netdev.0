From: pablo@netfilter.org
Subject: [PATCH 25/25] netfilter: selinux: switch hook PFs to nfproto
Date: Mon, 11 Jun 2012 16:44:01 +0200
Message-ID: <1339425841-24171-26-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32960 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755432Ab2FKOpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:45:14 -0400
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alban Crequy <alban.crequy@collabora.co.uk>

This patch is a cleanup. Use NFPROTO_* for consistency with other
netfilter code.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 security/selinux/hooks.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 372ec65..4ee6f23 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -5763,21 +5763,21 @@ static struct nf_hook_ops selinux_ipv4_ops[] = {
 	{
 		.hook =		selinux_ipv4_postroute,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET,
+		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_POST_ROUTING,
 		.priority =	NF_IP_PRI_SELINUX_LAST,
 	},
 	{
 		.hook =		selinux_ipv4_forward,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET,
+		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
 	},
 	{
 		.hook =		selinux_ipv4_output,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET,
+		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_LOCAL_OUT,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
 	}
@@ -5789,14 +5789,14 @@ static struct nf_hook_ops selinux_ipv6_ops[] = {
 	{
 		.hook =		selinux_ipv6_postroute,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET6,
+		.pf =		NFPROTO_IPV6,
 		.hooknum =	NF_INET_POST_ROUTING,
 		.priority =	NF_IP6_PRI_SELINUX_LAST,
 	},
 	{
 		.hook =		selinux_ipv6_forward,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET6,
+		.pf =		NFPROTO_IPV6,
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP6_PRI_SELINUX_FIRST,
 	}
-- 
1.7.10
