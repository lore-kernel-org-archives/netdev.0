From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/7] netfilter: cleanup struct nf_hook_ops struct indentation
Date: Fri, 10 Apr 2015 14:15:39 +0200
Message-ID: <1428668142-4006-5-git-send-email-pablo@netfilter.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40080 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755909AbbDJMLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 08:11:47 -0400
In-Reply-To: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index a605ebe..49d0063 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -82,16 +82,16 @@ typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
 			       const struct nf_hook_state *state);
 
 struct nf_hook_ops {
-	struct list_head list;
+	struct list_head 	list;
 
 	/* User fills in from here down. */
-	nf_hookfn	*hook;
-	struct module	*owner;
-	void		*priv;
-	u_int8_t	pf;
-	unsigned int	hooknum;
+	nf_hookfn		*hook;
+	struct module		*owner;
+	void			*priv;
+	u_int8_t		pf;
+	unsigned int		hooknum;
 	/* Hooks are ordered in ascending priority. */
-	int		priority;
+	int			priority;
 };
 
 struct nf_sockopt_ops {
-- 
1.7.10.4
