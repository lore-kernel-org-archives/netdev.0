From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: fix rx_pause in myri10ge_set_pauseparam
Date: Sun, 04 Apr 2010 17:19:00 +0200
Message-ID: <4BB8ADE4.5090304@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1916 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754563Ab0DDPnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 11:43:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix rx_pause in myri10ge_set_pauseparam().

Signed-off-by: Brice Goglin <brice@myri.com>

diff --git a/drivers/net/myri10ge/myri10ge.c
b/drivers/net/myri10ge/myri10ge.c
index e84dd3e..3cb7607 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1689,7 +1689,7 @@ myri10ge_set_pauseparam(struct net_device *netdev,
     if (pause->tx_pause != mgp->pause)
         return myri10ge_change_pause(mgp, pause->tx_pause);
     if (pause->rx_pause != mgp->pause)
-        return myri10ge_change_pause(mgp, pause->tx_pause);
+        return myri10ge_change_pause(mgp, pause->rx_pause);
     if (pause->autoneg != 0)
         return -EINVAL;
     return 0;

