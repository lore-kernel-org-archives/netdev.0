From: Art Haas <ahaas@neosoft.com>
Subject: [PATCH] trivial C99 designated initializer patch for net/netlink/af_netlink.c
Date: Mon, 7 Oct 2002 17:52:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007225200.GP9856@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

The trivial patch below fixes a structure to use C99 designated
initializers. The patch is against 2.5.41.

Art Haas

--- linux-2.5.41/net/netlink/af_netlink.c.old	2002-08-10 22:04:03.000000000 -0500
+++ linux-2.5.41/net/netlink/af_netlink.c	2002-10-07 15:51:59.000000000 -0500
@@ -280,8 +280,8 @@
 	skb_queue_purge(&sk->write_queue);
 
 	if (nlk->pid && !nlk->groups) {
-		struct netlink_notify n = { protocol:sk->protocol,
-		                            pid:nlk->pid };
+		struct netlink_notify n = { .protocol = sk->protocol,
+		                            .pid = nlk->pid };
 		notifier_call_chain(&netlink_chain, NETLINK_URELEASE, &n);
 	}	
 	
-- 
They that can give up essential liberty to obtain a little temporary safety
deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759
