From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 05/21] net: nlmon: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:33 +0200
Message-ID: <1439886649-24166-6-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60620 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690AbbHRIaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:52 -0400
In-Reply-To: <1439886649-24166-5-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/nlmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index 34924df..7b7c70e 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -130,7 +130,7 @@ static const struct net_device_ops nlmon_ops = {
 static void nlmon_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_NETLINK;
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 
 	dev->netdev_ops	= &nlmon_ops;
 	dev->ethtool_ops = &nlmon_ethtool_ops;
-- 
2.1.2
