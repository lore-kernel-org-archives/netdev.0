From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH 1/2] fec: convert TX hook to netdev_tx_t
Date: Wed, 2 Jun 2010 19:15:47 +0000
Message-ID: <20100602191547.GA16211@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:48702 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932951Ab0FBTPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 15:15:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert TX hook return value to netdev_tx_t

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 42d9ac9..64afed0 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -208,7 +208,7 @@ static void fec_stop(struct net_device *dev);
 /* Transmitter timeout */
 #define TX_TIMEOUT (2 * HZ)
 
-static int
+static netdev_tx_t
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
