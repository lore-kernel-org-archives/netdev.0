From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] ieee80211: WLAN_GET_SEQ_SEQ fix
Date: Mon, 18 Dec 2006 17:26:13 +0800
Message-ID: <20061218092613.GA27091@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24709 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753585AbWLRJ24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 04:28:56 -0500
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index e6af381..e02d85f 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -218,7 +218,7 @@ struct ieee80211_snap_hdr {
 #define WLAN_FC_GET_STYPE(fc) ((fc) & IEEE80211_FCTL_STYPE)
 
 #define WLAN_GET_SEQ_FRAG(seq) ((seq) & IEEE80211_SCTL_FRAG)
-#define WLAN_GET_SEQ_SEQ(seq)  ((seq) & IEEE80211_SCTL_SEQ)
+#define WLAN_GET_SEQ_SEQ(seq)  (((seq) & IEEE80211_SCTL_SEQ) >> 4)
 
 /* Authentication algorithms */
 #define WLAN_AUTH_OPEN 0
