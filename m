From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: note on shared socket options
Date: Wed, 04 Feb 2004 20:37:39 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204.203739.16838230.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

There're several socket options for multicast
shared between IPv4 and IPv6.
Add a note that some range is already used for them.

(Alternatevely, we could define other names like this:
 #define IPV6_MCAST_JOIN_GROUP   MCAST_JOIN_GROUP
 #define IPV6_MCAST_BLOCK_SOURCE MCAST_BLOCK_SOURCE
 /* bla, bla ... */
)

===== include/linux/in6.h 1.5 vs edited =====
--- 1.5/include/linux/in6.h	Fri Mar 21 14:23:30 2003
+++ edited/include/linux/in6.h	Wed Feb  4 20:30:47 2004
@@ -183,5 +183,17 @@
 #define IPV6_IPSEC_POLICY	34
 #define IPV6_XFRM_POLICY	35
 
+/*
+ * Multicast:
+ * Following socket options are shared between IPv4 and IPv6.
+ *
+ * MCAST_JOIN_GROUP		42
+ * MCAST_BLOCK_SOURCE		43
+ * MCAST_UNBLOCK_SOURCE		44
+ * MCAST_LEAVE_GROUP		45
+ * MCAST_JOIN_SOURCE_GROUP	46
+ * MCAST_LEAVE_SOURCE_GROUP	47
+ * MCAST_MSFILTER		48
+ */
 
 #endif

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
