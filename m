From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/4] netfilter: xt_connlimit: use kmalloc() instead of kzalloc()
Date: Mon, 14 Mar 2011 14:50:12 +0800
Message-ID: <1300085414-27275-2-git-send-email-xiaosuo@gmail.com>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the members are initialized after kzalloc().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/xt_connlimit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 1f4b9f9..ade2a80 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -162,7 +162,7 @@ static int count_them(struct net *net,
 
 	if (addit) {
 		/* save the new connection in our list */
-		conn = kzalloc(sizeof(*conn), GFP_ATOMIC);
+		conn = kmalloc(sizeof(*conn), GFP_ATOMIC);
 		if (conn == NULL)
 			return -ENOMEM;
 		conn->tuple = *tuple;
