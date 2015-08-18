From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 19/21] staging: wilc1000: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:47 +0200
Message-ID: <1439886649-24166-20-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
 <1439886649-24166-9-git-send-email-phil@nwl.cc>
 <1439886649-24166-10-git-send-email-phil@nwl.cc>
 <1439886649-24166-11-git-send-email-phil@nwl.cc>
 <1439886649-24166-12-git-send-email-phil@nwl.cc>
 <1439886649-24166-13-git-send-email-phil@nwl.cc>
 <1439886649-24166-14-git-send-email-phil@nwl.cc>
 <1439886649-24166-15-git-send-email-phil@nwl.cc>
 <1439886649-24166-16-git-send-email-phil@nwl.cc>
 <1439886649-24166-17-git-send-email-phil@nwl.cc>
 <1439886649-24166-18-git-send-email-phil@nwl.cc>
 <1439886649-24166-19-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Johnny Kim <johnny.kim@atmel.com>,
	Rachel Kim <rachel.kim@atmel.com>,
	Dean Lee <dean.lee@atmel.com>,
	Chris Park <chris.park@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:55428 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141AbbHRIa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:57 -0400
In-Reply-To: <1439886649-24166-19-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Johnny Kim <johnny.kim@atmel.com>
Cc: Rachel Kim <rachel.kim@atmel.com>
Cc: Dean Lee <dean.lee@atmel.com>
Cc: Chris Park <chris.park@atmel.com>
---
 drivers/staging/wilc1000/linux_mon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/wilc1000/linux_mon.c b/drivers/staging/wilc1000/linux_mon.c
index f5296f5..a1f66ad 100644
--- a/drivers/staging/wilc1000/linux_mon.c
+++ b/drivers/staging/wilc1000/linux_mon.c
@@ -493,7 +493,7 @@ static void WILC_WFI_mon_setup(struct net_device *dev)
 	/* dev->destructor = free_netdev; */
 	PRINT_INFO(CORECONFIG_DBG, "In Ethernet setup function\n");
 	ether_setup(dev);
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->type = ARPHRD_IEEE80211_RADIOTAP;
 	memset(dev->dev_addr, 0, ETH_ALEN);
 
-- 
2.1.2
