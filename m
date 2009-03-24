From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 30/41: auto-load ip6_queue module when socket opened
Date: Tue, 24 Mar 2009 15:03:47 +0100 (MET)
Message-ID: <20090324140342.31401.31452.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34804 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758314AbZCXODt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:49 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 26c3b6780618f09abb5f7e03b09b13dbb8e8aa24
Author: Scott James Remnant <scott@canonical.com>
Date:   Mon Mar 16 15:30:14 2009 +0100

    netfilter: auto-load ip6_queue module when socket opened
    
    The ip6_queue module is missing the net-pf-16-proto-13 alias that would
    cause it to be auto-loaded when a socket of that type is opened.  This
    patch adds the alias.
    
    Signed-off-by: Scott James Remnant <scott@canonical.com>
    Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 5859c04..b693f84 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -643,6 +643,7 @@ static void __exit ip6_queue_fini(void)
 
 MODULE_DESCRIPTION("IPv6 packet queue handler");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_IP6_FW);
 
 module_init(ip6_queue_init);
 module_exit(ip6_queue_fini);
