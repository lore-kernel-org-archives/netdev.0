From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [PATCH][IPV6] export inet6_sock_nr
Date: Sun, 17 Apr 2005 19:54:33 -0300
Message-ID: <20050417225433.GC10626@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please apply, SCTP/DCCP needs this.

                        - Arnaldo

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Index: net/ipv6/af_inet6.c
===================================================================
--- net/ipv6/af_inet6.c	(revision 57)
+++ net/ipv6/af_inet6.c	(working copy)
@@ -88,6 +88,7 @@
 
 #ifdef INET_REFCNT_DEBUG
 atomic_t inet6_sock_nr;
+EXPORT_SYMBOL(inet6_sock_nr);
 #endif
 
 /* The inetsw table contains everything that inet_create needs to
