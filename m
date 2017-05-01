From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/53] netfilter: nf_tables: remove double return statement
Date: Mon,  1 May 2017 12:46:45 +0200
Message-ID: <1493635640-24325-19-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aaron Conole <aconole@bytheb.org>

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 22e191ad4468..91e9191a43d8 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4433,8 +4433,6 @@ static int nf_tables_getobj(struct net *net, struct sock *nlsk,
 err:
 	kfree_skb(skb2);
 	return err;
-
-	return 0;
 }
 
 static void nft_obj_destroy(struct nft_object *obj)
-- 
2.1.4

