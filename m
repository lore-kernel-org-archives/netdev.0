From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next 2/2] 6lowpan: use IEEE802154_ADDR_LEN instead of a magic number
Date: Wed, 27 Mar 2013 00:09:25 -0400
Message-ID: <1364357365-21080-3-git-send-email-tony.cheneau@amnesiak.org>
References: <1364357365-21080-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:35332 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859Ab3C0ELE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 00:11:04 -0400
In-Reply-To: <1364357365-21080-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
---
 net/ieee802154/6lowpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index f4969d7..e1b4580 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -602,7 +602,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 			da.short_addr = IEEE802154_ADDR_BROADCAST;
 		} else {
 			da.addr_type = IEEE802154_ADDR_LONG;
-			memcpy(&(da.hwaddr), daddr, 8);
+			memcpy(&(da.hwaddr), daddr, IEEE802154_ADDR_LEN);
 
 			/* request acknowledgment */
 			mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
-- 
1.7.12.4
