From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx-softmac: Further improvement in wireless statistics
Date: Tue, 11 Jul 2006 11:04:53 -0500
Message-ID: <44B3CC25.7060305@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:53229 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751124AbWGKQFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 12:05:09 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This minor patch adjusts the parameters of the wireless statistics to improve the display of 
programs such as the "Wireless Network Information" applet of KDE.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

==============================================================



diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 8ffd760..1ea04da 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -49,7 +49,7 @@ #define BCM43xx_WX_VERSION	18
  #define MAX_WX_STRING		80
  /* FIXME: the next line is a guess as to what the maximum value of RX power
            (in dBm) might be */
-#define RX_POWER_MAX		-10
+#define RX_POWER_MAX		-20


  static int bcm43xx_wx_get_name(struct net_device *net_dev,
@@ -231,8 +231,8 @@ static int bcm43xx_wx_get_rangeparams(st

  	range->max_qual.qual = 100;
  	/* TODO: Real max RSSI */
-	range->max_qual.level = 0;
-	range->max_qual.noise = 0;
+	range->max_qual.level = -100;
+	range->max_qual.noise = -100;
  	range->max_qual.updated = IW_QUAL_ALL_UPDATED;

  	range->avg_qual.qual = 50;
