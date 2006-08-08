From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/8] d80211/bcm43xx: Modify struct ieee80211_rx_status for
 wireless statistics.
Date: Tue, 08 Aug 2006 18:58:45 -0500
Message-ID: <44D92535.8090303@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:2046 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030347AbWHHX6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:58:47 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 1 of 8 to add wireless statistics to the bcm43xx-d80211 system. This patch adds new variables
to struct ieee80211_rx_status to contain the latest values for signal, noise, and the maximum value
of the received ssi. These could be u8's, but I left them as integers in case other drivers needed
larger values.

The patch is for the August 8 version of Linville's wireless-dev tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>




diff --git a/include/net/d80211.h b/include/net/d80211.h
index ba5cb4c..8479b58 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -205,6 +205,9 @@ struct ieee80211_rx_status {
          int channel;
          int phymode;
          int ssi;
+	int maxssi;
+	int signal;
+	int noise;
          int antenna;
          int rate;
          int flag;


