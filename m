From: Denis Efremov <yefremov.denis@gmail.com>
Subject: [PATCH 07/21] netfilter: nf_nat: remove inline marking of EXPORT_SYMBOL functions
Date: Thu,  9 May 2013 13:19:38 +0400
Message-ID: <1368091192-10245-2-git-send-email-yefremov.denis@gmail.com>
References: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Cc: Denis Efremov <yefremov.denis@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, netfilter@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org, ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EXPORT_SYMBOL and inline directives are contradictory to each other.
The patch fixes this inconsistency.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>
---
 net/netfilter/nf_nat_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 038eee5..38492e0 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -44,7 +44,7 @@ __nf_nat_l3proto_find(u8 family)
 	return rcu_dereference(nf_nat_l3protos[family]);
 }
 
-inline const struct nf_nat_l4proto *
+const struct nf_nat_l4proto *
 __nf_nat_l4proto_find(u8 family, u8 protonum)
 {
 	return rcu_dereference(nf_nat_l4protos[family][protonum]);
-- 
1.8.1.4
