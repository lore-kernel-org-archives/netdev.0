From: pablo@netfilter.org
Subject: [PATCH 4/4] netfilter: nf_ct_h323: fix usage of MODULE_ALIAS_NFCT_HELPER
Date: Mon, 14 May 2012 13:47:03 +0200
Message-ID: <1336996023-20249-5-git-send-email-pablo@netfilter.org>
References: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

ctnetlink uses the aliases that are created by MODULE_ALIAS_NFCT_HELPER
to auto-load the module based on the helper name. Thus, we have to use
RAS, Q.931 and H.245, not H.323.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_h323_main.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 722291f..b7bf187 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1833,4 +1833,6 @@ MODULE_AUTHOR("Jing Min Zhao <zhaojingmin@users.sourceforge.net>");
 MODULE_DESCRIPTION("H.323 connection tracking helper");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ip_conntrack_h323");
-MODULE_ALIAS_NFCT_HELPER("h323");
+MODULE_ALIAS_NFCT_HELPER("RAS");
+MODULE_ALIAS_NFCT_HELPER("Q.931");
+MODULE_ALIAS_NFCT_HELPER("H.245");
-- 
1.7.10

