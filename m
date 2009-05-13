From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] wireless: fix to set dev->broadcast correctly
Date: Wed, 13 May 2009 09:47:38 +0800
Message-ID: <4A0A26BA.7090805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49799 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbZEMBvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 21:51:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix to set dev->broadcast correctly, since
dev->broadcast is defined as:
  unsigned char broadcast[MAX_ADDR_LEN];

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/wireless/strip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index f952046..b7b0c46 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -2509,7 +2509,7 @@ static void strip_dev_setup(struct net_device *dev)
 	 *  netdev_priv(dev) Already holds a pointer to our struct strip
 	 */
 
-	*(MetricomAddress *) & dev->broadcast = broadcast_address;
+	*(MetricomAddress *)dev->broadcast = broadcast_address;
 	dev->dev_addr[0] = 0;
 	dev->addr_len = sizeof(MetricomAddress);
 
-- 
1.5.3.8



