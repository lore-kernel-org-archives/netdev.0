From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: mis-spelling
Date: Fri, 23 Jan 2004 10:02:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040123.100255.88151138.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: fix several mis-spellings / typoes in net/ipv6

===== net/ipv6/addrconf.c 1.88 vs edited =====
--- 1.88/net/ipv6/addrconf.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/addrconf.c	Fri Jan 23 09:48:31 2004
@@ -1338,7 +1338,7 @@
 	 *	2) Configure prefixes with the auto flag set
 	 */
 
-	/* Avoid arithemtic overflow. Really, we could
+	/* Avoid arithmetic overflow. Really, we could
 	   save rt_expires in seconds, likely valid_lft,
 	   but it would require division in fib gc, that it
 	   not good.
===== net/ipv6/exthdrs.c 1.13 vs edited =====
--- 1.13/net/ipv6/exthdrs.c	Tue Jun 24 17:33:31 2003
+++ edited/net/ipv6/exthdrs.c	Fri Jan 23 09:58:59 2004
@@ -367,7 +367,7 @@
 	   Inverted result:
 	   [ H_prev -> ... -> H1 ] daddr =sender
 
-	   Note, that IP output engine will rewrire this rthdr
+	   Note, that IP output engine will rewrite this rthdr
 	   by rotating it left by one addr.
 	 */
 
===== net/ipv6/ip6_fib.c 1.21 vs edited =====
--- 1.21/net/ipv6/ip6_fib.c	Fri Jul 11 18:17:06 2003
+++ edited/net/ipv6/ip6_fib.c	Fri Jan 23 09:48:15 2004
@@ -942,7 +942,7 @@
 			}
 			fn = fn->parent;
 		}
-		/* No more references are possiible at this point. */
+		/* No more references are possible at this point. */
 		if (atomic_read(&rt->rt6i_ref) != 1) BUG();
 	}
 
===== net/ipv6/reassembly.c 1.20 vs edited =====
--- 1.20/net/ipv6/reassembly.c	Sun Jun 29 19:38:51 2003
+++ edited/net/ipv6/reassembly.c	Fri Jan 23 09:55:41 2004
@@ -526,7 +526,7 @@
 		} else {
 			struct sk_buff *free_it = next;
 
-			/* Old fragmnet is completely overridden with
+			/* Old fragment is completely overridden with
 			 * new one drop it.
 			 */
 			next = next->next;
===== net/ipv6/route.c 1.62 vs edited =====
--- 1.62/net/ipv6/route.c	Tue Jan 20 14:15:52 2004
+++ edited/net/ipv6/route.c	Fri Jan 23 09:55:08 2004
@@ -785,7 +785,7 @@
 			/* IPv6 strictly inhibits using not link-local
 			   addresses as nexthop address.
 			   Otherwise, router will not able to send redirects.
-			   It is very good, but in some (rare!) curcumstances
+			   It is very good, but in some (rare!) circumstances
 			   (SIT, PtP, NBMA NOARP links) it is handy to allow
 			   some exceptions. --ANK
 			 */
@@ -1365,10 +1365,10 @@
 	 */
 	/*
 	   If new MTU is less than route PMTU, this new MTU will be the
-	   lowest MTU in the path, update the route PMTU to refect PMTU
+	   lowest MTU in the path, update the route PMTU to reflect PMTU
 	   decreases; if new MTU is greater than route PMTU, and the
 	   old MTU is the lowest MTU in the path, update the route PMTU
-	   to refect the increase. In this case if the other nodes' MTU
+	   to reflect the increase. In this case if the other nodes' MTU
 	   also have the lowest MTU, TOO BIG MESSAGE will be lead to
 	   PMTU discouvery.
 	 */

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
