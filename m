From: akpm@osdl.org
Subject: [patch 1/1] addrconf.h build fix
Date: Tue, 03 May 2005 21:55:40 -0700
Message-ID: <200505040456.j444u6sS004479@shell0.pdx.osdl.net>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On ppc64:

In file included from net/ipv6/xfrm6_policy.c:18:
include/net/addrconf.h:40: error: field `prefix' has incomplete type

This surely patch isn't right, and might break userspace inclusion of this
header file.


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/net/addrconf.h |    2 ++
 1 files changed, 2 insertions(+)

diff -puN include/net/addrconf.h~addrconf-build-fix include/net/addrconf.h
--- 25/include/net/addrconf.h~addrconf-build-fix	2005-05-04 04:47:24.000000000 -0600
+++ 25-akpm/include/net/addrconf.h	2005-05-04 04:47:39.000000000 -0600
@@ -1,6 +1,8 @@
 #ifndef _ADDRCONF_H
 #define _ADDRCONF_H
 
+#include <linux/in6.h>
+
 #define RETRANS_TIMER	HZ
 
 #define MAX_RTR_SOLICITATIONS		3
_
