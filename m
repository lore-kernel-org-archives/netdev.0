From: domen@coderock.org
Subject: [patch 01/26] list_for_each: net-ipv6-ip6_fib.c
Date: Sun, 06 Mar 2005 11:32:38 +0100
Message-ID: <20050306103238.86F181E46E@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, janitor@sternwelten.at
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




s/for/list_for_each/
Compile tested.

Signed-off-by: Domen Puncer <domen@coderock.org>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/net/ipv6/ip6_fib.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipv6/ip6_fib.c~list-for-each-drivers_net_ipv6_ip6_fib net/ipv6/ip6_fib.c
--- kj/net/ipv6/ip6_fib.c~list-for-each-drivers_net_ipv6_ip6_fib	2005-03-05 16:09:09.000000000 +0100
+++ kj-domen/net/ipv6/ip6_fib.c	2005-03-05 16:09:09.000000000 +0100
@@ -99,7 +99,7 @@ struct fib6_walker_t fib6_walker_list = 
 	.next	= &fib6_walker_list, 
 };
 
-#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
+#define FOR_WALKERS(w) list_for_each((w), &fib6_walker_list)
 
 static __inline__ u32 fib6_new_sernum(void)
 {
_
