From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] fix typo in net/ipv4/ip_input.c
Date: Fri, 12 Sep 2003 13:27:30 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912162729.GD8713@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Harald, Dave,

	Please apply.

- Arnaldo

===== net/ipv4/ip_input.c 1.18 vs edited =====
--- 1.18/net/ipv4/ip_input.c	Thu Sep 11 20:46:34 2003
+++ edited/net/ipv4/ip_input.c	Fri Sep 12 16:17:06 2003
@@ -201,7 +201,7 @@
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	nf_debug_ip_local_deliver(skb);
-	skb->nf_debug =3D 0;
+	skb->nf_debug = 0;
 #endif /*CONFIG_NETFILTER_DEBUG*/
 
 	__skb_pull(skb, ihl);
