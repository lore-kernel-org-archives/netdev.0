From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH][Doc][Trivial] fix spelling error related to IPComp help in
 Kconfig
Date: Tue, 26 Oct 2004 20:44:35 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410262038040.3277@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>,
        Linux Kernel Trivial Patch Monkey <trivial@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Small patch that fixes a spelling error (Payload misspelled as Paylod)in 
the IPComp help text in Kconfig (also expands the text to "IP Payload 
Compression Protocol (IPComp)" which is the title of RFC3173).
Please consider applying.

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

diff -urp linux-2.6.10-rc1-bk5-orig/net/ipv4/Kconfig linux-2.6.10-rc1-bk5/net/ipv4/Kconfig
--- linux-2.6.10-rc1-bk5-orig/net/ipv4/Kconfig	2004-10-18 23:54:55.000000000 +0200
+++ linux-2.6.10-rc1-bk5/net/ipv4/Kconfig	2004-10-26 20:30:35.000000000 +0200
@@ -331,8 +331,8 @@ config INET_IPCOMP
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
-	  Support for IP Paylod Compression (RFC3173), typically needed
-	  for IPsec.
+	  Support for IP Payload Compression Protocol (IPComp) (RFC3173),
+	  typically needed for IPsec.
 	  
 	  If unsure, say Y.
 
diff -urp linux-2.6.10-rc1-bk5-orig/net/ipv6/Kconfig linux-2.6.10-rc1-bk5/net/ipv6/Kconfig
--- linux-2.6.10-rc1-bk5-orig/net/ipv6/Kconfig	2004-10-18 23:54:08.000000000 +0200
+++ linux-2.6.10-rc1-bk5/net/ipv6/Kconfig	2004-10-26 20:31:19.000000000 +0200
@@ -52,8 +52,8 @@ config INET6_IPCOMP
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
-	  Support for IP Paylod Compression (RFC3173), typically needed
-	  for IPsec.
+	  Support for IP Payload Compression Protocol (IPComp) (RFC3173),
+	  typically needed for IPsec.
 
 	  If unsure, say Y.
 
