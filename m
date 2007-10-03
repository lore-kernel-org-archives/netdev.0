From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Tue, 2 Oct 2007 21:20:44 -0400
Message-ID: <20071003012044.GD29361@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4595 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbXJCBi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 21:38:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 3146b39c185f8a436d430132457e84fa1d8f8208:
  Linus Torvalds (1):
        Linux 2.6.23-rc9

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Joe Perches (1):
      bcm43xx: Correct printk with PFX before KERN_

Richard Knutsson (1):
      softmac: Fix compiler-warning

 drivers/net/wireless/bcm43xx/bcm43xx_wx.c   |    2 +-
 net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

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
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 442b987..5742dc8 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -114,7 +114,7 @@ check_assoc_again:
 	sm->associnfo.associating = 1;
 	/* queue lower level code to do work (if necessary) */
 	schedule_delayed_work(&sm->associnfo.work, 0);
-out:
+
 	mutex_unlock(&sm->associnfo.mutex);
 
 	return 0;
-- 
John W. Linville
linville@tuxdriver.com
