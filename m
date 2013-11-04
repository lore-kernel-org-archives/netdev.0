From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: nf_tables: remove duplicated include from nf_tables_ipv4.c
Date: Mon,  4 Nov 2013 23:05:20 +0100
Message-ID: <1383602721-5728-5-git-send-email-pablo@netfilter.org>
References: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_tables_ipv4.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 8f7536b..0f4cbfe 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -16,7 +16,6 @@
 #include <net/netfilter/nf_tables.h>
 #include <net/net_namespace.h>
 #include <net/ip.h>
-#include <net/net_namespace.h>
 #include <net/netfilter/nf_tables_ipv4.h>
 
 static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
-- 
1.7.10.4

