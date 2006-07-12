From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] bcm43xx-d80211: use SET_NETDEV_DEV
Date: Wed, 12 Jul 2006 19:02:46 +0200
Message-ID: <20060712190246.0427ff70@griffin.suse.cz>
References: <20060712190120.7c909ac7@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Dan Williams <dcbw@redhat.com>, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:2971 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751273AbWGLRCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 13:02:48 -0400
To: NetDev <netdev@vger.kernel.org>
In-Reply-To: <20060712190120.7c909ac7@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds /sys/class/net/wmaster0/device symlink.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    1 +
 1 files changed, 1 insertion(+)

--- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -4722,6 +4722,7 @@ static int __devinit bcm43xx_init_one(st
 		goto err_free_netdev;
 
 	pci_set_drvdata(pdev, net_dev);
+	SET_NETDEV_DEV(net_dev, &pdev->dev);
 
 	err = bcm43xx_attach_board(bcm);
 	if (err)


-- 
Jiri Benc
SUSE Labs
