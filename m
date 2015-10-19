From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [net-next] net: Fix typo in 80211.xml
Date: Tue, 20 Oct 2015 01:34:47 +0900
Message-ID: <1445272487-26558-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, rdunlap@infradead.org,
	netdev@vger.kernel.org, corbet@lwn.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix spelling typos found in Documentation/
DocBook/80211.xml.
It is because this file was generated from comments in source,
so I had to fix comments in source files.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 include/net/cfg80211.h  | 2 +-
 include/net/mac80211.h  | 6 +++---
 net/mac80211/sta_info.h | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 90332a1..7566265 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2417,7 +2417,7 @@ struct cfg80211_qos_map {
  * @set_coalesce: Set coalesce parameters.
  *
  * @channel_switch: initiate channel-switch procedure (with CSA). Driver is
- *	responsible for veryfing if the switch is possible. Since this is
+ *	responsible for verifying if the switch is possible. Since this is
  *	inherently tricky driver may decide to disconnect an interface later
  *	with cfg80211_stop_iface(). This doesn't mean driver can accept
  *	everything. It should do it's best to verify requests and reject them
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 4ec6fed..8f992ed 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1169,7 +1169,7 @@ struct ieee80211_vendor_radiotap {
  * @IEEE80211_CONF_PS: Enable 802.11 power save mode (managed mode only).
  *	This is the power save mode defined by IEEE 802.11-2007 section 11.2,
  *	meaning that the hardware still wakes up for beacons, is able to
- *	transmit frames and receive the possible acknowledgment frames.
+ *	transmit frames and receive the possible acknowledgement frames.
  *	Not to be confused with hardware specific wakeup/sleep states,
  *	driver is responsible for that. See the section "Powersave support"
  *	for more.
@@ -1460,7 +1460,7 @@ struct wireless_dev *ieee80211_vif_to_wdev(struct ieee80211_vif *vif);
  *	%IEEE80211_KEY_FLAG_SW_MGMT_TX flag to encrypt such frames in SW.
  * @IEEE80211_KEY_FLAG_GENERATE_IV_MGMT: This flag should be set by the
  *	driver for a CCMP/GCMP key to indicate that is requires IV generation
- *	only for managment frames (MFP).
+ *	only for management frames (MFP).
  * @IEEE80211_KEY_FLAG_RESERVE_TAILROOM: This flag should be set by the
  *	driver for a key to indicate that sufficient tailroom must always
  *	be reserved for ICV or MIC, even when HW encryption is enabled.
@@ -5198,7 +5198,7 @@ static inline int rate_supported(struct ieee80211_sta *sta,
  * @sta: &struct ieee80211_sta pointer to the target destination. Note
  * 	that this may be null.
  * @priv_sta: private rate control structure. This may be null.
- * @txrc: rate control information we sholud populate for mac80211.
+ * @txrc: rate control information we should populate for mac80211.
  */
 bool rate_control_send_low(struct ieee80211_sta *sta,
 			   void *priv_sta,
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index d5ded87..185ef36 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -133,7 +133,7 @@ enum ieee80211_agg_stop_reason {
  * @buf_size: reorder buffer size at receiver
  * @failed_bar_ssn: ssn of the last failed BAR tx attempt
  * @bar_pending: BAR needs to be re-sent
- * @amsdu: support A-MSDU withing A-MDPU
+ * @amsdu: support A-MSDU within A-MDPU
  *
  * This structure's lifetime is managed by RCU, assignments to
  * the array holding it must hold the aggregation mutex.
-- 
2.6.2.195.g0c4dd78
