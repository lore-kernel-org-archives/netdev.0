From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ip: ipip  compile warning
Date: Fri, 20 Feb 2009 10:04:20 -0800
Message-ID: <20090220100420.6287eba7@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45584 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbZBTSEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 13:04:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of compile warning about non-const format

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ipip.c	2009-02-20 09:07:31.377370665 -0800
+++ b/net/ipv4/ipip.c	2009-02-20 09:07:46.958260669 -0800
@@ -750,7 +750,7 @@ static struct xfrm_tunnel ipip_handler =
 	.priority	=	1,
 };
 
-static char banner[] __initdata =
+static const char banner[] __initconst =
 	KERN_INFO "IPv4 over IPv4 tunneling driver\n";
 
 static void ipip_destroy_tunnels(struct ipip_net *ipn)
