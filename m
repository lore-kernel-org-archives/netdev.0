From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 2/2] Doc: Clean whitespaces in net/ipv4/Kconfig.
Date: Fri, 20 Feb 2009 16:04:26 +0100
Message-ID: <1235142266.2351.44.camel@localhost.localdomain>
References: <1235141957.2351.37.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kernel Janitors <kernel-janitors@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53228 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbZBTPE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 10:04:28 -0500
In-Reply-To: <1235141957.2351.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Fri Feb 20 15:35:40 2009 +0100

    Doc: Clean whitespaces in net/ipv4/Kconfig.
    
    While going through net/ipv4/Kconfig cleanup whitespaces.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 10c944d..c7a8148 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -53,7 +53,7 @@ config IP_ADVANCED_ROUTER
 
 	  If unsure, say N here.
 
-choice 
+choice
 	prompt "Choose IP: FIB lookup algorithm (choose FIB_HASH if unsure)"
 	depends on IP_ADVANCED_ROUTER
 	default ASK_IP_FIB_HASH
@@ -61,27 +61,29 @@ choice
 config ASK_IP_FIB_HASH
 	bool "FIB_HASH"
 	---help---
-	Current FIB is very proven and good enough for most users.
+	  Current FIB is very proven and good enough for most users.
 
 config IP_FIB_TRIE
 	bool "FIB_TRIE"
 	---help---
-	Use new experimental LC-trie as FIB lookup algorithm. 
-        This improves lookup performance if you have a large
-	number of routes.
-
-	LC-trie is a longest matching prefix lookup algorithm which
-	performs better than FIB_HASH for large routing tables.
-	But, it consumes more memory and is more complex.
-	
-	LC-trie is described in:
-	
- 	IP-address lookup using LC-tries. Stefan Nilsson and Gunnar Karlsson
- 	IEEE Journal on Selected Areas in Communications, 17(6):1083-1092, June 1999
-	An experimental study of compression methods for dynamic tries
- 	Stefan Nilsson and Matti Tikkanen. Algorithmica, 33(1):19-33, 2002.
- 	http://www.nada.kth.se/~snilsson/public/papers/dyntrie2/
-       
+	  Use new experimental LC-trie as FIB lookup algorithm.
+	  This improves lookup performance if you have a large
+	  number of routes.
+
+	  LC-trie is a longest matching prefix lookup algorithm which
+	  performs better than FIB_HASH for large routing tables.
+	  But, it consumes more memory and is more complex.
+
+	  LC-trie is described in:
+
+	  IP-address lookup using LC-tries. Stefan Nilsson and Gunnar Karlsson
+	  IEEE Journal on Selected Areas in Communications, 17(6):1083-1092,
+	  June 1999
+
+	  An experimental study of compression methods for dynamic tries
+	  Stefan Nilsson and Matti Tikkanen. Algorithmica, 33(1):19-33, 2002.
+	  http://www.nada.kth.se/~snilsson/public/papers/dyntrie2/
+
 endchoice
 
 config IP_FIB_HASH
@@ -193,7 +195,7 @@ config IP_PNP_RARP
 	  <file:Documentation/filesystems/nfsroot.txt> for details.
 
 # not yet ready..
-#   bool '    IP: ARP support' CONFIG_IP_PNP_ARP		
+#   bool '    IP: ARP support' CONFIG_IP_PNP_ARP
 config NET_IPIP
 	tristate "IP: tunneling"
 	select INET_TUNNEL
@@ -363,7 +365,7 @@ config INET_IPCOMP
 	---help---
 	  Support for IP Payload Compression Protocol (IPComp) (RFC3173),
 	  typically needed for IPsec.
-	  
+
 	  If unsure, say Y.
 
 config INET_XFRM_TUNNEL
@@ -417,7 +419,7 @@ config INET_DIAG
 	  Support for INET (TCP, DCCP, etc) socket monitoring interface used by
 	  native Linux tools such as ss. ss is included in iproute2, currently
 	  downloadable at <http://linux-net.osdl.org/index.php/Iproute2>.
-	  
+
 	  If unsure, say Y.
 
 config INET_TCP_DIAG

