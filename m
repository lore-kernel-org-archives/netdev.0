From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/3] IPV6: remove unused variable
Date: Fri, 04 Jul 2003 18:37:01 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030704.183701.131986831.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

2/3: remove unused variable

This patch, depends on "[PATCH 1/3] IPV6: ignore on-link 
information without on-link flag set," removes unused
variable in prefix informatio handler.

Thanks.

--- linux-2.5/net/ipv6/addrconf.c~	Fri Jul  4 17:57:05 2003
+++ linux-2.5/net/ipv6/addrconf.c	Fri Jul  4 17:56:28 2003
@@ -1380,10 +1380,7 @@
 	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
 		struct inet6_ifaddr * ifp;
 		struct in6_addr addr;
-		int plen;
 		int create = 0;
-
-		plen = pinfo->prefix_len >> 3;
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
