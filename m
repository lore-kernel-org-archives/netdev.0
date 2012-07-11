From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 5/7] mac802154: sparse warnings: make symbols static
Date: Wed, 11 Jul 2012 11:22:46 +0400
Message-ID: <1341991368-11800-6-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35913 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756679Ab2GKH1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:27:04 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr14so807533wib.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:27:03 -0700 (PDT)
In-Reply-To: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make symbols static to avoid the following warning shown up
by sparse:

    warning: symbol ... was not declared. Should it be static?

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac_cmd.c |    2 +-
 net/mac802154/mib.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index 5d9a47b..d8d2770 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -55,7 +55,7 @@ static int mac802154_mlme_start_req(struct net_device *dev,
 	return 0;
 }
 
-struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
+static struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 5c66b8f..f47781a 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -39,7 +39,7 @@ struct hw_addr_filt_notify_work {
 	unsigned long changed;
 };
 
-struct mac802154_priv *mac802154_slave_get_priv(struct net_device *dev)
+static struct mac802154_priv *mac802154_slave_get_priv(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 
-- 
1.7.2.3
