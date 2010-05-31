From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH 1/2] ksz884x: convert to netdev_tx_t
Date: Mon, 31 May 2010 10:24:49 +0000
Message-ID: <20100531102449.GA6617@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:58495 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490Ab0EaKYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 06:24:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert TX hook to netdev_tx_t type

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/ksz884x.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index c80ca64..7805bbf 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -4854,7 +4854,7 @@ static inline void copy_old_skb(struct sk_buff *old, struct sk_buff *skb)
  *
  * Return 0 if successful; otherwise an error code indicating failure.
  */
-static int netdev_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dev_priv *priv = netdev_priv(dev);
 	struct dev_info *hw_priv = priv->adapter;
