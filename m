From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6: Move comment to right place.
Date: Mon, 14 Jan 2013 11:02:06 +0900
Message-ID: <50F3671E.2090601@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38912 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753538Ab3ANCCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 21:02:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IN6ADDR_* and in6addr_* are not exported to userspace, and are defined
in include/linux/in6.h.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/in6.h      |    4 ++++
 include/uapi/linux/in6.h |    5 -----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 9e2ae26..a16e193 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -22,6 +22,10 @@
 
 #include <uapi/linux/in6.h>
 
+/* IPv6 Wildcard Address (::) and Loopback Address (::1) defined in RFC2553
+ * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
+ * in network byte order, not in host byte order as are the IPv4 equivalents
+ */
 extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
 extern const struct in6_addr in6addr_loopback;
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index f79c372..5673b97 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -38,11 +38,6 @@ struct in6_addr {
 #define s6_addr32		in6_u.u6_addr32
 };
 
-/* IPv6 Wildcard Address (::) and Loopback Address (::1) defined in RFC2553
- * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
- * in network byte order, not in host byte order as are the IPv4 equivalents
- */
-
 struct sockaddr_in6 {
 	unsigned short int	sin6_family;    /* AF_INET6 */
 	__be16			sin6_port;      /* Transport layer port # */
-- 
1.7.9.5
