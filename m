From: kaber@trash.net
Subject: [PATCH 30/37] netfilter: xt_connlimit: use kmalloc() instead of kzalloc()
Date: Tue, 15 Mar 2011 20:44:10 +0100
Message-ID: <1300218257-26953-31-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

All the members are initialized after kzalloc().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_connlimit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
-- 
1.7.2.3

