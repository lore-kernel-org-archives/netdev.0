From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Typo in address comparison
Date: Mon, 27 Oct 2003 01:45:02 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031027.014502.98736584.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Typo found in the local address comparison among sockets.

===== net/ipv6/addrconf.c 1.71 vs edited =====
--- 1.71/net/ipv6/addrconf.c	Tue Oct 21 14:59:11 2003
+++ edited/net/ipv6/addrconf.c	Mon Oct 27 01:35:11 2003
@@ -992,7 +992,7 @@
 	    !ipv6_addr_cmp(&np->rcv_saddr,
 			   (sk2->sk_state != TCP_TIME_WAIT ?
 			    &inet6_sk(sk2)->rcv_saddr :
-			    &tcptw_sk(sk)->tw_v6_rcv_saddr)))
+			    &tcptw_sk(sk2)->tw_v6_rcv_saddr)))
 		return 1;
 
 	if (addr_type == IPV6_ADDR_MAPPED &&

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
