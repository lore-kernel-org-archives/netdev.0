From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: typo in include/linux/ipv6.h
Date: Fri, 08 Aug 2003 22:37:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808.223742.55652930.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Typo in definition in include/linux/ipv6.h.
2.4.x has similar bug, too.

Thanks.

Index: linux-2.6/include/linux/ipv6.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/linux/ipv6.h,v
retrieving revision 1.11
diff -u -r1.11 ipv6.h
--- linux-2.6/include/linux/ipv6.h	3 Aug 2003 18:34:10 -0000	1.11
+++ linux-2.6/include/linux/ipv6.h	8 Aug 2003 12:05:41 -0000
@@ -71,7 +71,7 @@
 	__u32			bitmap;		/* strict/loose bit map */
 	struct in6_addr		addr[0];
 
-#define rt0_type		rt_hdr.type;
+#define rt0_type		rt_hdr.type
 };
 
 struct ipv6_auth_hdr {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
