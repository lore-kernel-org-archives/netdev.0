From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/8] d80211/bcm43xx: Modify struct bcm43xx_stats for wireless
 statistics.
Date: Tue, 08 Aug 2006 18:59:17 -0500
Message-ID: <44D92555.7030907@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:32717 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030353AbWHHX7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:59:30 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 4 of 8 to add wireless statistics to the bcm43xx-d80211 system.
This patch removes link_quality and adds link_noise to struct
bcm43xx_stats and defines BCM43xx_RX_MAX_SSI, which is the maximum value for
rssi.

The patch is for the August 8 version of Linville's wireless-dev tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>


diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
index a0faeca..75174f9 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -27,6 +27,8 @@ #define BCM43xx_IRQWAIT_MAX_RETRIES	50

  #define BCM43xx_IO_SIZE			8192

+#define BCM43xx_RX_MAX_SSI		60
+
  /* Active Core PCI Configuration Register. */
  #define BCM43xx_PCICFG_ACTIVE_CORE	0x80
  /* SPROM control register. */
@@ -623,7 +625,7 @@ struct bcm43xx_noise_calculation {
  };

  struct bcm43xx_stats {
-	u8 link_quality;
+	u8 link_noise;
  	/* Store the last TX/RX times here for updating the leds. */
  	unsigned long last_tx;
  	unsigned long last_rx;


