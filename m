From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 06/21] net: team: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:34 +0200
Message-ID: <1439886649-24166-7-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39336 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbbHRIax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:53 -0400
In-Reply-To: <1439886649-24166-6-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index daa054b..651d35e 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2051,9 +2051,9 @@ static void team_setup(struct net_device *dev)
 	dev->netdev_ops = &team_netdev_ops;
 	dev->ethtool_ops = &team_ethtool_ops;
 	dev->destructor	= team_destructor;
-	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MULTICAST;
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags |= IFF_NO_QUEUE;
 
 	/*
 	 * Indicate we support unicast address filtering. That way core won't
-- 
2.1.2
