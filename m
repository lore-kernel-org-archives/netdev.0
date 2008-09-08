From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] igmp: allow IPPROTO_IGMP sockets in netns
Date: Mon, 8 Sep 2008 05:29:19 +0400
Message-ID: <20080908012919.GD575@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:59660 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbYIHB1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 21:27:32 -0400
Received: by gv-out-0910.google.com with SMTP id e6so81720gvc.37
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 18:27:31 -0700 (PDT)
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
 

