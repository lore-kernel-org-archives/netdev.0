From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 RESEND 1/9] ethtool: move EXPORT_SYMBOL(ethtool_op_set_tx_csum) to correct place
Date: Sun, 13 Feb 2011 12:11:44 +0100 (CET)
Message-ID: <79519ebf67009b4b185de02dfda9a7612f0cdbaa.1297594674.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50507 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754080Ab1BMLLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 06:11:47 -0500
In-Reply-To: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
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

