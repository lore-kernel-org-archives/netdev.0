From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: [PATCH 03/3] d80211:  adhoc
Date: Mon, 21 Aug 2006 17:38:04 -0700
Message-ID: <44EA51EC.8010705@linux.intel.com>
References: <20060821074107.648561364@sipsolutions.net> <20060821075158.728615077@sipsolutions.net> <44EA501E.4010605@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020703010508000700070800"
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6545 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751340AbWHVAiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 20:38:13 -0400
To: netdev@vger.kernel.org
In-Reply-To: <44EA501E.4010605@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020703010508000700070800
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This a small patch allow IBSS network to recieve management frame.
Thanks
Mohamed

--------------020703010508000700070800
Content-Type: text/plain;
 name="d80211-adhoc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-adhoc.patch"

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 8caf352..1153932 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1716,7 +1710,8 @@ void ieee80211_sta_rx_mgmt(struct net_de
 		goto fail;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_IF_TYPE_STA) {
+	if ((sdata->type != IEEE80211_IF_TYPE_STA) &&
+            (sdata->type != IEEE80211_IF_TYPE_IBSS)) {
 		printk(KERN_DEBUG "%s: ieee80211_sta_rx_mgmt: non-STA "
 		       "interface (type=%d)\n", dev->name, sdata->type);
 		goto fail;

--------------020703010508000700070800--
