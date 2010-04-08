From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: fix rx_pause in myri10ge_set_pauseparam
Date: Thu, 08 Apr 2010 07:21:28 +0200
Message-ID: <4BBD67D8.8000104@myri.com>
References: <4BB8ADE4.5090304@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1852 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750746Ab0DHFVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 01:21:35 -0400
In-Reply-To: <4BB8ADE4.5090304@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix rx_pause management in myri10ge_set_pauseparam().

Signed-off-by: Brice Goglin <brice@myri.com>

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e84dd3e..3cb7607 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1689,7 +1689,7 @@ myri10ge_set_pauseparam(struct net_device *netdev,
 	if (pause->tx_pause != mgp->pause)
 		return myri10ge_change_pause(mgp, pause->tx_pause);
 	if (pause->rx_pause != mgp->pause)
-		return myri10ge_change_pause(mgp, pause->tx_pause);
+		return myri10ge_change_pause(mgp, pause->rx_pause);
 	if (pause->autoneg != 0)
 		return -EINVAL;
 	return 0;


