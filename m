From: domen@coderock.org
Subject: [patch 01/19] list_for_each: net-ipv6-ip6_fib.c
Date: Wed, 12 Jan 2005 00:10:08 +0100
Message-ID: <20050111231008.B3A551F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Hi.

s/for/list_for_each/
Compile tested.

Signed-off-by: Domen Puncer <domen@coderock.org>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/net/ipv6/ip6_fib.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipv6/ip6_fib.c~list-for-each-drivers_net_ipv6_ip6_fib net/ipv6/ip6_fib.c
--- kj/net/ipv6/ip6_fib.c~list-for-each-drivers_net_ipv6_ip6_fib	2005-01-10 17:59:48.000000000 +0100
+++ kj-domen/net/ipv6/ip6_fib.c	2005-01-10 17:59:48.000000000 +0100
@@ -99,7 +99,7 @@ struct fib6_walker_t fib6_walker_list = 
 	.next	= &fib6_walker_list, 
 };
 
-#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
+#define FOR_WALKERS(w) list_for_each((w), &fib6_walker_list)
 
 static __inline__ u32 fib6_new_sernum(void)
 {
_
