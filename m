From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH net-next 1/2] staging: rtl8188eu: Convert to using IFF_NO_QUEUE
Date: Fri, 15 Apr 2016 19:14:19 +0200
Message-ID: <1460740460-12859-2-git-send-email-phil@nwl.cc>
References: <1460740460-12859-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Jakub Sitnicki <jsitnicki@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49603 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbcDOROp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 13:14:45 -0400
In-Reply-To: <1460740460-12859-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/staging/rtl8188eu/os_dep/mon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/os_dep/mon.c b/drivers/staging/rtl8188eu/os_dep/mon.c
index 63bb87593af0c..d976e5e18d50e 100644
--- a/drivers/staging/rtl8188eu/os_dep/mon.c
+++ b/drivers/staging/rtl8188eu/os_dep/mon.c
@@ -155,7 +155,7 @@ static void mon_setup(struct net_device *dev)
 	dev->netdev_ops = &mon_netdev_ops;
 	dev->destructor = free_netdev;
 	ether_setup(dev);
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->type = ARPHRD_IEEE80211;
 	/*
 	 * Use a locally administered address (IEEE 802)
-- 
2.8.0
