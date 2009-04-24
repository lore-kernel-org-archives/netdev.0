From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH net-next-2.6] pcnet32: Remove redundant set of skb->dev
Date: Fri, 24 Apr 2009 19:48:32 +0000
Message-ID: <1240602512.7304.11.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:22472 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbZDXTsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 15:48:46 -0400
Received: by qw-out-2122.google.com with SMTP id 5so1073537qwd.37
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 12:48:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant set of skb->dev (now handled for ethernet
drivers by eth_type_trans()).

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 drivers/net/pcnet32.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 80124fa..e5e8c59 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1227,7 +1227,6 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		dev->stats.rx_dropped++;
 		return;
 	}
-	skb->dev = dev;
 	if (!rx_in_place) {
 		skb_reserve(skb, NET_IP_ALIGN);
 		skb_put(skb, pkt_len);	/* Make room */
-- 
1.5.4.3



