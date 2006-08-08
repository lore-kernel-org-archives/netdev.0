From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/8] d80211/bcm43xx: Modify struct ieee80211_local for wireless
 statistics.
Date: Tue, 08 Aug 2006 18:58:55 -0500
Message-ID: <44D9253F.20809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:37277 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030350AbWHHX7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:59:00 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 2 of 8 to add wireless statistics to the bcm43xx-d80211 system. This patch adds new variables
to struct ieee80211_local to contain the link_quality and noise. These could be u8's for bcm43xx,
but have been left as int's in case other drivers need a larger range.


The patch is for the August 8 version of Linville's wireless-dev tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>



diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 7e021ec..be68ebf 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -337,6 +337,9 @@ struct ieee80211_local {
  	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
  	int open_count;
  	int monitors;
+	int link_quality;
+	int noise;
+	struct iw_statistics wstats;
  	struct ieee80211_conf conf;

  	int dev_index;


