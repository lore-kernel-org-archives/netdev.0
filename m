From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/21] netfilter: ipset: No need to make nomatch bitfield
Date: Mon, 18 May 2015 18:25:08 +0200
Message-ID: <1431966324-4494-6-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

We do not store cidr packed with no match, so there is no
need to make nomatch bitfield.

This simplifies mtype_data_reset_flags() a bit.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_netportnet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index bfaa94c..7cfd2df 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -54,7 +54,7 @@ struct hash_netportnet4_elem {
 		u16 ccmp;
 	};
 	u16 padding;
-	u8 nomatch:1;
+	u8 nomatch;
 	u8 proto;
 };
 
@@ -326,7 +326,7 @@ struct hash_netportnet6_elem {
 		u16 ccmp;
 	};
 	u16 padding;
-	u8 nomatch:1;
+	u8 nomatch;
 	u8 proto;
 };
 
-- 
1.7.10.4

