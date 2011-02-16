From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v6 1/9] ethtool: move EXPORT_SYMBOL(ethtool_op_set_tx_csum) to correct place
Date: Wed, 16 Feb 2011 03:59:16 +0100 (CET)
Message-ID: <2a2add438829b267560b366b8c90e57a8e1fbb5b.1297824704.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57720 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756486Ab1BPC7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 21:59:18 -0500
In-Reply-To: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 5984ee0..9eb8277 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -55,6 +55,7 @@ int ethtool_op_set_tx_csum(struct net_device *dev, u3=
2 data)
=20
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_tx_csum);
=20
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
 {
@@ -1124,7 +1125,6 @@ static int ethtool_set_tx_csum(struct net_device =
*dev, char __user *useraddr)
=20
 	return dev->ethtool_ops->set_tx_csum(dev, edata.data);
 }
-EXPORT_SYMBOL(ethtool_op_set_tx_csum);
=20
 static int ethtool_set_rx_csum(struct net_device *dev, char __user *us=
eraddr)
 {
--=20
1.7.2.3

