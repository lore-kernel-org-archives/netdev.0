From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV{4,6}: Fix one more inappropriate use of
 inet6_sk()->ipv6only
Date: Sat, 01 Nov 2003 20:01:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101.200132.55114465.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello. 

Sorry, I forgot to fix this one...

===== net/ipv4/tcp_ipv4.c 1.75 vs edited =====
--- 1.75/net/ipv4/tcp_ipv4.c	Tue Oct 28 20:10:47 2003
+++ edited/net/ipv4/tcp_ipv4.c	Sat Nov  1 19:36:45 2003
@@ -187,7 +187,7 @@
 
 	sk_for_each_bound(sk2, node, &tb->owners) {
 		if (sk != sk2 &&
-		    !ipv6_only_sock(sk2) &&
+		    !tcp_v6_ipv6only(sk2) &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
