From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 1/2] Doc: Fix rp_filter description in net/ipv4/Kconfig.
Date: Fri, 20 Feb 2009 16:03:13 +0100
Message-ID: <1235142193.2351.41.camel@localhost.localdomain>
References: <1235141957.2351.37.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kernel Janitors <kernel-janitors@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53153 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbZBTPDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 10:03:14 -0500
In-Reply-To: <1235141957.2351.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Fri Feb 20 15:20:57 2009 +0100

    Doc: Fix rp_filter description in net/ipv4/Kconfig.
    
    The reverse path filter (rp_filter) will NOT get enabled
    when enabling forwarding.  Read the code and tested in
    in practice.
    
    Most distributions does enable it in startup scripts.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 691268f..10c944d 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -35,7 +35,7 @@ config IP_ADVANCED_ROUTER
 
 	  at boot time after the /proc file system has been mounted.
 
-	  If you turn on IP forwarding, you will also get the rp_filter, which
+	  If you turn on IP forwarding, you should consider the rp_filter, which
 	  automatically rejects incoming packets if the routing table entry
 	  for their source address doesn't match the network interface they're
 	  arriving on. This has security advantages because it prevents the
@@ -46,9 +46,11 @@ config IP_ADVANCED_ROUTER
 	  rp_filter on use:
 
 	  echo 1 > /proc/sys/net/ipv4/conf/<device>/rp_filter
-	  or
+	   and
 	  echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
 
+	  Note that some distributions enable it in startup scripts.
+
 	  If unsure, say N here.
 
 choice 

