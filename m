From: Joe Perches <joe@perches.com>
Subject: [PATCH] - trivial - Correct printk with PFX before KERN_ in
	drivers/net/wireless/bcm43xx/bcm43xx_wx.c
Date: Tue, 02 Oct 2007 12:57:11 -0700
Message-ID: <1191355031.29929.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3205 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006AbXJBT6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 15:58:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index d6d9413..6acfdc4 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -444,7 +444,7 @@ static int bcm43xx_wx_set_xmitpower(struct net_device *net_dev,
 	u16 maxpower;
 
 	if ((data->txpower.flags & IW_TXPOW_TYPE) != IW_TXPOW_DBM) {
-		printk(PFX KERN_ERR "TX power not in dBm.\n");
+		printk(KERN_ERR PFX "TX power not in dBm.\n");
 		return -EOPNOTSUPP;
 	}
 


