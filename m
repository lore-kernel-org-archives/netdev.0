From: janitor@sternwelten.at
Subject: [patch 2/4]  list_for_each: net-ipv6-ip6_fib.c
Date: Sat, 20 Nov 2004 03:45:03 +0100
Message-ID: <E1CVLFI-0002EK-6k@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, domen@coderock.org
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

---

 linux-2.6.10-rc2-bk4-max/net/ipv6/ip6_fib.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipv6/ip6_fib.c~list-for-each-drivers_net_ipv6_ip6_fib net/ipv6/ip6_fib.c
--- linux-2.6.10-rc2-bk4/net/ipv6/ip6_fib.c~list-for-each-drivers_net_ipv6_ip6_fib	2004-11-19 17:15:17.000000000 +0100
+++ linux-2.6.10-rc2-bk4-max/net/ipv6/ip6_fib.c	2004-11-19 17:15:17.000000000 +0100
@@ -99,7 +99,7 @@ struct fib6_walker_t fib6_walker_list = 
 	.next	= &fib6_walker_list, 
 };
 
-#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
+#define FOR_WALKERS(w) list_for_each((w), &fib6_walker_list)
 
 static __inline__ u32 fib6_new_sernum(void)
 {
_
