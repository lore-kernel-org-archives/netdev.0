From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 1/2] ieee802154: sparse warnings: make symbols static
Date: Mon,  2 Jul 2012 10:18:31 +0400
Message-ID: <1341209912-6030-2-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:64148 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148Ab2GBGWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 02:22:45 -0400
Received: by wibhm11 with SMTP id hm11so2816159wib.1
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 23:22:44 -0700 (PDT)
In-Reply-To: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make symbols static to avoid the following warning shown up
by sparse:

    warning: symbol ... was not declared. Should it be static?

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    2 +-
 net/mac802154/mac_cmd.c  |    2 +-
 net/mac802154/mib.c      |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index cd5007f..17ad28f 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -124,7 +124,7 @@ struct lowpan_fragment {
 
 static unsigned short fragment_tag;
 static LIST_HEAD(lowpan_fragments);
-spinlock_t flist_lock;
+static spinlock_t flist_lock;
 
 static inline struct
 lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index 7f5403e..e6659fa 100644
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
index 380829d..9cfa5f3 100644
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
