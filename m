From: akpm@osdl.org
Subject: [patch 1/1] netfilter: ipt build fix
Date: Wed, 05 Jan 2005 22:39:21 -0800
Message-ID: <200501060639.j066dUd19597@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



*** Warning: "ipt_find_target" [net/sched/ipt.ko] undefined!


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/ipv4/netfilter/ip_tables.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN net/ipv4/netfilter/ip_tables.c~netfilter-ipt-build-fix net/ipv4/netfilter/ip_tables.c
--- 25/net/ipv4/netfilter/ip_tables.c~netfilter-ipt-build-fix	2005-01-05 22:43:32.000000000 -0800
+++ 25-akpm/net/ipv4/netfilter/ip_tables.c	2005-01-05 22:43:41.000000000 -0800
@@ -488,6 +488,7 @@ struct ipt_target *ipt_find_target(const
 		return NULL;
 	return target;
 }
+EXPORT_SYMBOL(ipt_find_target);
 
 static int match_revfn(const char *name, u8 revision, int *bestp)
 {
_
