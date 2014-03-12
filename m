From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/6] netfilter: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:04:19 -0700
Message-ID: <d0259d9122d308e3297cac6f7bc47c9955c3597b.1394643455.git.joe@perches.com>
References: <cover.1394643455.git.joe@perches.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/ipset/pfxlen.c | 4 ++--
 net/netfilter/xt_AUDIT.c     | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipset/pfxlen.c b/net/netfilter/ipset/pfxlen.c
index 4f29fa9..04d15fd 100644
--- a/net/netfilter/ipset/pfxlen.c
+++ b/net/netfilter/ipset/pfxlen.c
@@ -7,8 +7,8 @@
 
 #define E(a, b, c, d) \
 	{.ip6 = { \
-		__constant_htonl(a), __constant_htonl(b), \
-		__constant_htonl(c), __constant_htonl(d), \
+		htonl(a), htonl(b), \
+		htonl(c), htonl(d), \
 	} }
 
 /*
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index 3228d7f..4973cbd 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -146,11 +146,11 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 		if (par->family == NFPROTO_BRIDGE) {
 			switch (eth_hdr(skb)->h_proto) {
-			case __constant_htons(ETH_P_IP):
+			case htons(ETH_P_IP):
 				audit_ip4(ab, skb);
 				break;
 
-			case __constant_htons(ETH_P_IPV6):
+			case htons(ETH_P_IPV6):
 				audit_ip6(ab, skb);
 				break;
 			}
-- 
1.8.1.2.459.gbcd45b4.dirty
