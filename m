From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for adm8211
Date: Tue, 29 Aug 2006 18:08:29 -0700
Message-ID: <20060830010829.GL8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:8173 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S932226AbWH3BJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 21:09:09 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for ADMTek driver...
	Patch for wireless-2.6 git...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/adm8211/adm8211_ioctl.20.c linux/drivers/net/wireless/adm8211/adm8211_ioctl.c
--- linux/drivers/net/wireless/adm8211/adm8211_ioctl.20.c	2006-08-29 15:36:18.000000000 -0700
+++ linux/drivers/net/wireless/adm8211/adm8211_ioctl.c	2006-08-29 15:36:30.000000000 -0700
@@ -294,7 +294,7 @@ static int adm8211_ioctl_siwessid(struct
 	if (dwrq->flags == 0 || dwrq->length < 1)
 		len = 0;
 	else
-		len = min(dwrq->length - 1, IW_ESSID_MAX_SIZE);
+		len = min(dwrq->length, IW_ESSID_MAX_SIZE);
 
 	memcpy(priv->ieee80211.ssid, essid, len);
 	priv->ieee80211.ssid_len = len;
