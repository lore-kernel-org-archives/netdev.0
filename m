From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/13) aarp  - set last_sent
Date: Fri, 29 Aug 2003 14:01:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829140159.4ec0927e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Aarp has a field for last_sent which is used in the /proc/net/aarp
display, but it is never set.

diff -Nru a/net/appletalk/aarp.c b/net/appletalk/aarp.c
--- a/net/appletalk/aarp.c	Fri Aug 29 13:30:20 2003
+++ b/net/appletalk/aarp.c	Fri Aug 29 13:30:20 2003
@@ -145,6 +145,7 @@
 	aarp_dl->request(aarp_dl, skb, aarp_eth_multicast);
 	/* Update the sending count */
 	a->xmit_count++;
+	a->last_sent = jiffies;
 }
 
 /* This runs under aarp_lock and in softint context, so only atomic memory
