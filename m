From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: cleanup struct nf_hook_ops indentation
Date: Wed, 29 Apr 2015 20:53:04 +0200
Message-ID: <1430333589-4940-2-git-send-email-pablo@netfilter.org>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 63560d0..83be4a3 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -79,16 +79,16 @@ typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
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

