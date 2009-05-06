From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/5] mv643xx_eth: count handling a link event as one unit of napi work
Date: Wed, 6 May 2009 15:01:10 +0200
Message-ID: <20090506130110.GG24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40432 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbZEFMy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 08:54:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 352c772..92a867c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2178,6 +2178,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		if (mp->work_link) {
 			mp->work_link = 0;
 			handle_link_event(mp);
+			work_done++;
 			continue;
 		}
 
-- 
1.5.6.4
