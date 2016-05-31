From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH] net/wireless: Fix 'multiple blank lines' check
Date: Mon, 30 May 2016 22:58:58 -0700
Message-ID: <20160531055858.GA32239@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the checkpatch.pl check "Please don't use multiple
blank lines" for all files in net/wireless, except nl80211.c which
is covered in a separated patch.

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/ap.c          | 1 -
 net/wireless/chan.c        | 3 ---
 net/wireless/core.h        | 2 --
 net/wireless/ibss.c        | 1 -
 net/wireless/mlme.c        | 2 --
 net/wireless/radiotap.c    | 2 --
 net/wireless/rdev-ops.h    | 2 --
 net/wireless/reg.c         | 3 ---
 net/wireless/scan.c        | 1 -
 net/wireless/sme.c         | 1 -
 net/wireless/util.c        | 2 --
 net/wireless/wext-compat.c | 3 ---
 net/wireless/wext-compat.h | 2 --
 net/wireless/wext-core.c   | 6 ------
 net/wireless/wext-proc.c   | 1 -
 net/wireless/wext-sme.c    | 1 -
 16 files changed, 33 deletions(-)

diff --git a/net/wireless/ap.c b/net/wireless/ap.c
index bdad1f9..23acf58 100644
--- a/net/wireless/ap.c
+++ b/net/wireless/ap.c
@@ -5,7 +5,6 @@
 #include "core.h"
 #include "rdev-ops.h"

-
 int __cfg80211_stop_ap(struct cfg80211_registered_device *rdev,
 		       struct net_device *dev, bool notify)
 {
diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index da49c0b..34cec73d 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -325,7 +325,6 @@ static int cfg80211_get_chans_dfs_required(struct wiphy *wiphy,
 	return 0;
 }

-
 int cfg80211_chandef_dfs_required(struct wiphy *wiphy,
 				  const struct cfg80211_chan_def *chandef,
 				  enum nl80211_iftype iftype)
@@ -455,7 +454,6 @@ bool cfg80211_chandef_dfs_usable(struct wiphy *wiphy,
 	return (r1 + r2 > 0);
 }

-
 static bool cfg80211_get_chans_dfs_available(struct wiphy *wiphy,
 					     u32 center_freq,
 					     u32 bandwidth)
@@ -685,7 +683,6 @@ bool cfg80211_chandef_usable(struct wiphy *wiphy,
 	if (width < 20)
 		prohibited_flags |= IEEE80211_CHAN_NO_OFDM;

-
 	if (!cfg80211_secondary_chans_ok(wiphy, chandef->center_freq1,
 					 width, prohibited_flags))
 		return false;
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 025b7a5..5c54a1e 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -16,7 +16,6 @@
 #include <net/cfg80211.h>
 #include "reg.h"

-
 #define WIPHY_IDX_INVALID	-1

 struct cfg80211_registered_device {
@@ -161,7 +160,6 @@ static inline void cfg80211_unhold_bss(struct cfg80211_internal_bss *bss)
 	WARN_ON(r < 0);
 }

-
 struct cfg80211_registered_device *cfg80211_rdev_by_wiphy_idx(int wiphy_idx);
 int get_wiphy_idx(struct wiphy *wiphy);

diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index 4a4dda5..67b4f9b 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -13,7 +13,6 @@
 #include "nl80211.h"
 #include "rdev-ops.h"

-
 void __cfg80211_ibss_joined(struct net_device *dev, const u8 *bssid,
 			    struct ieee80211_channel *channel)
 {
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index c284d88..332a143 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -18,7 +18,6 @@
 #include "nl80211.h"
 #include "rdev-ops.h"

-
 void cfg80211_rx_assoc_resp(struct net_device *dev, struct cfg80211_bss *bss,
 			    const u8 *buf, size_t len, int uapsd_queues)
 {
@@ -768,7 +767,6 @@ void cfg80211_dfs_channels_update_work(struct work_struct *work)
 				   next_time);
 }

-
 void cfg80211_radar_event(struct wiphy *wiphy,
 			  struct cfg80211_chan_def *chandef,
 			  gfp_t gfp)
diff --git a/net/wireless/radiotap.c b/net/wireless/radiotap.c
index 6582d15..f193b88 100644
--- a/net/wireless/radiotap.c
+++ b/net/wireless/radiotap.c
@@ -184,8 +184,6 @@ static void find_ns(struct ieee80211_radiotap_iterator *iterator,
 	}
 }

-
-
 /**
  * ieee80211_radiotap_iterator_next - return next radiotap parser iterator arg
  * @iterator: radiotap_iterator to move to next arg (if any)
diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
index 85ff30b..9ad56db 100644
--- a/net/wireless/rdev-ops.h
+++ b/net/wireless/rdev-ops.h
@@ -338,7 +338,6 @@ static inline int rdev_join_mesh(struct cfg80211_registered_device *rdev,
 	return ret;
 }

-
 static inline int rdev_leave_mesh(struct cfg80211_registered_device *rdev,
 				  struct net_device *dev)
 {
@@ -569,7 +568,6 @@ static inline void rdev_rfkill_poll(struct cfg80211_registered_device *rdev)
 	trace_rdev_return_void(&rdev->wiphy);
 }

-
 #ifdef CONFIG_NL80211_TESTMODE
 static inline int rdev_testmode_cmd(struct cfg80211_registered_device *rdev,
 				    struct wireless_dev *wdev,
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 5dbac37..cfd4d69 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -18,7 +18,6 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */

-
 /**
  * DOC: Wireless regulatory infrastructure
  *
@@ -1969,7 +1968,6 @@ reg_process_hint_driver(struct wiphy *wiphy,
 		rcu_free_regdom(tmp);
 	}

-
 	driver_request->intersect = treatment == REG_REQ_INTERSECT;
 	driver_request->processed = false;

@@ -2715,7 +2713,6 @@ static void print_rd_rules(const struct ieee80211_regdomain *rd)
 		else
 			scnprintf(cac_time, sizeof(cac_time), "N/A");

-
 		/*
 		 * There may not be documentation for max antenna gain
 		 * in certain regions
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index ef2955c..fb121ca 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -1622,7 +1622,6 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 	return current_ev;
 }

-
 static int ieee80211_scan_results(struct cfg80211_registered_device *rdev,
 				  struct iw_request_info *info,
 				  char *buf, size_t len)
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 584fdc3..2c39dc5a 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -638,7 +638,6 @@ static void disconnect_work(struct work_struct *work)

 static DECLARE_WORK(cfg80211_disconnect_work, disconnect_work);

-
 /*
  * API calls for drivers implementing connect/disconnect and
  * SME event handling
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 4e809e9..8f246c1 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -16,7 +16,6 @@
 #include "core.h"
 #include "rdev-ops.h"

-
 struct ieee80211_rate *
 ieee80211_get_response_rate(struct ieee80211_supported_band *sband,
 			    u32 basic_rates, int bitrate)
@@ -1310,7 +1309,6 @@ int cfg80211_get_p2p_attr(const u8 *ies, unsigned int len,
 				bufsize -= min(bufsize, copy);
 			}

-
 			if (copy == attr_remaining)
 				return desired_len;
 		}
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index 9f27221..e9b724a 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -101,7 +101,6 @@ int cfg80211_wext_giwmode(struct net_device *dev, struct iw_request_info *info,
 }
 EXPORT_WEXT_HANDLER(cfg80211_wext_giwmode);

-
 int cfg80211_wext_giwrange(struct net_device *dev,
 			   struct iw_request_info *info,
 			   struct iw_point *data, char *extra)
@@ -215,7 +214,6 @@ int cfg80211_wext_giwrange(struct net_device *dev,
 }
 EXPORT_WEXT_HANDLER(cfg80211_wext_giwrange);

-
 /**
  * cfg80211_wext_freq - get wext frequency for non-"auto"
  * @dev: the net device
@@ -1013,7 +1011,6 @@ static int cfg80211_set_cipher_pairwise(struct wireless_dev *wdev, u32 cipher)
 	return 0;
 }

-
 static int cfg80211_set_key_mgt(struct wireless_dev *wdev, u32 key_mgt)
 {
 	int nr_akm_suites = 0;
diff --git a/net/wireless/wext-compat.h b/net/wireless/wext-compat.h
index 94c7405..4d6af53 100644
--- a/net/wireless/wext-compat.h
+++ b/net/wireless/wext-compat.h
@@ -55,9 +55,7 @@ int cfg80211_wext_siwgenie(struct net_device *dev,
 			   struct iw_request_info *info,
 			   struct iw_point *data, char *extra);

-
 int cfg80211_wext_freq(struct iw_freq *freq);

-
 extern const struct iw_handler_def cfg80211_wext_handler;
 #endif /* __WEXT_COMPAT */
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 6250b1c..1cbbe7c 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -24,7 +24,6 @@ typedef int (*wext_ioctl_func)(struct net_device *, struct iwreq *,
 			       unsigned int, struct iw_request_info *,
 			       iw_handler);

-
 /*
  * Meta-data about all the standard Wireless Extension request we
  * know about.
@@ -339,7 +338,6 @@ static const int compat_event_type_size[] = {
 };
 #endif

-
 /* IW event code */

 void wireless_nlevent_flush(void)
@@ -444,7 +442,6 @@ static struct nlmsghdr *rtnetlink_ifinfo_prep(struct net_device *dev,
 	return NULL;
 }

-
 /*
  * Main event dispatcher. Called from other parts and drivers.
  * Send the event on the appropriate channels.
@@ -635,8 +632,6 @@ void wireless_send_event(struct net_device *	dev,
 }
 EXPORT_SYMBOL(wireless_send_event);

-
-
 /* IW handlers */

 struct iw_statistics *get_wireless_stats(struct net_device *dev)
@@ -1038,7 +1033,6 @@ static int ioctl_standard_call(struct net_device *	dev,
 	return ret;
 }

-
 int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 		      void __user *arg)
 {
diff --git a/net/wireless/wext-proc.c b/net/wireless/wext-proc.c
index e98a01c..3356c1b 100644
--- a/net/wireless/wext-proc.c
+++ b/net/wireless/wext-proc.c
@@ -25,7 +25,6 @@
 #include <net/iw_handler.h>
 #include <net/wext.h>

-
 static void wireless_seq_printf_stats(struct seq_file *seq,
 				      struct net_device *dev)
 {
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index a4e8af3..8b8e468 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -106,7 +106,6 @@ int cfg80211_mgd_wext_siwfreq(struct net_device *dev,
 			goto out;
 	}

-
 	wdev->wext.connect.channel = chan;

 	/*
