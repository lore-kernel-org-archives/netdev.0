From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/4] e1000e: Remove unnessary log message
Date: Fri, 23 Apr 2010 17:26:39 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004231717001.16022@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:2026 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756287Ab0DXA0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 20:26:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove e_info message printed whenever TSO is enabled or disabled.
This is not very useful and just clutters dmesg.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 983493f..0deb2d1 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -412,7 +412,6 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 		netdev->features &= ~NETIF_F_TSO6;
 	}
 
-	e_info("TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->flags |= FLAG_TSO_FORCE;
 	return 0;
 }
