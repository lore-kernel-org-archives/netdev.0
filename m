From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] ieee802154: space prohibited before that close parenthesis
Date: Fri, 20 Dec 2013 11:41:15 +0800
Message-ID: <1387510875-11632-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <alex.bluesman.smirnov@gmail.com>, <dbaryshkov@gmail.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:22517 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab3LTDlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 22:41:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Fix checkpatch error with space.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ieee802154/wpan-class.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index ef56ab5..4dd3761 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -46,7 +46,7 @@ MASTER_SHOW(current_channel, "%d");
 MASTER_SHOW(current_page, "%d");
 MASTER_SHOW_COMPLEX(transmit_power, "%d +- %d dB",
 	((signed char) (phy->transmit_power << 2)) >> 2,
-	(phy->transmit_power >> 6) ? (phy->transmit_power >> 6) * 3 : 1 );
+	(phy->transmit_power >> 6) ? (phy->transmit_power >> 6) * 3 : 1);
 MASTER_SHOW(cca_mode, "%d");
 
 static ssize_t channels_supported_show(struct device *dev,
-- 
1.7.12
