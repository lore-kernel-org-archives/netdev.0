From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] mac802154: Use pr_err(...) rather than printk(KERN_ERR ...)
Date: Wed, 30 Oct 2013 15:28:07 +0800
Message-ID: <1383118087-10128-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-zigbee-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, <dingtianhong@huawei.com>
To: <alex.bluesman.smirnov@gmail.com>, <dbaryshkov@gmail.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:62716 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3J3H2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 03:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is inspired by checkpatch.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/mac802154/ieee802154_dev.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index b7c7f81..52ae664 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -174,8 +174,7 @@ ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 
 	if (!ops || !ops->xmit || !ops->ed || !ops->start ||
 	    !ops->stop || !ops->set_channel) {
-		printk(KERN_ERR
-		       "undefined IEEE802.15.4 device operations\n");
+		pr_err("undefined IEEE802.15.4 device operations\n");
 		return NULL;
 	}
 
@@ -201,8 +200,7 @@ ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 
 	phy = wpan_phy_alloc(priv_size);
 	if (!phy) {
-		printk(KERN_ERR
-		       "failure to allocate master IEEE802.15.4 device\n");
+		pr_err("failure to allocate master IEEE802.15.4 device\n");
 		return NULL;
 	}
 
-- 
1.8.2.1
