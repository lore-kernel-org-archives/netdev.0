From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/8] d80211/bcm43xx: Modify struct sta_info for wireless statistics.
Date: Tue, 08 Aug 2006 18:59:08 -0500
Message-ID: <44D9254C.2090105@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:51613 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030352AbWHHX7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:59:10 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 3 of 8 to add wireless statistics to the bcm43xx-d80211 system.
This patch adds new variables last_signal, last_noise and max_rssi to
struct sta_info.

The patch is for the August 8 version of Linville's wireless-dev tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>


diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 70334e5..4d4169e 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -82,6 +82,9 @@ struct sta_info {
  	unsigned long rx_dropped; /* number of dropped MPDUs from this STA */

  	int last_rssi; /* RSSI of last received frame from this STA */
+	int last_signal; /* signal of last received frame from this STA */
+	int last_noise; /* noise of last received frame from this STA */
+	int max_rssi; /* maximum value of RSSI for this STA */
  	int last_ack_rssi[3]; /* RSSI of last received ACKs from this STA */
  	unsigned long last_ack;
          int channel_use;


