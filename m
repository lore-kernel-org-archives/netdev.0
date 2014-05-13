From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 5/5] mac802154: make mac802154_wpan_open static
Date: Tue, 13 May 2014 19:24:06 +0200
Message-ID: <1400001846-5349-6-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39673 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbaEMRYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:24:24 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4DHOMLX024120
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 19:24:22 +0200
In-Reply-To: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is only used within the same translation unit, so mark it
static.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/mac802154/wpan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 1477ee9..31b60b6 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -124,7 +124,7 @@ void mac802154_get_mac_params(struct net_device *dev,
 	mutex_unlock(&priv->hw->slaves_mtx);
 }
 
-int mac802154_wpan_open(struct net_device *dev)
+static int mac802154_wpan_open(struct net_device *dev)
 {
 	int rc;
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-- 
1.7.9.5
