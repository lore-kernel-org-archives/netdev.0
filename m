From: akpm@osdl.org
Subject: [patch 3/4] ip_fw_compat_masq.c build fix
Date: Wed, 23 Jun 2004 23:30:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406240631.i5O6VXZ31250@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/ipv4/netfilter/ip_fw_compat_masq.c: In function `check_for_demasq':
net/ipv4/netfilter/ip_fw_compat_masq.c:165: error: 'IP_OFFSET' undeclared (first use in this function)
net/ipv4/netfilter/ip_fw_compat_masq.c:165: error: (Each undeclared identifier is reported only once
net/ipv4/netfilter/ip_fw_compat_masq.c:165: error: for each function it appears in.)


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/ipv4/netfilter/ip_fw_compat_masq.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN net/ipv4/netfilter/ip_fw_compat_masq.c~ip_fw_compat_masq-build-fix net/ipv4/netfilter/ip_fw_compat_masq.c
--- 25/net/ipv4/netfilter/ip_fw_compat_masq.c~ip_fw_compat_masq-build-fix	2004-06-23 23:30:10.094664248 -0700
+++ 25-akpm/net/ipv4/netfilter/ip_fw_compat_masq.c	2004-06-23 23:30:10.097663792 -0700
@@ -24,6 +24,7 @@
 #include <linux/proc_fs.h>
 #include <linux/module.h>
 #include <net/route.h>
+#include <net/ip.h>
 
 #define ASSERT_READ_LOCK(x) MUST_BE_READ_LOCKED(&ip_conntrack_lock)
 #define ASSERT_WRITE_LOCK(x) MUST_BE_WRITE_LOCKED(&ip_conntrack_lock)
_
