From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 11/21] net: bonding: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:39 +0200
Message-ID: <1439886649-24166-12-git-send-email-phil@nwl.cc>
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
Cc: brouer@redhat.com, davem@davemloft.net,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41291 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbbHRIaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:55 -0400
In-Reply-To: <1439886649-24166-11-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2d7d72c..0ef2ed3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4120,9 +4120,8 @@ void bond_setup(struct net_device *bond_dev)
 	SET_NETDEV_DEVTYPE(bond_dev, &bond_type);
 
 	/* Initialize the device options */
-	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
-	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT;
+	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT | IFF_NO_QUEUE;
 	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 
 	/* don't acquire bond device's netif_tx_lock when transmitting */
-- 
2.1.2
