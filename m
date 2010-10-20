From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH 2/9] tproxy: added const specifiers to udp lookup functions
Date: Wed, 20 Oct 2010 13:21:18 +0200
Message-ID: <20101020112118.6260.46933.stgit@este.odu>
References: <20101020112118.6260.31618.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20101020112118.6260.31618.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

The parameters for various UDP lookup functions were non-const, even though
they could be const. TProxy has some const references and instead of
downcasting it, I added const specifiers along the path.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
---
 net/ipv6/udp.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5acb356..33e3683 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -122,8 +122,8 @@ static void udp_v6_rehash(struct sock *sk)
 
 static inline int compute_score(struct sock *sk, struct net *net,
 				unsigned short hnum,
-				struct in6_addr *saddr, __be16 sport,
-				struct in6_addr *daddr, __be16 dport,
+				const struct in6_addr *saddr, __be16 sport,
+				const struct in6_addr *daddr, __be16 dport,
 				int dif)
 {
 	int score = -1;
@@ -239,8 +239,8 @@ exact_match:
 }
 
 static struct sock *__udp6_lib_lookup(struct net *net,
-				      struct in6_addr *saddr, __be16 sport,
-				      struct in6_addr *daddr, __be16 dport,
+				      const struct in6_addr *saddr, __be16 sport,
+				      const struct in6_addr *daddr, __be16 dport,
 				      int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;


