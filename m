From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] fixed broken bootp compilation
Date: Thu, 27 Sep 2007 14:46:22 +0400
Message-ID: <20070927104622.GA8349@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:55020 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751790AbXI0Kpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 06:45:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compilation fix. Extra bracket removed.
Broken by "[NET]: Wrap netdevice hardware header creation" from
Stephen Hemminger <shemminger@linux-foundation.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./net/ipv4/ipconfig.c.compile	2007-09-27 13:32:35.000000000 +0400
+++ ./net/ipv4/ipconfig.c	2007-09-27 14:36:19.000000000 +0400
@@ -758,7 +758,7 @@ static void __init ic_bootp_send_if(stru
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol),
-			    dev->broadcast, dev->dev_addr, skb->len) < 0) ||
+			    dev->broadcast, dev->dev_addr, skb->len) < 0 ||
 	    dev_queue_xmit(skb) < 0)
 		printk("E");
 }
