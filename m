From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH v2] uapi: fix linux/ipv6_route.h userspace compilation errors
Date: Thu, 16 Feb 2017 18:04:14 +0300
Message-ID: <20170216150414.GA13804@altlinux.org>
References: <20170215200546.GE1028@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170215200546.GE1028@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include <linux/in6.h> to fix the following linux/ipv6_route.h userspace
compilation errors:

/usr/include/linux/ipv6_route.h:42:19: error: field 'rtmsg_dst' has incomplete type
  struct in6_addr  rtmsg_dst;
/usr/include/linux/ipv6_route.h:43:19: error: field 'rtmsg_src' has incomplete type
  struct in6_addr  rtmsg_src;
/ust/include/linux/ipv6_route.h:44:19: error: field 'rtmsg_gateway' has incomplete type
  struct in6_addr  rtmsg_gateway;

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
v2: Cc'ed netdev

 include/uapi/linux/ipv6_route.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
index f6598d1..85bbb17 100644
--- a/include/uapi/linux/ipv6_route.h
+++ b/include/uapi/linux/ipv6_route.h
@@ -14,6 +14,7 @@
 #define _UAPI_LINUX_IPV6_ROUTE_H
 
 #include <linux/types.h>
+#include <linux/in6.h>			/* For struct in6_addr. */
 
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
 #define RTF_ALLONLINK	0x00020000	/* (deprecated and will be removed)
-- 
ldv
