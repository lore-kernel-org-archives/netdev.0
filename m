From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next 1/2] 6lowpan: fix a small formatting issue
Date: Wed, 27 Mar 2013 00:09:24 -0400
Message-ID: <1364357365-21080-2-git-send-email-tony.cheneau@amnesiak.org>
References: <1364357365-21080-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:35316 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030Ab3C0EKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 00:10:38 -0400
In-Reply-To: <1364357365-21080-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This formatting issue was introduced with commit
d4ac32365dcbfd341a87eae444c26679f889249a

Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
---
 net/ieee802154/6lowpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index c9c3f3d..f4969d7 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -104,7 +104,7 @@ static const u8 lowpan_llprefix[] = {0xfe, 0x80};
 struct lowpan_dev_info {
 	struct net_device	*real_dev; /* real WPAN device ptr */
 	struct mutex		dev_list_mtx; /* mutex for list ops */
-	unsigned short fragment_tag;
+	unsigned short		fragment_tag;
 };
 
 struct lowpan_dev_record {
-- 
1.7.12.4
