From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV4: spelling correction
Date: Wed, 11 Feb 2004 03:33:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211.033324.120562092.yoshfuji@linux-ipv6.org>
References: <20040211.032831.67897970.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040211.032831.67897970.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040211.032831.67897970.yoshfuji@linux-ipv6.org> (at Wed, 11 Feb 2004 03:28:31 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

>     Well, I wonder, rfc1812 was written by Cisco employee,
> -   what the hell these idiots break standrads established
> -   by themself???
> +   what the hell these idiots break standrards established
> +   by themselves???

Oops, this also includes a typo. Please use this instead.

===== net/ipv4/ip_gre.c 1.34 vs edited =====
--- 1.34/net/ipv4/ip_gre.c	Tue Oct 28 18:13:14 2003
+++ edited/net/ipv4/ip_gre.c	Wed Feb 11 03:30:06 2004
@@ -316,8 +316,8 @@
    GRE tunnels with enabled checksum. Tell them "thank you".
 
    Well, I wonder, rfc1812 was written by Cisco employee,
-   what the hell these idiots break standrads established
-   by themself???
+   what the hell these idiots break standards established
+   by themselves???
  */
 
 	struct iphdr *iph = (struct iphdr*)skb->data;
===== net/ipv4/ip_output.c 1.49 vs edited =====
--- 1.49/net/ipv4/ip_output.c	Wed Feb  4 03:24:11 2004
+++ edited/net/ipv4/ip_output.c	Wed Feb 11 03:29:42 2004
@@ -35,7 +35,7 @@
  *		Andi Kleen	: 	Replace ip_reply with ip_send_reply.
  *		Andi Kleen	:	Split fast and slow ip_build_xmit path 
  *					for decreased register pressure on x86 
- *					and more readibility. 
+ *					and more readability. 
  *		Marc Boucher	:	When call_out_firewall returns FW_QUEUE,
  *					silently drop skb instead of failing with -EPERM.
  *		Detlev Wengorz	:	Copy protocol for fragments.
===== net/ipv4/proc.c 1.15 vs edited =====
--- 1.15/net/ipv4/proc.c	Fri Sep 12 10:08:45 2003
+++ edited/net/ipv4/proc.c	Wed Feb 11 03:29:42 2004
@@ -24,7 +24,7 @@
  *	Gerhard Koerting	:	Show both timers
  *		Alan Cox	:	Allow inode to be NULL (kernel socket)
  *	Andi Kleen		:	Add support for open_requests and
- *					split functions for more readibility.
+ *					split functions for more readability.
  *	Andi Kleen		:	Add support for /proc/net/netstat
  *	Arnaldo C. Melo		:	Convert to seq_file
  *
===== net/ipv4/tcp_input.c 1.49 vs edited =====
--- 1.49/net/ipv4/tcp_input.c	Mon Feb  2 04:22:45 2004
+++ edited/net/ipv4/tcp_input.c	Wed Feb 11 03:29:42 2004
@@ -42,7 +42,7 @@
  *		Andi Kleen	:	Moved open_request checking here
  *					and process RSTs for open_requests.
  *		Andi Kleen	:	Better prune_queue, and other fixes.
- *		Andrey Savochkin:	Fix RTT measurements in the presnce of
+ *		Andrey Savochkin:	Fix RTT measurements in the presence of
  *					timestamps.
  *		Andrey Savochkin:	Check sequence numbers correctly when
  *					removing SACKs due to in sequence incoming
@@ -283,7 +283,7 @@
 		sk->sk_rcvbuf = min(4 * rcvmem, sysctl_tcp_rmem[2]);
 }
 
-/* 4. Try to fixup all. It is made iimediately after connection enters
+/* 4. Try to fixup all. It is made immediately after connection enters
  *    established state.
  */
 static void tcp_init_buffer_space(struct sock *sk)
@@ -392,7 +392,7 @@
 			if (tp->ack.ato > tp->rto)
 				tp->ack.ato = tp->rto;
 		} else if (m > tp->rto) {
-			/* Too long gap. Apparently sender falled to
+			/* Too long gap. Apparently sender fellen to
 			 * restart window, so that we send ACKs quickly.
 			 */
 			tcp_incr_quickack(tp);
@@ -431,7 +431,7 @@
 	 *
 	 * Funny. This algorithm seems to be very broken.
 	 * These formulae increase RTO, when it should be decreased, increase
-	 * too slowly, when it should be incresed fastly, decrease too fastly
+	 * too slowly, when it should be increased fastly, decrease too fastly
 	 * etc. I guess in BSD RTO takes ONE value, so that it is absolutely
 	 * does not matter how to _calculate_ it. Seems, it was trap
 	 * that VJ failed to avoid. 8)
@@ -493,14 +493,14 @@
 	 *    at least by solaris and freebsd. "Erratic ACKs" has _nothing_
 	 *    to do with delayed acks, because at cwnd>2 true delack timeout
 	 *    is invisible. Actually, Linux-2.4 also generates erratic
-	 *    ACKs in some curcumstances.
+	 *    ACKs in some circumstances.
 	 */
 	tp->rto = (tp->srtt >> 3) + tp->rttvar;
 
 	/* 2. Fixups made earlier cannot be right.
 	 *    If we do not estimate RTO correctly without them,
 	 *    all the algo is pure shit and should be replaced
-	 *    with correct one. It is exaclty, which we pretend to do.
+	 *    with correct one. It is exactly, which we pretend to do.
 	 */
 }
 
@@ -654,7 +654,7 @@
 	 * to make it more realistic.
 	 *
 	 * A bit of theory. RTT is time passed after "normal" sized packet
-	 * is sent until it is ACKed. In normal curcumstances sending small
+	 * is sent until it is ACKed. In normal circumstances sending small
 	 * packets force peer to delay ACKs and calculation is correct too.
 	 * The algorithm is adaptive and, provided we follow specs, it
 	 * NEVER underestimate RTT. BUT! If peer tries to make some clever
@@ -728,7 +728,7 @@
  * L|R	1		- orig is lost, retransmit is in flight.
  * S|R  1		- orig reached receiver, retrans is still in flight.
  * (L|S|R is logically valid, it could occur when L|R is sacked,
- *  but it is equivalent to plain S and code short-curcuits it to S.
+ *  but it is equivalent to plain S and code short-circuits it to S.
  *  L|S is logically invalid, it would mean -1 packet in flight 8))
  *
  * These 6 states form finite state machine, controlled by the following events:
@@ -2194,7 +2194,7 @@
 /*
  * @__westwood_fast_bw
  * It is called when we are in fast path. In particular it is called when
- * header prediction is successfull. In such case infact update is
+ * header prediction is successfull. In such case in fact update is
  * straight forward and doesn't need any particular care.
  */
 void __tcp_westwood_fast_bw(struct sock *sk, struct sk_buff *skb)
@@ -3494,7 +3494,7 @@
 	 * urgent. To do this requires some care. We cannot just ignore
 	 * tp->copied_seq since we would read the last urgent byte again
 	 * as data, nor can we alter copied_seq until this data arrives
-	 * or we break the sematics of SIOCATMARK (and thus sockatmark())
+	 * or we break the semantics of SIOCATMARK (and thus sockatmark())
 	 *
 	 * NOTE. Double Dutch. Rendering to plain English: author of comment
 	 * above did something sort of 	send("A", MSG_OOB); send("B", MSG_OOB);
@@ -3638,7 +3638,7 @@
 	tp->saw_tstamp = 0;
 
 	/*	pred_flags is 0xS?10 << 16 + snd_wnd
-	 *	if header_predition is to be made
+	 *	if header_prediction is to be made
 	 *	'S' will always be tp->tcp_header_len >> 2
 	 *	'?' will be 0 for the fast path, otherwise pred_flags is 0 to
 	 *  turn it off	(when there are holes in the receive 
===== net/ipv4/tcp_minisocks.c 1.43 vs edited =====
--- 1.43/net/ipv4/tcp_minisocks.c	Tue Oct 28 20:10:47 2003
+++ edited/net/ipv4/tcp_minisocks.c	Wed Feb 11 03:29:42 2004
@@ -216,7 +216,7 @@
 		/* In window segment, it may be only reset or bare ack. */
 
 		if (th->rst) {
-			/* This is TIME_WAIT assasination, in two flavors.
+			/* This is TIME_WAIT assassination, in two flavors.
 			 * Oh well... nobody has a sufficient solution to this
 			 * protocol bug yet.
 			 */

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
