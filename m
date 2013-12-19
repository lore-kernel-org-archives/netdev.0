From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] rose: cleanup checkpatch errors,spaces required
Date: Thu, 19 Dec 2013 11:55:17 +0800
Message-ID: <1387425317-8900-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <ralf@linux-mips.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:14243 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab3LSD4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 22:56:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

This patch add spaces to cleanup checkpatch errors.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/rose/af_rose.c  | 2 +-
 net/rose/rose_dev.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 33af772..81f94b1 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1012,7 +1012,7 @@ int rose_rx_call_request(struct sk_buff *skb, struct net_device *dev, struct ros
 	make_rose->source_call   = facilities.source_call;
 	make_rose->source_ndigis = facilities.source_ndigis;
 	for (n = 0 ; n < facilities.source_ndigis ; n++)
-		make_rose->source_digis[n]= facilities.source_digis[n];
+		make_rose->source_digis[n] = facilities.source_digis[n];
 	make_rose->neighbour     = neigh;
 	make_rose->device        = dev;
 	make_rose->facilities    = facilities;
diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 28dbdb9..5000588 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -146,7 +146,7 @@ static netdev_tx_t rose_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static const struct header_ops rose_header_ops = {
 	.create	= rose_header,
-	.rebuild= rose_rebuild_header,
+	.rebuild = rose_rebuild_header,
 };
 
 static const struct net_device_ops rose_netdev_ops = {
-- 
1.7.12
