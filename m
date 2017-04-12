From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next] nf_tables: remove double return statement
Date: Wed, 12 Apr 2017 16:12:28 -0400
Message-ID: <20170412201228.13585-1-aconole@bytheb.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/netfilter/nf_tables_api.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2d822d2..1452fb7 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4435,8 +4435,6 @@ static int nf_tables_getobj(struct net *net, struct sock *nlsk,
 err:
 	kfree_skb(skb2);
 	return err;
-
-	return 0;
 }
 
 static void nft_obj_destroy(struct nft_object *obj)
-- 
2.9.3
