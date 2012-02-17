From: Luis Felipe Strano Moraes <lfelipe@profusion.mobi>
Subject: [PATCH] Cleaning up code formatting errors in net/wireless pointed out by checkpatch.
Date: Fri, 17 Feb 2012 07:30:03 -0800
Message-ID: <1329492603-3972-1-git-send-email-lfelipe@profusion.mobi>
Mime-Version: 1.0
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Luis Felipe Strano Moraes <lfelipe@profusion.mobi>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:65093 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab2BQPag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 10:30:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are mostly minor changes and they are being sent as one patch only in
order to cause the smallest amount of disruption.

Signed-off-by: Luis Felipe Strano Moraes <lfelipe@profusion.mobi>
---
 net/wireless/core.c                |    4 +-
 net/wireless/core.h                |    2 +-
 net/wireless/debugfs.c             |    2 +-
 net/wireless/lib80211.c            |   30 ++++++++--------
 net/wireless/lib80211_crypt_ccmp.c |   12 +++---
 net/wireless/lib80211_crypt_tkip.c |   40 +++++++++++-----------
 net/wireless/lib80211_crypt_wep.c  |    4 +-
 net/wireless/mesh.c                |    2 +-
 net/wireless/mlme.c                |    6 ++--
 net/wireless/nl80211.c             |    6 ++--
 net/wireless/nl80211.h             |    2 +-
 net/wireless/reg.c                 |    8 ++--
 net/wireless/scan.c                |    4 +-
 net/wireless/util.c                |    4 +-
 net/wireless/wext-compat.c         |    4 +-
 net/wireless/wext-core.c           |   20 +++++-----
 net/wireless/wext-priv.c           |    8 ++--
 net/wireless/wext-spy.c            |   66 ++++++++++++++++++------------------
 18 files changed, 112 insertions(+), 112 deletions(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index ccdfed8..a9df335 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -668,7 +668,7 @@ void wiphy_unregister(struct wiphy *wiphy)
 		mutex_lock(&rdev->devlist_mtx);
 		__count = rdev->opencount;
 		mutex_unlock(&rdev->devlist_mtx);
-		__count == 0;}));
+		__count == 0; }));
 
 	mutex_lock(&rdev->devlist_mtx);
 	BUG_ON(!list_empty(&rdev->netdev_list));
@@ -777,7 +777,7 @@ static struct device_type wiphy_type = {
 	.name	= "wlan",
 };
 
-static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
+static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 					 unsigned long state,
 					 void *ndev)
 {
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 43ad9c8..4c03d62 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -283,7 +283,7 @@ void ieee80211_set_bitrate_flags(struct wiphy *wiphy);
 
 void cfg80211_bss_expire(struct cfg80211_registered_device *dev);
 void cfg80211_bss_age(struct cfg80211_registered_device *dev,
-                      unsigned long age_secs);
+		      unsigned long age_secs);
 
 /* IBSS */
 int __cfg80211_join_ibss(struct cfg80211_registered_device *rdev,
diff --git a/net/wireless/debugfs.c b/net/wireless/debugfs.c
index 39765bc..8a0d5a0 100644
--- a/net/wireless/debugfs.c
+++ b/net/wireless/debugfs.c
@@ -23,7 +23,7 @@ static int cfg80211_open_file_generic(struct inode *inode, struct file *file)
 static ssize_t name## _read(struct file *file, char __user *userbuf,	\
 			    size_t count, loff_t *ppos)			\
 {									\
-	struct wiphy *wiphy= file->private_data;		\
+	struct wiphy *wiphy = file->private_data;		\
 	char buf[buflen];						\
 	int res;							\
 									\
diff --git a/net/wireless/lib80211.c b/net/wireless/lib80211.c
index a55c27b..3927898 100644
--- a/net/wireless/lib80211.c
+++ b/net/wireless/lib80211.c
@@ -98,21 +98,21 @@ void lib80211_crypt_info_free(struct lib80211_crypt_info *info)
 {
 	int i;
 
-        lib80211_crypt_quiescing(info);
-        del_timer_sync(&info->crypt_deinit_timer);
-        lib80211_crypt_deinit_entries(info, 1);
-
-        for (i = 0; i < NUM_WEP_KEYS; i++) {
-                struct lib80211_crypt_data *crypt = info->crypt[i];
-                if (crypt) {
-                        if (crypt->ops) {
-                                crypt->ops->deinit(crypt->priv);
-                                module_put(crypt->ops->owner);
-                        }
-                        kfree(crypt);
-                        info->crypt[i] = NULL;
-                }
-        }
+	lib80211_crypt_quiescing(info);
+	del_timer_sync(&info->crypt_deinit_timer);
+	lib80211_crypt_deinit_entries(info, 1);
+
+	for (i = 0; i < NUM_WEP_KEYS; i++) {
+		struct lib80211_crypt_data *crypt = info->crypt[i];
+		if (crypt) {
+			if (crypt->ops) {
+				crypt->ops->deinit(crypt->priv);
+				module_put(crypt->ops->owner);
+			}
+			kfree(crypt);
+			info->crypt[i] = NULL;
+		}
+	}
 }
 EXPORT_SYMBOL(lib80211_crypt_info_free);
 
diff --git a/net/wireless/lib80211_crypt_ccmp.c b/net/wireless/lib80211_crypt_ccmp.c
index 755738d..effb562 100644
--- a/net/wireless/lib80211_crypt_ccmp.c
+++ b/net/wireless/lib80211_crypt_ccmp.c
@@ -101,7 +101,7 @@ static void lib80211_ccmp_deinit(void *priv)
 	kfree(priv);
 }
 
-static inline void xor_block(u8 * b, u8 * a, size_t len)
+static inline void xor_block(u8 *b, u8 *a, size_t len)
 {
 	int i;
 	for (i = 0; i < len; i++)
@@ -110,7 +110,7 @@ static inline void xor_block(u8 * b, u8 * a, size_t len)
 
 static void ccmp_init_blocks(struct crypto_cipher *tfm,
 			     struct ieee80211_hdr *hdr,
-			     u8 * pn, size_t dlen, u8 * b0, u8 * auth, u8 * s0)
+			     u8 *pn, size_t dlen, u8 *b0, u8 *auth, u8 *s0)
 {
 	u8 *pos, qc = 0;
 	size_t aad_len;
@@ -124,7 +124,7 @@ static void ccmp_init_blocks(struct crypto_cipher *tfm,
 	if (a4_included)
 		aad_len += 6;
 	if (qc_included) {
-		pos = (u8 *) & hdr->addr4;
+		pos = (u8 *) &hdr->addr4;
 		if (a4_included)
 			pos += 6;
 		qc = *pos & 0x0f;
@@ -156,7 +156,7 @@ static void ccmp_init_blocks(struct crypto_cipher *tfm,
 	aad[2] = pos[0] & 0x8f;
 	aad[3] = pos[1] & 0xc7;
 	memcpy(aad + 4, hdr->addr1, 3 * ETH_ALEN);
-	pos = (u8 *) & hdr->seq_ctrl;
+	pos = (u8 *) &hdr->seq_ctrl;
 	aad[22] = pos[0] & 0x0f;
 	aad[23] = 0;		/* all bits masked */
 	memset(aad + 24, 0, 8);
@@ -388,7 +388,7 @@ static int lib80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	return keyidx;
 }
 
-static int lib80211_ccmp_set_key(void *key, int len, u8 * seq, void *priv)
+static int lib80211_ccmp_set_key(void *key, int len, u8 *seq, void *priv)
 {
 	struct lib80211_ccmp_data *data = priv;
 	int keyidx;
@@ -418,7 +418,7 @@ static int lib80211_ccmp_set_key(void *key, int len, u8 * seq, void *priv)
 	return 0;
 }
 
-static int lib80211_ccmp_get_key(void *key, int len, u8 * seq, void *priv)
+static int lib80211_ccmp_get_key(void *key, int len, u8 *seq, void *priv)
 {
 	struct lib80211_ccmp_data *data = priv;
 
diff --git a/net/wireless/lib80211_crypt_tkip.c b/net/wireless/lib80211_crypt_tkip.c
index 3873484..ce50760 100644
--- a/net/wireless/lib80211_crypt_tkip.c
+++ b/net/wireless/lib80211_crypt_tkip.c
@@ -190,7 +190,7 @@ static inline u16 Mk16(u8 hi, u8 lo)
 	return lo | (((u16) hi) << 8);
 }
 
-static inline u16 Mk16_le(__le16 * v)
+static inline u16 Mk16_le(__le16 *v)
 {
 	return le16_to_cpu(*v);
 }
@@ -238,7 +238,7 @@ static inline u16 _S_(u16 v)
 
 #define PHASE1_LOOP_COUNT 8
 
-static void tkip_mixing_phase1(u16 * TTAK, const u8 * TK, const u8 * TA,
+static void tkip_mixing_phase1(u16 *TTAK, const u8 *TK, const u8 *TA,
 			       u32 IV32)
 {
 	int i, j;
@@ -260,12 +260,12 @@ static void tkip_mixing_phase1(u16 * TTAK, const u8 * TK, const u8 * TA,
 	}
 }
 
-static void tkip_mixing_phase2(u8 * WEPSeed, const u8 * TK, const u16 * TTAK,
+static void tkip_mixing_phase2(u8 *WEPSeed, const u8 *TK, const u16 *TTAK,
 			       u16 IV16)
 {
 	/* Make temporary area overlap WEP seed so that the final copy can be
 	 * avoided on little endian hosts. */
-	u16 *PPK = (u16 *) & WEPSeed[4];
+	u16 *PPK = (u16 *) &WEPSeed[4];
 
 	/* Step 1 - make copy of TTAK and bring in TSC */
 	PPK[0] = TTAK[0];
@@ -276,15 +276,15 @@ static void tkip_mixing_phase2(u8 * WEPSeed, const u8 * TK, const u16 * TTAK,
 	PPK[5] = TTAK[4] + IV16;
 
 	/* Step 2 - 96-bit bijective mixing using S-box */
-	PPK[0] += _S_(PPK[5] ^ Mk16_le((__le16 *) & TK[0]));
-	PPK[1] += _S_(PPK[0] ^ Mk16_le((__le16 *) & TK[2]));
-	PPK[2] += _S_(PPK[1] ^ Mk16_le((__le16 *) & TK[4]));
-	PPK[3] += _S_(PPK[2] ^ Mk16_le((__le16 *) & TK[6]));
-	PPK[4] += _S_(PPK[3] ^ Mk16_le((__le16 *) & TK[8]));
-	PPK[5] += _S_(PPK[4] ^ Mk16_le((__le16 *) & TK[10]));
-
-	PPK[0] += RotR1(PPK[5] ^ Mk16_le((__le16 *) & TK[12]));
-	PPK[1] += RotR1(PPK[0] ^ Mk16_le((__le16 *) & TK[14]));
+	PPK[0] += _S_(PPK[5] ^ Mk16_le((__le16 *) &TK[0]));
+	PPK[1] += _S_(PPK[0] ^ Mk16_le((__le16 *) &TK[2]));
+	PPK[2] += _S_(PPK[1] ^ Mk16_le((__le16 *) &TK[4]));
+	PPK[3] += _S_(PPK[2] ^ Mk16_le((__le16 *) &TK[6]));
+	PPK[4] += _S_(PPK[3] ^ Mk16_le((__le16 *) &TK[8]));
+	PPK[5] += _S_(PPK[4] ^ Mk16_le((__le16 *) &TK[10]));
+
+	PPK[0] += RotR1(PPK[5] ^ Mk16_le((__le16 *) &TK[12]));
+	PPK[1] += RotR1(PPK[0] ^ Mk16_le((__le16 *) &TK[14]));
 	PPK[2] += RotR1(PPK[1]);
 	PPK[3] += RotR1(PPK[2]);
 	PPK[4] += RotR1(PPK[3]);
@@ -295,7 +295,7 @@ static void tkip_mixing_phase2(u8 * WEPSeed, const u8 * TK, const u16 * TTAK,
 	WEPSeed[0] = Hi8(IV16);
 	WEPSeed[1] = (Hi8(IV16) | 0x20) & 0x7F;
 	WEPSeed[2] = Lo8(IV16);
-	WEPSeed[3] = Lo8((PPK[5] ^ Mk16_le((__le16 *) & TK[0])) >> 1);
+	WEPSeed[3] = Lo8((PPK[5] ^ Mk16_le((__le16 *) &TK[0])) >> 1);
 
 #ifdef __BIG_ENDIAN
 	{
@@ -307,7 +307,7 @@ static void tkip_mixing_phase2(u8 * WEPSeed, const u8 * TK, const u16 * TTAK,
 }
 
 static int lib80211_tkip_hdr(struct sk_buff *skb, int hdr_len,
-			      u8 * rc4key, int keylen, void *priv)
+			      u8 *rc4key, int keylen, void *priv)
 {
 	struct lib80211_tkip_data *tkey = priv;
 	u8 *pos;
@@ -523,8 +523,8 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	return keyidx;
 }
 
-static int michael_mic(struct crypto_hash *tfm_michael, u8 * key, u8 * hdr,
-		       u8 * data, size_t data_len, u8 * mic)
+static int michael_mic(struct crypto_hash *tfm_michael, u8 *key, u8 *hdr,
+		       u8 *data, size_t data_len, u8 *mic)
 {
 	struct hash_desc desc;
 	struct scatterlist sg[2];
@@ -545,7 +545,7 @@ static int michael_mic(struct crypto_hash *tfm_michael, u8 * key, u8 * hdr,
 	return crypto_hash_digest(&desc, sg, data_len + 16, mic);
 }
 
-static void michael_mic_hdr(struct sk_buff *skb, u8 * hdr)
+static void michael_mic_hdr(struct sk_buff *skb, u8 *hdr)
 {
 	struct ieee80211_hdr *hdr11;
 
@@ -659,7 +659,7 @@ static int lib80211_michael_mic_verify(struct sk_buff *skb, int keyidx,
 	return 0;
 }
 
-static int lib80211_tkip_set_key(void *key, int len, u8 * seq, void *priv)
+static int lib80211_tkip_set_key(void *key, int len, u8 *seq, void *priv)
 {
 	struct lib80211_tkip_data *tkey = priv;
 	int keyidx;
@@ -692,7 +692,7 @@ static int lib80211_tkip_set_key(void *key, int len, u8 * seq, void *priv)
 	return 0;
 }
 
-static int lib80211_tkip_get_key(void *key, int len, u8 * seq, void *priv)
+static int lib80211_tkip_get_key(void *key, int len, u8 *seq, void *priv)
 {
 	struct lib80211_tkip_data *tkey = priv;
 
diff --git a/net/wireless/lib80211_crypt_wep.c b/net/wireless/lib80211_crypt_wep.c
index c130401..2fd03fa 100644
--- a/net/wireless/lib80211_crypt_wep.c
+++ b/net/wireless/lib80211_crypt_wep.c
@@ -228,7 +228,7 @@ static int lib80211_wep_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	return 0;
 }
 
-static int lib80211_wep_set_key(void *key, int len, u8 * seq, void *priv)
+static int lib80211_wep_set_key(void *key, int len, u8 *seq, void *priv)
 {
 	struct lib80211_wep_data *wep = priv;
 
@@ -241,7 +241,7 @@ static int lib80211_wep_set_key(void *key, int len, u8 * seq, void *priv)
 	return 0;
 }
 
-static int lib80211_wep_get_key(void *key, int len, u8 * seq, void *priv)
+static int lib80211_wep_get_key(void *key, int len, u8 *seq, void *priv)
 {
 	struct lib80211_wep_data *wep = priv;
 
diff --git a/net/wireless/mesh.c b/net/wireless/mesh.c
index 8c550df..a3c1508 100644
--- a/net/wireless/mesh.c
+++ b/net/wireless/mesh.c
@@ -118,7 +118,7 @@ int cfg80211_join_mesh(struct cfg80211_registered_device *rdev,
 }
 
 void cfg80211_notify_new_peer_candidate(struct net_device *dev,
-		const u8 *macaddr, const u8* ie, u8 ie_len, gfp_t gfp)
+		const u8 *macaddr, const u8 *ie, u8 ie_len, gfp_t gfp)
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index 438dfc1..56983a5 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -512,9 +512,9 @@ void cfg80211_oper_and_ht_capa(struct ieee80211_ht_cap *ht_capa,
 		return;
 	}
 
-	p1 = (u8*)(ht_capa);
-	p2 = (u8*)(ht_capa_mask);
-	for (i = 0; i<sizeof(*ht_capa); i++)
+	p1 = (u8 *)(ht_capa);
+	p2 = (u8 *)(ht_capa_mask);
+	for (i = 0; i < sizeof(*ht_capa); i++)
 		p1[i] &= p2[i];
 }
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index afeea32..4cdcccd 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2078,7 +2078,7 @@ static int nl80211_del_key(struct sk_buff *skb, struct genl_info *info)
 
 static int nl80211_addset_beacon(struct sk_buff *skb, struct genl_info *info)
 {
-        int (*call)(struct wiphy *wiphy, struct net_device *dev,
+	int (*call)(struct wiphy *wiphy, struct net_device *dev,
 		    struct beacon_parameters *info);
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct net_device *dev = info->user_ptr[1];
@@ -7285,7 +7285,7 @@ void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
 
 void nl80211_send_new_peer_candidate(struct cfg80211_registered_device *rdev,
 		struct net_device *netdev,
-		const u8 *macaddr, const u8* ie, u8 ie_len,
+		const u8 *macaddr, const u8 *ie, u8 ie_len,
 		gfp_t gfp)
 {
 	struct sk_buff *msg;
@@ -7895,7 +7895,7 @@ void cfg80211_report_obss_beacon(struct wiphy *wiphy,
 }
 EXPORT_SYMBOL(cfg80211_report_obss_beacon);
 
-static int nl80211_netlink_notify(struct notifier_block * nb,
+static int nl80211_netlink_notify(struct notifier_block *nb,
 				  unsigned long state,
 				  void *_notify)
 {
diff --git a/net/wireless/nl80211.h b/net/wireless/nl80211.h
index 12bf4d1..20f1f48 100644
--- a/net/wireless/nl80211.h
+++ b/net/wireless/nl80211.h
@@ -56,7 +56,7 @@ void nl80211_send_disconnected(struct cfg80211_registered_device *rdev,
 
 void nl80211_send_new_peer_candidate(struct cfg80211_registered_device *rdev,
 				     struct net_device *netdev,
-				     const u8 *macaddr, const u8* ie, u8 ie_len,
+				     const u8 *macaddr, const u8 *ie, u8 ie_len,
 				     gfp_t gfp);
 void
 nl80211_michael_mic_failure(struct cfg80211_registered_device *rdev,
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index f65feaa..d800342 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -147,8 +147,8 @@ static const struct ieee80211_regdomain world_regdom = {
 			NL80211_RRF_NO_OFDM),
 		/* IEEE 802.11a, channel 36..48 */
 		REG_RULE(5180-10, 5240+10, 40, 6, 20,
-                        NL80211_RRF_PASSIVE_SCAN |
-                        NL80211_RRF_NO_IBSS),
+			NL80211_RRF_PASSIVE_SCAN |
+			NL80211_RRF_NO_IBSS),
 
 		/* NB: 5260 MHz - 5700 MHz requies DFS */
 
@@ -296,7 +296,7 @@ static bool is_user_regdom_saved(void)
 		  !is_an_alpha2(user_alpha2)),
 		 "Unexpected user alpha2: %c%c\n",
 		 user_alpha2[0],
-	         user_alpha2[1]))
+		 user_alpha2[1]))
 		return false;
 
 	return true;
@@ -348,7 +348,7 @@ static void reg_regdb_search(struct work_struct *work)
 					   list);
 		list_del(&request->list);
 
-		for (i=0; i<reg_regdb_size; i++) {
+		for (i = 0; i < reg_regdb_size; i++) {
 			curdom = reg_regdb[i];
 
 			if (!memcmp(request->alpha2, curdom->alpha2, 2)) {
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 31119e3..f7cad4b 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -176,7 +176,7 @@ static void bss_release(struct kref *ref)
 
 /* must hold dev->bss_lock! */
 void cfg80211_bss_age(struct cfg80211_registered_device *dev,
-                      unsigned long age_secs)
+		      unsigned long age_secs)
 {
 	struct cfg80211_internal_bss *bss;
 	unsigned long age_jiffies = msecs_to_jiffies(age_secs * MSEC_PER_SEC);
@@ -810,7 +810,7 @@ cfg80211_inform_bss_frame(struct wiphy *wiphy,
 		return NULL;
 
 	if (WARN_ON(wiphy->signal_type == CFG80211_SIGNAL_TYPE_UNSPEC &&
-	            (signal < 0 || signal > 100)))
+		    (signal < 0 || signal > 100)))
 		return NULL;
 
 	if (WARN_ON(len < offsetof(struct ieee80211_mgmt, u.probe_resp.variable)))
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 9aa9db6..39192d4 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -357,10 +357,10 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
 			if (meshdr->flags & MESH_FLAGS_AE_A5_A6) {
 				skb_copy_bits(skb, hdrlen +
 					offsetof(struct ieee80211s_hdr, eaddr1),
-				       	dst, ETH_ALEN);
+					dst, ETH_ALEN);
 				skb_copy_bits(skb, hdrlen +
 					offsetof(struct ieee80211s_hdr, eaddr2),
-				        src, ETH_ALEN);
+					src, ETH_ALEN);
 			}
 			hdrlen += ieee80211_get_mesh_hdrlen(meshdr);
 		}
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index 3c24eb9..063a62c 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -219,7 +219,7 @@ int cfg80211_wext_giwrange(struct net_device *dev,
 		}
 	}
 
-	for (band = 0; band < IEEE80211_NUM_BANDS; band ++) {
+	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
 		struct ieee80211_supported_band *sband;
 
 		sband = wdev->wiphy->bands[band];
@@ -965,7 +965,7 @@ static int cfg80211_set_wpa_version(struct wireless_dev *wdev, u32 wpa_versions)
 {
 	if (wpa_versions & ~(IW_AUTH_WPA_VERSION_WPA |
 			     IW_AUTH_WPA_VERSION_WPA2|
-		             IW_AUTH_WPA_VERSION_DISABLED))
+			     IW_AUTH_WPA_VERSION_DISABLED))
 		return -EINVAL;
 
 	if ((wpa_versions & IW_AUTH_WPA_VERSION_DISABLED) &&
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 0af7f54..d23569e 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -416,12 +416,12 @@ static struct nlmsghdr *rtnetlink_ifinfo_prep(struct net_device *dev,
  * Send the event on the appropriate channels.
  * May be called from interrupt context.
  */
-void wireless_send_event(struct net_device *	dev,
+void wireless_send_event(struct net_device	*dev,
 			 unsigned int		cmd,
-			 union iwreq_data *	wrqu,
-			 const char *		extra)
+			 union iwreq_data	*wrqu,
+			 const char		*extra)
 {
-	const struct iw_ioctl_description *	descr = NULL;
+	const struct iw_ioctl_description	*descr = NULL;
 	int extra_len = 0;
 	struct iw_event  *event;		/* Mallocated whole event */
 	int event_len;				/* Its size */
@@ -625,10 +625,10 @@ struct iw_statistics *get_wireless_stats(struct net_device *dev)
 	return NULL;
 }
 
-static int iw_handler_get_iwstats(struct net_device *		dev,
-				  struct iw_request_info *	info,
-				  union iwreq_data *		wrqu,
-				  char *			extra)
+static int iw_handler_get_iwstats(struct net_device		*dev,
+				  struct iw_request_info	*info,
+				  union iwreq_data		*wrqu,
+				  char				*extra)
 {
 	/* Get stats from the driver */
 	struct iw_statistics *stats;
@@ -964,13 +964,13 @@ static int wext_ioctl_dispatch(struct net *net, struct ifreq *ifr,
  * We do various checks and also take care of moving data between
  * user space and kernel space.
  */
-static int ioctl_standard_call(struct net_device *	dev,
+static int ioctl_standard_call(struct net_device	*dev,
 			       struct iwreq		*iwr,
 			       unsigned int		cmd,
 			       struct iw_request_info	*info,
 			       iw_handler		handler)
 {
-	const struct iw_ioctl_description *	descr;
+	const struct iw_ioctl_description	*descr;
 	int					ret = -EINVAL;
 
 	/* Get the description of the IOCTL */
diff --git a/net/wireless/wext-priv.c b/net/wireless/wext-priv.c
index 674d426..f44bccd 100644
--- a/net/wireless/wext-priv.c
+++ b/net/wireless/wext-priv.c
@@ -13,10 +13,10 @@
 #include <net/iw_handler.h>
 #include <net/wext.h>
 
-int iw_handler_get_private(struct net_device *		dev,
-			   struct iw_request_info *	info,
-			   union iwreq_data *		wrqu,
-			   char *			extra)
+int iw_handler_get_private(struct net_device		*dev,
+			   struct iw_request_info	*info,
+			   union iwreq_data		*wrqu,
+			   char				*extra)
 {
 	/* Check if the driver has something to export */
 	if ((dev->wireless_handlers->num_private_args == 0) ||
diff --git a/net/wireless/wext-spy.c b/net/wireless/wext-spy.c
index 5d643a5..1a66f2b 100644
--- a/net/wireless/wext-spy.c
+++ b/net/wireless/wext-spy.c
@@ -23,13 +23,13 @@ static inline struct iw_spy_data *get_spydata(struct net_device *dev)
 	return NULL;
 }
 
-int iw_handler_set_spy(struct net_device *	dev,
-		       struct iw_request_info *	info,
-		       union iwreq_data *	wrqu,
-		       char *			extra)
+int iw_handler_set_spy(struct net_device	*dev,
+		       struct iw_request_info	*info,
+		       union iwreq_data		*wrqu,
+		       char			*extra)
 {
-	struct iw_spy_data *	spydata = get_spydata(dev);
-	struct sockaddr *	address = (struct sockaddr *) extra;
+	struct iw_spy_data	*spydata = get_spydata(dev);
+	struct sockaddr		*address = (struct sockaddr *) extra;
 
 	/* Make sure driver is not buggy or using the old API */
 	if (!spydata)
@@ -71,13 +71,13 @@ int iw_handler_set_spy(struct net_device *	dev,
 }
 EXPORT_SYMBOL(iw_handler_set_spy);
 
-int iw_handler_get_spy(struct net_device *	dev,
-		       struct iw_request_info *	info,
-		       union iwreq_data *	wrqu,
-		       char *			extra)
+int iw_handler_get_spy(struct net_device	*dev,
+		       struct iw_request_info	*info,
+		       union iwreq_data		*wrqu,
+		       char			*extra)
 {
-	struct iw_spy_data *	spydata = get_spydata(dev);
-	struct sockaddr *	address = (struct sockaddr *) extra;
+	struct iw_spy_data	*spydata = get_spydata(dev);
+	struct sockaddr		*address = (struct sockaddr *) extra;
 	int			i;
 
 	/* Make sure driver is not buggy or using the old API */
@@ -87,7 +87,7 @@ int iw_handler_get_spy(struct net_device *	dev,
 	wrqu->data.length = spydata->spy_number;
 
 	/* Copy addresses. */
-	for (i = 0; i < spydata->spy_number; i++) 	{
+	for (i = 0; i < spydata->spy_number; i++) {
 		memcpy(address[i].sa_data, spydata->spy_address[i], ETH_ALEN);
 		address[i].sa_family = AF_UNIX;
 	}
@@ -107,13 +107,13 @@ EXPORT_SYMBOL(iw_handler_get_spy);
 /*
  * Standard Wireless Handler : set spy threshold
  */
-int iw_handler_set_thrspy(struct net_device *	dev,
-			  struct iw_request_info *info,
-			  union iwreq_data *	wrqu,
-			  char *		extra)
+int iw_handler_set_thrspy(struct net_device		*dev,
+			  struct iw_request_info	*info,
+			  union iwreq_data		*wrqu,
+			  char				*extra)
 {
-	struct iw_spy_data *	spydata = get_spydata(dev);
-	struct iw_thrspy *	threshold = (struct iw_thrspy *) extra;
+	struct iw_spy_data	*spydata = get_spydata(dev);
+	struct iw_thrspy	*threshold = (struct iw_thrspy *) extra;
 
 	/* Make sure driver is not buggy or using the old API */
 	if (!spydata)
@@ -134,13 +134,13 @@ EXPORT_SYMBOL(iw_handler_set_thrspy);
 /*
  * Standard Wireless Handler : get spy threshold
  */
-int iw_handler_get_thrspy(struct net_device *	dev,
-			  struct iw_request_info *info,
-			  union iwreq_data *	wrqu,
-			  char *		extra)
+int iw_handler_get_thrspy(struct net_device		*dev,
+			  struct iw_request_info	*info,
+			  union iwreq_data		*wrqu,
+			  char				*extra)
 {
-	struct iw_spy_data *	spydata = get_spydata(dev);
-	struct iw_thrspy *	threshold = (struct iw_thrspy *) extra;
+	struct iw_spy_data	*spydata = get_spydata(dev);
+	struct iw_thrspy	*threshold = (struct iw_thrspy *) extra;
 
 	/* Make sure driver is not buggy or using the old API */
 	if (!spydata)
@@ -158,10 +158,10 @@ EXPORT_SYMBOL(iw_handler_get_thrspy);
 /*
  * Prepare and send a Spy Threshold event
  */
-static void iw_send_thrspy_event(struct net_device *	dev,
-				 struct iw_spy_data *	spydata,
-				 unsigned char *	address,
-				 struct iw_quality *	wstats)
+static void iw_send_thrspy_event(struct net_device	*dev,
+				 struct iw_spy_data	*spydata,
+				 unsigned char		*address,
+				 struct iw_quality	*wstats)
 {
 	union iwreq_data	wrqu;
 	struct iw_thrspy	threshold;
@@ -189,11 +189,11 @@ static void iw_send_thrspy_event(struct net_device *	dev,
  * small, this is good enough. If we wanted to support larger number of
  * spy addresses, we should use something more efficient...
  */
-void wireless_spy_update(struct net_device *	dev,
-			 unsigned char *	address,
-			 struct iw_quality *	wstats)
+void wireless_spy_update(struct net_device	*dev,
+			 unsigned char		*address,
+			 struct iw_quality	*wstats)
 {
-	struct iw_spy_data *	spydata = get_spydata(dev);
+	struct iw_spy_data	*spydata = get_spydata(dev);
 	int			i;
 	int			match = -1;
 
-- 
1.7.5.4
