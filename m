From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 8/8] netpoll: remove unused variable
Date: Thu, 11 Aug 2005 21:19:12 -0500
Message-ID: <9.502409567@selenic.com>
References: <8.502409567@selenic.com>
Cc: ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <8.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove unused variable

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: l/net/core/netpoll.c
===================================================================
--- l.orig/net/core/netpoll.c	2005-08-11 01:32:01.000000000 -0500
+++ l/net/core/netpoll.c	2005-08-11 01:49:37.000000000 -0500
@@ -356,7 +356,6 @@ static void arp_reply(struct sk_buff *sk
 	unsigned char *arp_ptr;
 	int size, type = ARPOP_REPLY, ptype = ETH_P_ARP;
 	u32 sip, tip;
-	unsigned long flags;
 	struct sk_buff *send_skb;
 	struct netpoll *np = NULL;
 
