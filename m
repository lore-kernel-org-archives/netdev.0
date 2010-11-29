From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] gre: minor cleanups
Date: Mon, 29 Nov 2010 11:47:47 -0800
Message-ID: <20101129194805.666257322@vyatta.com>
References: <20101129194746.724222156@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42251 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806Ab0K2Tsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 14:48:33 -0500
Content-Disposition: inline; filename=gre-fix-trivial.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use strcpy() rather the sprintf() for the case where name is getting
generated.  Fix indentation.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ip_gre.c	2010-11-28 11:28:48.684091117 -0800
+++ b/net/ipv4/ip_gre.c	2010-11-28 11:29:21.839822531 -0800
@@ -405,11 +405,11 @@ static struct ip_tunnel *ipgre_tunnel_lo
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
 	else
-		sprintf(name, "gre%%d");
+		strcpy(name, "gre%d");
 
 	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
 	if (!dev)
-	  return NULL;
+		return NULL;
 
 	dev_net_set(dev, net);
 


