From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/6] 6lowpan: fix set not used warning
Date: Mon, 24 Jul 2017 10:25:23 -0700
Message-ID: <20170724172523.13135-7-sthemmin@microsoft.com>
References: <20170724172523.13135-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        davem@davemloft.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34680 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756198AbdGXRZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:25:38 -0400
Received: by mail-pf0-f174.google.com with SMTP id q85so49377524pfq.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:25:38 -0700 (PDT)
In-Reply-To: <20170724172523.13135-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/bluetooth/6lowpan.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 2af4f1cc0ab4..4e2576fc0c59 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -273,9 +273,6 @@ static int iphc_decompress(struct sk_buff *skb, struct net_device *netdev,
 			   struct lowpan_peer *peer)
 {
 	const u8 *saddr;
-	struct lowpan_btle_dev *dev;
-
-	dev = lowpan_btle_dev(netdev);
 
 	saddr = peer->lladdr;
 
-- 
2.11.0
