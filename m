From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/2] bcm43xx-d80211: use SET_NETDEV_DEV
Date: Tue, 18 Jul 2006 17:51:07 +0200 (CEST)
Message-ID: <20060718155107.410FC483BD@silver.suse.cz>
References: <20060718175044.204144808.midnight@suse.cz>
Cc: netdev@vger.kernel.org, Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:27623 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932309AbWGRPtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:49:19 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060718175044.204144808.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds /sys/class/net/wmaster0/device symlink.

Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

9dc20a14811532e2a630c66882ff27f71f90e5dd
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 8b63d1c..aa131af 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -4722,6 +4722,7 @@ #endif
 		goto err_free_netdev;
 
 	pci_set_drvdata(pdev, net_dev);
+	SET_NETDEV_DEV(net_dev, &pdev->dev);
 
 	err = bcm43xx_attach_board(bcm);
 	if (err)
-- 
1.3.0

