From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: spelling correction
Date: Wed, 11 Feb 2004 03:28:02 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211.032802.74694162.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

D: spelling correction for net/ipv6
D: This patch also removes some XXX.

Thanks.

===== net/ipv6/addrconf.c 1.91 vs edited =====
--- 1.91/net/ipv6/addrconf.c	Tue Feb  3 03:31:58 2004
+++ edited/net/ipv6/addrconf.c	Wed Feb 11 02:11:58 2004
@@ -1071,7 +1071,7 @@
 		eui[0] ^= 2;
 		return 0;
 	case ARPHRD_ARCNET:
-		/* XXX: inherit EUI-64 fro mother interface -- yoshfuji */
+		/* XXX: inherit EUI-64 from other interface -- yoshfuji */
 		if (dev->addr_len != ARCNET_ALEN)
 			return -1;
 		memset(eui, 0, 7);
===== net/ipv6/ip6_fib.c 1.22 vs edited =====
--- 1.22/net/ipv6/ip6_fib.c	Sun Jan 25 03:09:52 2004
+++ edited/net/ipv6/ip6_fib.c	Wed Feb 11 02:30:58 2004
@@ -85,7 +85,7 @@
 
 /*
  *	A routing update causes an increase of the serial number on the
- *	afected subtree. This allows for cached routes to be asynchronously
+ *	affected subtree. This allows for cached routes to be asynchronously
  *	tested when modifications are made to the destination cache as a
  *	result of redirects, path MTU changes, etc.
  */
===== net/ipv6/exthdrs.c 1.16 vs edited =====
--- 1.16/net/ipv6/exthdrs.c	Mon Feb  9 05:54:02 2004
+++ edited/net/ipv6/exthdrs.c	Wed Feb 11 02:30:29 2004
@@ -120,7 +120,7 @@
 			for (curr=procs; curr->type >= 0; curr++) {
 				if (curr->type == skb->nh.raw[off]) {
 					/* type specific length/alignment 
-					   checks will be perfomed in the 
+					   checks will be performed in the 
 					   func(). */
 					if (curr->func(skb, off) == 0)
 						return 0;
===== net/ipv6/ndisc.c 1.71 vs edited =====
--- 1.71/net/ipv6/ndisc.c	Tue Feb 10 04:13:09 2004
+++ edited/net/ipv6/ndisc.c	Wed Feb 11 02:12:13 2004
@@ -747,7 +747,7 @@
 			return;
 		}
 
-		/* XXX: RFC2461 7.1.1:
+		/* RFC2461 7.1.1:
 	 	 *	If the IP source address is the unspecified address, 
 		 *	there MUST NOT be source link-layer address option 
 		 *	in the message.
@@ -1195,7 +1195,7 @@
 		return;
 	}
 
-	/* XXX: RFC2461 8.1: 
+	/* RFC2461 8.1: 
 	 *	The IP source address of the Redirect MUST be the same as the current
 	 *	first-hop router for the specified ICMP Destination Address.
 	 */
===== net/ipv6/raw.c 1.48 vs edited =====
--- 1.48/net/ipv6/raw.c	Thu Jan 29 09:06:25 2004
+++ edited/net/ipv6/raw.c	Wed Feb 11 02:39:30 2004
@@ -222,7 +222,7 @@
 		}
 		
 		/* ipv4 addr of the socket is invalid.  Only the
-		 * unpecified and mapped address have a v4 equivalent.
+		 * unspecified and mapped address have a v4 equivalent.
 		 */
 		v4addr = LOOPBACK4_IPV6;
 		if (!(addr_type & IPV6_ADDR_MULTICAST))	{
@@ -306,7 +306,7 @@
  *	This is next to useless... 
  *	if we demultiplex in network layer we don't need the extra call
  *	just to queue the skb... 
- *	maybe we could have the network decide uppon a hint if it 
+ *	maybe we could have the network decide upon a hint if it 
  *	should call raw_rcv for demultiplexing
  */
 int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
@@ -627,7 +627,7 @@
 
 	if (ipv6_addr_any(daddr)) {
 		/* 
-		 * unspecfied destination address 
+		 * unspecified destination address 
 		 * treated as error... is this correct ?
 		 */
 		fl6_sock_release(flowlabel);
===== net/ipv6/route.c 1.63 vs edited =====
--- 1.63/net/ipv6/route.c	Sun Jan 25 03:09:52 2004
+++ edited/net/ipv6/route.c	Wed Feb 11 02:38:57 2004
@@ -223,7 +223,7 @@
 			match = sprt;
 			mpri = m;
 			if (m >= 12) {
-				/* we choose the lastest default router if it
+				/* we choose the last default router if it
 				 * is in (probably) reachable state.
 				 * If route changed, we should do pmtu
 				 * discovery. --yoshfuji
===== net/ipv6/ip6_tunnel.c 1.16 vs edited =====
--- 1.16/net/ipv6/ip6_tunnel.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/ip6_tunnel.c	Wed Feb 11 02:37:02 2004
@@ -399,7 +399,7 @@
 	__u16 len;
 
 	/* If the packet doesn't contain the original IPv6 header we are 
-	   in trouble since we might need the source address for furter 
+	   in trouble since we might need the source address for further 
 	   processing of the error. */
 
 	read_lock(&ip6ip6_lock);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
