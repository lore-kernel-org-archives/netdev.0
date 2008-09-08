From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] igmp: allow IPPROTO_IGMP sockets in netns
Date: Mon, 8 Sep 2008 04:38:07 +0400
Message-ID: <20080908003807.GB575@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containters@lists.osdl.org
To: davem@devemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:38335 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbYIHAgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 20:36:22 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1129745muf.1
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 17:36:20 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like everything is already ready.

Required for ebtables(8) for one thing.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/af_inet.c |    1 +
 1 file changed, 1 insertion(+)

--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1310,6 +1310,7 @@ EXPORT_SYMBOL_GPL(snmp_mib_free);
 #ifdef CONFIG_IP_MULTICAST
 static struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
+	.netns_ok =	1,
 };
 #endif
 

