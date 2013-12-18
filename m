From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] mac802154: fix following checkpath.pl warning Prefer pr_warn(... to pr_warning(...
Date: Wed, 18 Dec 2013 17:36:04 +0800
Message-ID: <1387359364-5892-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <alex.bluesman.smirnov@gmail.com>,
	<dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:35400 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098Ab3LRJg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:36:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

This patch fixes checkpath.pl:
 WARNING: Prefer pr_warn(... to pr_warning(...
 #447: FILE: ./wpan.c:447:

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/mac802154/wpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index e24bcf9..9e5cc67 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -444,7 +444,7 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 	case IEEE802154_FC_TYPE_DATA:
 		return mac802154_process_data(sdata->dev, skb);
 	default:
-		pr_warning("ieee802154: bad frame received (type = %d)\n",
+		pr_warn("ieee802154: bad frame received (type = %d)\n",
 			   mac_cb_type(skb));
 		kfree_skb(skb);
 		return NET_RX_DROP;
-- 
1.7.12
