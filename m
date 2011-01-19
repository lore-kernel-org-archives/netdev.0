From: kaber@trash.net
Subject: [PATCH 11/79] netfilter: nf_ct_frag6_sysctl_table is static
Date: Wed, 19 Jan 2011 20:14:11 +0100
Message-ID: <1295464519-21763-12-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51978 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab1ASTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:26 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 3a3f129..eb9f1c0 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -73,7 +73,7 @@ static struct inet_frags nf_frags;
 static struct netns_frags nf_init_frags;
 
 #ifdef CONFIG_SYSCTL
-struct ctl_table nf_ct_frag6_sysctl_table[] = {
+static struct ctl_table nf_ct_frag6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_frag6_timeout",
 		.data		= &nf_init_frags.timeout,
-- 
1.7.2.3

