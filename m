From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 04/21] wireless: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 20:55:35 -0700
Message-ID: <bb2235c257e347354d94478bd1be35b89bf90186.1350618009.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Luciano Coelho <coelho@ti.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, b43-dev@lists.infradead.org,
	brcm80211-dev-list@broadcom.com, users@rt2x00.serialmonkey.com
To: "John W. Linville" <linville@tuxdriver.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Bing Zhao <bzhao@marvell.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	A
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/adm8211.c                     |    2 +-
 drivers/net/wireless/airo.c                        |    4 ++--
 drivers/net/wireless/at76c50x-usb.c                |    8 ++++----
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    8 ++++----
 drivers/net/wireless/ath/ath6kl/main.c             |    8 ++++----
 drivers/net/wireless/ath/ath6kl/txrx.c             |   10 +++++-----
 drivers/net/wireless/ath/ath9k/recv.c              |    8 ++++----
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/b43legacy/main.c              |    2 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    4 ++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   16 ++++++++--------
 drivers/net/wireless/hostap/hostap_info.c          |    2 +-
 drivers/net/wireless/hostap/hostap_ioctl.c         |    8 ++++----
 drivers/net/wireless/hostap/hostap_main.c          |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |    6 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c             |   18 +++++++++---------
 drivers/net/wireless/ipw2x00/libipw_rx.c           |   12 ++++++------
 drivers/net/wireless/ipw2x00/libipw_tx.c           |    4 ++--
 drivers/net/wireless/iwlegacy/3945-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/common.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |    2 +-
 drivers/net/wireless/libertas_tf/main.c            |    2 +-
 drivers/net/wireless/mwifiex/join.c                |    2 +-
 drivers/net/wireless/mwifiex/scan.c                |    2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |    2 +-
 drivers/net/wireless/mwl8k.c                       |    2 +-
 drivers/net/wireless/orinoco/wext.c                |    4 ++--
 drivers/net/wireless/p54/eeprom.c                  |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |   18 +++++++++---------
 drivers/net/wireless/rt2x00/rt2400pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    8 ++++----
 drivers/net/wireless/rt2x00/rt61pci.c              |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |    4 ++--
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |    4 ++--
 drivers/net/wireless/rtlwifi/base.c                |    6 +++---
 drivers/net/wireless/rtlwifi/cam.c                 |    2 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    8 ++++----
 drivers/net/wireless/rtlwifi/rc.c                  |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    4 ++--
 drivers/net/wireless/rtlwifi/usb.c                 |   12 ++++++------
 drivers/net/wireless/ti/wl1251/main.c              |   12 ++++++------
 drivers/net/wireless/ti/wlcore/cmd.c               |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |    6 +++---
 drivers/net/wireless/ti/wlcore/tx.c                |    2 +-
 drivers/net/wireless/wl3501_cs.c                   |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |    2 +-
 55 files changed, 133 insertions(+), 133 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 154a496..2fd62a0 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1853,7 +1853,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 	*(__le16 *)&perm_addr[4] =
 		cpu_to_le16(ADM8211_CSR_READ(PAR1) & 0xFFFF);
 
-	if (!is_valid_ether_addr(perm_addr)) {
+	if (!eth_addr_valid(perm_addr)) {
 		printk(KERN_WARNING "%s (adm8211): Invalid hwaddr in EEPROM!\n",
 		       pci_name(pdev));
 		eth_random_addr(perm_addr);
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 3cd05a71..b0afd59 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -5986,8 +5986,8 @@ static int airo_set_wap(struct net_device *dev,
 
 	if (awrq->sa_family != ARPHRD_ETHER)
 		return -EINVAL;
-	else if (is_broadcast_ether_addr(awrq->sa_data) ||
-		 is_zero_ether_addr(awrq->sa_data)) {
+	else if (eth_addr_broadcast(awrq->sa_data) ||
+		 eth_addr_zero(awrq->sa_data)) {
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd=CMD_LOSE_SYNC;
 		if (down_interruptible(&local->sem))
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 99b9ddf..3ed5523 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -1658,7 +1658,7 @@ static void at76_work_join_bssid(struct work_struct *work)
 
 	mutex_lock(&priv->mtx);
 
-	if (is_valid_ether_addr(priv->bssid))
+	if (eth_addr_valid(priv->bssid))
 		at76_join(priv);
 
 	mutex_unlock(&priv->mtx);
@@ -1874,7 +1874,7 @@ static void at76_dwork_hw_scan(struct work_struct *work)
 		return;
 	}
 
-	if (is_valid_ether_addr(priv->bssid))
+	if (eth_addr_valid(priv->bssid))
 		at76_join(priv);
 
 	mutex_unlock(&priv->mtx);
@@ -1952,7 +1952,7 @@ static int at76_config(struct ieee80211_hw *hw, u32 changed)
 
 	priv->channel = hw->conf.channel->hw_value;
 
-	if (is_valid_ether_addr(priv->bssid))
+	if (eth_addr_valid(priv->bssid))
 		at76_join(priv);
 	else
 		at76_start_monitor(priv);
@@ -1980,7 +1980,7 @@ static void at76_bss_info_changed(struct ieee80211_hw *hw,
 
 	memcpy(priv->bssid, conf->bssid, ETH_ALEN);
 
-	if (is_valid_ether_addr(priv->bssid))
+	if (eth_addr_valid(priv->bssid))
 		/* mac80211 is joining a bss */
 		at76_join(priv);
 
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 7089f81..42c605a 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -455,7 +455,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	if (test_bit(SKIP_SCAN, &ar->flag) &&
 	    ((sme->channel && sme->channel->center_freq == 0) ||
-	     (sme->bssid && is_zero_ether_addr(sme->bssid)))) {
+	     (sme->bssid && eth_addr_zero(sme->bssid)))) {
 		ath6kl_err("SkipScan: channel or bssid invalid\n");
 		return -EINVAL;
 	}
@@ -521,7 +521,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 		vif->ch_hint = sme->channel->center_freq;
 
 	memset(vif->req_bssid, 0, sizeof(vif->req_bssid));
-	if (sme->bssid && !is_broadcast_ether_addr(sme->bssid))
+	if (sme->bssid && !eth_addr_broadcast(sme->bssid))
 		memcpy(vif->req_bssid, sme->bssid, sizeof(vif->req_bssid));
 
 	ath6kl_set_wpa_version(vif, sme->crypto.wpa_versions);
@@ -1628,7 +1628,7 @@ static int ath6kl_cfg80211_join_ibss(struct wiphy *wiphy,
 	}
 
 	memset(vif->req_bssid, 0, sizeof(vif->req_bssid));
-	if (ibss_param->bssid && !is_broadcast_ether_addr(ibss_param->bssid))
+	if (ibss_param->bssid && !eth_addr_broadcast(ibss_param->bssid))
 		memcpy(vif->req_bssid, ibss_param->bssid,
 		       sizeof(vif->req_bssid));
 
@@ -3066,7 +3066,7 @@ static bool ath6kl_mgmt_powersave_ap(struct ath6kl_vif *vif,
 	struct ath6kl *ar = vif->ar;
 
 	mgmt = (struct ieee80211_mgmt *) buf;
-	if (is_multicast_ether_addr(mgmt->da))
+	if (eth_addr_multicast(mgmt->da))
 		return false;
 
 	conn = ath6kl_find_sta(vif, mgmt->da);
diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index c189e28..c90b53b 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -115,14 +115,14 @@ static u8 ath6kl_remove_sta(struct ath6kl *ar, u8 *mac, u16 reason)
 {
 	u8 i, removed = 0;
 
-	if (is_zero_ether_addr(mac))
+	if (eth_addr_zero(mac))
 		return removed;
 
-	if (is_broadcast_ether_addr(mac)) {
+	if (eth_addr_broadcast(mac)) {
 		ath6kl_dbg(ATH6KL_DBG_TRC, "deleting all station\n");
 
 		for (i = 0; i < AP_MAX_NUM_STA; i++) {
-			if (!is_zero_ether_addr(ar->sta_list[i].mac)) {
+			if (!eth_addr_zero(ar->sta_list[i].mac)) {
 				ath6kl_sta_cleanup(ar, i);
 				removed = 1;
 			}
@@ -999,7 +999,7 @@ void ath6kl_disconnect_event(struct ath6kl_vif *vif, u8 reason, u8 *bssid,
 						       MCAST_AID, 0);
 		}
 
-		if (!is_broadcast_ether_addr(bssid)) {
+		if (!eth_addr_broadcast(bssid)) {
 			/* send event to application */
 			cfg80211_del_sta(vif->ndev, bssid, GFP_KERNEL);
 		}
diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index 7dfa0fd..159ef34 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -50,7 +50,7 @@ static u8 ath6kl_ibss_map_epid(struct sk_buff *skb, struct net_device *dev,
 	datap = skb->data;
 	eth_hdr = (struct ethhdr *) (datap + sizeof(struct wmi_data_hdr));
 
-	if (is_multicast_ether_addr(eth_hdr->h_dest))
+	if (eth_addr_multicast(eth_hdr->h_dest))
 		return ENDPOINT_2;
 
 	for (i = 0; i < ar->node_num; i++) {
@@ -212,7 +212,7 @@ static bool ath6kl_powersave_ap(struct ath6kl_vif *vif, struct sk_buff *skb,
 	bool ps_queued = false;
 	struct ath6kl *ar = vif->ar;
 
-	if (is_multicast_ether_addr(datap->h_dest)) {
+	if (eth_addr_multicast(datap->h_dest)) {
 		u8 ctr = 0;
 		bool q_mcast = false;
 
@@ -1544,7 +1544,7 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 
 	if (vif->nw_type == AP_NETWORK) {
 		datap = (struct ethhdr *) skb->data;
-		if (is_multicast_ether_addr(datap->h_dest))
+		if (eth_addr_multicast(datap->h_dest))
 			/*
 			 * Bcast/Mcast frames should be sent to the
 			 * OS stack as well as on the air.
@@ -1578,7 +1578,7 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 
 	datap = (struct ethhdr *) skb->data;
 
-	if (is_unicast_ether_addr(datap->h_dest)) {
+	if (eth_addr_unicast(datap->h_dest)) {
 		if (vif->nw_type == AP_NETWORK) {
 			conn = ath6kl_find_sta(vif, datap->h_source);
 			if (!conn)
@@ -1592,7 +1592,7 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 			/* aggregation code will handle the skb */
 			return;
 		}
-	} else if (!is_broadcast_ether_addr(datap->h_dest))
+	} else if (!eth_addr_broadcast(datap->h_dest))
 		vif->net_stats.multicast++;
 
 	ath6kl_deliver_frames_to_nw_stack(vif->ndev, skb);
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 83d16e7..777bec9 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -595,7 +595,7 @@ static void ath_rx_ps(struct ath_softc *sc, struct sk_buff *skb, bool mybeacon)
 	} else if ((sc->ps_flags & PS_WAIT_FOR_CAB) &&
 		   (ieee80211_is_data(hdr->frame_control) ||
 		    ieee80211_is_action(hdr->frame_control)) &&
-		   is_multicast_ether_addr(hdr->addr1) &&
+		   eth_addr_multicast(hdr->addr1) &&
 		   !ieee80211_has_moredata(hdr->frame_control)) {
 		/*
 		 * No more broadcast/multicast frames to be received at this
@@ -605,7 +605,7 @@ static void ath_rx_ps(struct ath_softc *sc, struct sk_buff *skb, bool mybeacon)
 		ath_dbg(common, PS,
 			"All PS CAB frames received, back to sleep\n");
 	} else if ((sc->ps_flags & PS_WAIT_FOR_PSPOLL_DATA) &&
-		   !is_multicast_ether_addr(hdr->addr1) &&
+		   !eth_addr_multicast(hdr->addr1) &&
 		   !ieee80211_has_morefrags(hdr->frame_control)) {
 		sc->ps_flags &= ~PS_WAIT_FOR_PSPOLL_DATA;
 		ath_dbg(common, PS,
@@ -774,7 +774,7 @@ static bool ath9k_rx_accept(struct ath_common *common,
 
 	fc = hdr->frame_control;
 
-	is_mc = !!is_multicast_ether_addr(hdr->addr1);
+	is_mc = !!eth_addr_multicast(hdr->addr1);
 	is_valid_tkip = rx_stats->rs_keyix != ATH9K_RXKEYIX_INVALID &&
 		test_bit(rx_stats->rs_keyix, common->tkip_keymap);
 	strip_mic = is_valid_tkip && ieee80211_is_data(fc) &&
@@ -1096,7 +1096,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		rxs = IEEE80211_SKB_RXCB(hdr_skb);
 		if (ieee80211_is_beacon(hdr->frame_control)) {
 			RX_STAT_INC(rx_beacons);
-			if (!is_zero_ether_addr(common->curbssid) &&
+			if (!eth_addr_zero(common->curbssid) &&
 			    ether_addr_equal(hdr->addr3, common->curbssid))
 				rs.is_mybeacon = true;
 			else
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 73730e9..3b1aca8 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -5334,7 +5334,7 @@ static struct b43_wl *b43_wireless_init(struct b43_bus_dev *dev)
 	wl->hw_registred = false;
 	hw->max_rates = 2;
 	SET_IEEE80211_DEV(hw, dev->dev);
-	if (is_valid_ether_addr(sprom->et1mac))
+	if (eth_addr_valid(sprom->et1mac))
 		SET_IEEE80211_PERM_ADDR(hw, sprom->et1mac);
 	else
 		SET_IEEE80211_PERM_ADDR(hw, sprom->il0mac);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 18e208e..9f95cd6 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3820,7 +3820,7 @@ static int b43legacy_wireless_init(struct ssb_device *dev)
 	hw->queues = 1; /* FIXME: hardware has more queues */
 	hw->max_rates = 2;
 	SET_IEEE80211_DEV(hw, dev->dev);
-	if (is_valid_ether_addr(sprom->et1mac))
+	if (eth_addr_valid(sprom->et1mac))
 		SET_IEEE80211_PERM_ADDR(hw, sprom->et1mac);
 	else
 		SET_IEEE80211_PERM_ADDR(hw, sprom->il0mac);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index d7c76ce..5d6b922c 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -319,7 +319,7 @@ static int brcmf_netdev_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		u8 *pktdata = (u8 *)(skb->data);
 		struct ethhdr *eh = (struct ethhdr *)pktdata;
 
-		if (is_multicast_ether_addr(eh->h_dest))
+		if (eth_addr_multicast(eh->h_dest))
 			drvr->tx_multicast++;
 		if (ntohs(eh->h_proto) == ETH_P_PAE)
 			atomic_inc(&drvr->pend_8021x_cnt);
@@ -865,7 +865,7 @@ static int brcmf_net_attach(struct brcmf_if *ifp)
 	/*
 	 * determine mac address to use
 	 */
-	if (is_valid_ether_addr(ifp->mac_addr))
+	if (eth_addr_valid(ifp->mac_addr))
 		memcpy(temp_addr, ifp->mac_addr, ETH_ALEN);
 	else
 		memcpy(temp_addr, drvr->mac, ETH_ALEN);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index c1abaa6..d773906 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -1999,7 +1999,7 @@ brcmf_add_keyext(struct wiphy *wiphy, struct net_device *ndev,
 	key.index = (u32) key_idx;
 	/* Instead of bcast for ea address for default wep keys,
 		 driver needs it to be Null */
-	if (!is_multicast_ether_addr(mac_addr))
+	if (!eth_addr_multicast(mac_addr))
 		memcpy((char *)&key.ea, (void *)mac_addr, ETH_ALEN);
 	key.len = (u32) params->key_len;
 	bssidx = brcmf_find_bssidx(cfg, ndev);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index a744ea5..f502527 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1062,7 +1062,7 @@ static struct brcms_info *brcms_attach(struct bcma_device *pdev)
 	brcms_c_regd_init(wl->wlc);
 
 	memcpy(perm, &wl->pub->cur_etheraddr, ETH_ALEN);
-	if (WARN_ON(!is_valid_ether_addr(perm)))
+	if (WARN_ON(!eth_addr_valid(perm)))
 		goto fail;
 	SET_IEEE80211_PERM_ADDR(hw, perm);
 
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 75086b3..bbe0937 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -1902,7 +1902,7 @@ static void brcms_c_get_macaddr(struct brcms_hardware *wlc_hw, u8 etheraddr[ETH_
 	struct ssb_sprom *sprom = &wlc_hw->d11core->bus->sprom;
 
 	/* If macaddr exists, use it (Sromrev4, CIS, ...). */
-	if (!is_zero_ether_addr(sprom->il0mac)) {
+	if (!eth_addr_zero(sprom->il0mac)) {
 		memcpy(etheraddr, sprom->il0mac, 6);
 		return;
 	}
@@ -4707,8 +4707,8 @@ static int brcms_b_attach(struct brcms_c_info *wlc, struct bcma_device *core,
 	/* init etheraddr state variables */
 	brcms_c_get_macaddr(wlc_hw, wlc_hw->etheraddr);
 
-	if (is_broadcast_ether_addr(wlc_hw->etheraddr) ||
-	    is_zero_ether_addr(wlc_hw->etheraddr)) {
+	if (eth_addr_broadcast(wlc_hw->etheraddr) ||
+	    eth_addr_zero(wlc_hw->etheraddr)) {
 		wiphy_err(wiphy, "wl%d: brcms_b_attach: bad macaddr\n",
 			  unit);
 		err = 22;
@@ -6764,7 +6764,7 @@ brcms_c_d11hdrs_mac80211(struct brcms_c_info *wlc, struct ieee80211_hw *hw,
 		if (!rspec_active(rspec[k])) {
 			rspec[k] = BRCM_RATE_1M;
 		} else {
-			if (!is_multicast_ether_addr(h->addr1)) {
+			if (!eth_addr_multicast(h->addr1)) {
 				/* set tx antenna config */
 				brcms_c_antsel_antcfg_get(wlc->asi, false,
 					false, 0, 0, &antcfg, &fbantcfg);
@@ -6905,7 +6905,7 @@ brcms_c_d11hdrs_mac80211(struct brcms_c_info *wlc, struct ieee80211_hw *hw,
 	/* (2) PROTECTION, may change rspec */
 	if ((ieee80211_is_data(h->frame_control) ||
 	    ieee80211_is_mgmt(h->frame_control)) &&
-	    (phylen > wlc->RTSThresh) && !is_multicast_ether_addr(h->addr1))
+	    (phylen > wlc->RTSThresh) && !eth_addr_multicast(h->addr1))
 		use_rts = true;
 
 	/* (3) PLCP: determine PLCP header and MAC duration,
@@ -6928,7 +6928,7 @@ brcms_c_d11hdrs_mac80211(struct brcms_c_info *wlc, struct ieee80211_hw *hw,
 
 	/* DUR field for main rate */
 	if (!ieee80211_is_pspoll(h->frame_control) &&
-	    !is_multicast_ether_addr(h->addr1) && !use_rifs) {
+	    !eth_addr_multicast(h->addr1) && !use_rifs) {
 		durid =
 		    brcms_c_compute_frame_dur(wlc, rspec[0], preamble_type[0],
 					  next_frag_len);
@@ -6946,7 +6946,7 @@ brcms_c_d11hdrs_mac80211(struct brcms_c_info *wlc, struct ieee80211_hw *hw,
 	/* DUR field for fallback rate */
 	if (ieee80211_is_pspoll(h->frame_control))
 		txh->FragDurFallback = h->duration_id;
-	else if (is_multicast_ether_addr(h->addr1) || use_rifs)
+	else if (eth_addr_multicast(h->addr1) || use_rifs)
 		txh->FragDurFallback = 0;
 	else {
 		durid = brcms_c_compute_frame_dur(wlc, rspec[1],
@@ -6958,7 +6958,7 @@ brcms_c_d11hdrs_mac80211(struct brcms_c_info *wlc, struct ieee80211_hw *hw,
 	if (frag == 0)
 		mcl |= TXC_STARTMSDU;
 
-	if (!is_multicast_ether_addr(h->addr1))
+	if (!eth_addr_multicast(h->addr1))
 		mcl |= TXC_IMMEDACK;
 
 	if (wlc->band->bandtype == BRCM_BAND_5G)
diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/hostap/hostap_info.c
index 970a48b..239e213 100644
--- a/drivers/net/wireless/hostap/hostap_info.c
+++ b/drivers/net/wireless/hostap/hostap_info.c
@@ -464,7 +464,7 @@ static void handle_info_queue_scanresults(local_info_t *local)
 		prism2_host_roaming(local);
 
 	if (local->host_roaming == 2 && local->iw_mode == IW_MODE_INFRA &&
-	    !is_zero_ether_addr(local->preferred_ap)) {
+	    !eth_addr_zero(local->preferred_ap)) {
 		/*
 		 * Firmware seems to be getting into odd state in host_roaming
 		 * mode 2 when hostscan is used without join command, so try
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index ac07473..e37beee 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -3222,7 +3222,7 @@ static int prism2_ioctl_siwencodeext(struct net_device *dev,
 		return -EINVAL;
 
 	addr = ext->addr.sa_data;
-	if (is_broadcast_ether_addr(addr)) {
+	if (eth_addr_broadcast(addr)) {
 		sta_ptr = NULL;
 		crypt = &local->crypt_info.crypt[i];
 	} else {
@@ -3394,7 +3394,7 @@ static int prism2_ioctl_giwencodeext(struct net_device *dev,
 		i--;
 
 	addr = ext->addr.sa_data;
-	if (is_broadcast_ether_addr(addr)) {
+	if (eth_addr_broadcast(addr)) {
 		sta_ptr = NULL;
 		crypt = &local->crypt_info.crypt[i];
 	} else {
@@ -3457,7 +3457,7 @@ static int prism2_ioctl_set_encryption(local_info_t *local,
 	    param->u.crypt.key_len)
 		return -EINVAL;
 
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		if (param->u.crypt.idx >= WEP_KEYS)
 			return -EINVAL;
 		sta_ptr = NULL;
@@ -3590,7 +3590,7 @@ static int prism2_ioctl_get_encryption(local_info_t *local,
 	if (max_key_len < 0)
 		return -EINVAL;
 
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		sta_ptr = NULL;
 		if (param->u.crypt.idx >= WEP_KEYS)
 			param->u.crypt.idx = local->crypt_info.tx_keyidx;
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 15f0fad..19197ed 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -1084,7 +1084,7 @@ int prism2_sta_deauth(local_info_t *local, u16 reason)
 	__le16 val = cpu_to_le16(reason);
 
 	if (local->iw_mode != IW_MODE_INFRA ||
-	    is_zero_ether_addr(local->bssid) ||
+	    eth_addr_zero(local->bssid) ||
 	    memcmp(local->bssid, "\x44\x44\x44\x44\x44\x44", ETH_ALEN) == 0)
 		return 0;
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 29b8fa1..a67ba42 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -5821,7 +5821,7 @@ static int ipw2100_set_address(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	int err = 0;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	mutex_lock(&priv->action_mutex);
@@ -6972,8 +6972,8 @@ static int ipw2100_wx_set_wap(struct net_device *dev,
 		goto done;
 	}
 
-	if (is_broadcast_ether_addr(wrqu->ap_addr.sa_data) ||
-	    is_zero_ether_addr(wrqu->ap_addr.sa_data)) {
+	if (eth_addr_broadcast(wrqu->ap_addr.sa_data) ||
+	    eth_addr_zero(wrqu->ap_addr.sa_data)) {
 		/* we disable mandatory BSSID association */
 		IPW_DEBUG_WX("exit - disable mandatory BSSID\n");
 		priv->config &= ~CFG_STATIC_BSSID;
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 935120f..cf64853 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -7277,7 +7277,7 @@ static int ipw_is_qos_active(struct net_device *dev,
 	struct libipw_qos_data *qos_data = NULL;
 	int active, supported;
 	u8 *daddr = skb->data + ETH_ALEN;
-	int unicast = !is_multicast_ether_addr(daddr);
+	int unicast = !eth_addr_multicast(daddr);
 
 	if (!(priv->status & STATUS_ASSOCIATED))
 		return 0;
@@ -7836,7 +7836,7 @@ static void ipw_handle_data_packet(struct ipw_priv *priv,
 	/* HW decrypt will not clear the WEP bit, MIC, PN, etc. */
 	hdr = (struct libipw_hdr_4addr *)rxb->skb->data;
 	if (priv->ieee->iw_mode != IW_MODE_MONITOR &&
-	    (is_multicast_ether_addr(hdr->addr1) ?
+	    (eth_addr_multicast(hdr->addr1) ?
 	     !priv->ieee->host_mc_decrypt : !priv->ieee->host_decrypt))
 		ipw_rebuild_decrypted_skb(priv, rxb->skb);
 
@@ -8222,7 +8222,7 @@ static int is_network_packet(struct ipw_priv *priv,
 			return 0;
 
 		/* {broad,multi}cast packets to our BSSID go through */
-		if (is_multicast_ether_addr(header->addr1))
+		if (eth_addr_multicast(header->addr1))
 			return !memcmp(header->addr3, priv->bssid, ETH_ALEN);
 
 		/* packets to our adapter go through */
@@ -8235,7 +8235,7 @@ static int is_network_packet(struct ipw_priv *priv,
 			return 0;
 
 		/* {broad,multi}cast packets to our BSS go through */
-		if (is_multicast_ether_addr(header->addr1))
+		if (eth_addr_multicast(header->addr1))
 			return !memcmp(header->addr2, priv->bssid, ETH_ALEN);
 
 		/* packets to our adapter go through */
@@ -9040,8 +9040,8 @@ static int ipw_wx_set_wap(struct net_device *dev,
 	if (wrqu->ap_addr.sa_family != ARPHRD_ETHER)
 		return -EINVAL;
 	mutex_lock(&priv->mutex);
-	if (is_broadcast_ether_addr(wrqu->ap_addr.sa_data) ||
-	    is_zero_ether_addr(wrqu->ap_addr.sa_data)) {
+	if (eth_addr_broadcast(wrqu->ap_addr.sa_data) ||
+	    eth_addr_zero(wrqu->ap_addr.sa_data)) {
 		/* we disable mandatory BSSID association */
 		IPW_DEBUG_WX("Setting AP BSSID to ANY\n");
 		priv->config &= ~CFG_STATIC_BSSID;
@@ -10240,7 +10240,7 @@ static int ipw_tx_skb(struct ipw_priv *priv, struct libipw_txb *txb,
 	hdr_len = libipw_get_hdrlen(le16_to_cpu(hdr->frame_ctl));
 	switch (priv->ieee->iw_mode) {
 	case IW_MODE_ADHOC:
-		unicast = !is_multicast_ether_addr(hdr->addr1);
+		unicast = !eth_addr_multicast(hdr->addr1);
 		id = ipw_find_station(priv, hdr->addr1);
 		if (id == IPW_INVALID_STATION) {
 			id = ipw_add_station(priv, hdr->addr1);
@@ -10255,7 +10255,7 @@ static int ipw_tx_skb(struct ipw_priv *priv, struct libipw_txb *txb,
 
 	case IW_MODE_INFRA:
 	default:
-		unicast = !is_multicast_ether_addr(hdr->addr3);
+		unicast = !eth_addr_multicast(hdr->addr3);
 		id = 0;
 		break;
 	}
@@ -10541,7 +10541,7 @@ static int ipw_net_set_mac_address(struct net_device *dev, void *p)
 	struct ipw_priv *priv = libipw_priv(dev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	mutex_lock(&priv->mutex);
 	priv->config |= CFG_CUSTOM_MAC;
diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index 02e0579..347b88a 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -416,8 +416,8 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 		return 1;
 	}
 
-	can_be_decrypted = (is_multicast_ether_addr(hdr->addr1) ||
-			    is_broadcast_ether_addr(hdr->addr2)) ?
+	can_be_decrypted = (eth_addr_multicast(hdr->addr1) ||
+			    eth_addr_broadcast(hdr->addr2)) ?
 	    ieee->host_mc_decrypt : ieee->host_decrypt;
 
 	if (can_be_decrypted) {
@@ -442,7 +442,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 		 * 802.11, but makes it easier to use different keys with
 		 * stations that do not support WEP key mapping). */
 
-		if (is_unicast_ether_addr(hdr->addr1) || local->bcrx_sta_key)
+		if (eth_addr_unicast(hdr->addr1) || local->bcrx_sta_key)
 			(void)hostap_handle_sta_crypto(local, hdr, &crypt,
 						       &sta);
 #endif
@@ -772,7 +772,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 
 #ifdef NOT_YET
 	if (ieee->iw_mode == IW_MODE_MASTER && !wds && ieee->ap->bridge_packets) {
-		if (is_multicast_ether_addr(dst)) {
+		if (eth_addr_multicast(dst)) {
 			/* copy multicast frame both to the higher layers and
 			 * to the wireless media */
 			ieee->ap->bridged_multicast++;
@@ -883,7 +883,7 @@ void libipw_rx_any(struct libipw_device *ieee,
 			else if (memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0)
 				is_packet_for_us = 1;
 			/* mcast */
-			else if (is_multicast_ether_addr(hdr->addr1))
+			else if (eth_addr_multicast(hdr->addr1))
 				is_packet_for_us = 1;
 		}
 		break;
@@ -898,7 +898,7 @@ void libipw_rx_any(struct libipw_device *ieee,
 			else if (memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0)
 				is_packet_for_us = 1;
 			/* mcast */
-			else if (is_multicast_ether_addr(hdr->addr1)) {
+			else if (eth_addr_multicast(hdr->addr1)) {
 				/* not our own packet bcasted from AP */
 				if (memcmp(hdr->addr3, ieee->dev->dev_addr, ETH_ALEN))
 					is_packet_for_us = 1;
diff --git a/drivers/net/wireless/ipw2x00/libipw_tx.c b/drivers/net/wireless/ipw2x00/libipw_tx.c
index e8c0398..d01deb7 100644
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c
@@ -380,8 +380,8 @@ netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (host_encrypt || ieee->host_open_frag) {
 		/* Determine fragmentation size based on destination (multicast
 		 * and broadcast are not fragmented) */
-		if (is_multicast_ether_addr(dest) ||
-		    is_broadcast_ether_addr(dest))
+		if (eth_addr_multicast(dest) ||
+		    eth_addr_broadcast(dest))
 			frag_size = MAX_FRAG_THRESHOLD;
 		else
 			frag_size = ieee->fts;
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index e252acb..ba4ff40 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -495,7 +495,7 @@ il3945_tx_skb(struct il_priv *il,
 		goto drop_unlock;
 	}
 
-	unicast = !is_multicast_ether_addr(hdr->addr1);
+	unicast = !eth_addr_multicast(hdr->addr1);
 	id = 0;
 
 	fc = hdr->frame_control;
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index eac4dc8..101b337 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -2561,7 +2561,7 @@ il4965_find_station(struct il_priv *il, const u8 *addr)
 	if (il->iw_mode == NL80211_IFTYPE_ADHOC)
 		start = IL_STA_ID;
 
-	if (is_broadcast_ether_addr(addr))
+	if (eth_addr_broadcast(addr))
 		return il->hw_params.bcast_id;
 
 	spin_lock_irqsave(&il->sta_lock, flags);
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index 318ed3c..0fad82c 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -1892,7 +1892,7 @@ il_prep_station(struct il_priv *il, const u8 *addr, bool is_ap,
 
 	if (is_ap)
 		sta_id = IL_AP_ID;
-	else if (is_broadcast_ether_addr(addr))
+	else if (eth_addr_broadcast(addr))
 		sta_id = il->hw_params.bcast_id;
 	else
 		for (i = IL_STA_ID; i < il->hw_params.max_stations; i++) {
diff --git a/drivers/net/wireless/iwlwifi/dvm/sta.c b/drivers/net/wireless/iwlwifi/dvm/sta.c
index cd9b6de..a220343 100644
--- a/drivers/net/wireless/iwlwifi/dvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/dvm/sta.c
@@ -303,7 +303,7 @@ u8 iwl_prep_station(struct iwl_priv *priv, struct iwl_rxon_context *ctx,
 
 	if (is_ap)
 		sta_id = ctx->ap_sta_id;
-	else if (is_broadcast_ether_addr(addr))
+	else if (eth_addr_broadcast(addr))
 		sta_id = ctx->bcast_sta_id;
 	else
 		for (i = IWL_STA_ID; i < IWLAGN_STATION_COUNT; i++) {
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index 7001856..e48e573 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -513,7 +513,7 @@ static void lbtf_op_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changes & BSS_CHANGED_BSSID) {
-		bool activate = !is_zero_ether_addr(bss_conf->bssid);
+		bool activate = !eth_addr_zero(bss_conf->bssid);
 		lbtf_set_bssid(priv, activate, bss_conf->bssid);
 	}
 
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwifiex/join.c
index 7b0858a..7778521 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -1352,7 +1352,7 @@ static int mwifiex_deauthenticate_infra(struct mwifiex_private *priv, u8 *mac)
 	u8 mac_address[ETH_ALEN];
 	int ret;
 
-	if (!mac || is_zero_ether_addr(mac))
+	if (!mac || eth_addr_zero(mac))
 		memcpy(mac_address,
 		       priv->curr_bss_params.bss_descriptor.mac_address,
 		       ETH_ALEN);
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index 00b658d..e02a56b 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -838,7 +838,7 @@ mwifiex_config_scan(struct mwifiex_private *priv,
 		 *  or BSSID filter applied to the scan results in the firmware.
 		 */
 		if ((i && ssid_filter) ||
-		    !is_zero_ether_addr(scan_cfg_out->specific_bssid))
+		    !eth_addr_zero(scan_cfg_out->specific_bssid))
 			*filtered_scan = true;
 	} else {
 		scan_cfg_out->bss_mode = (u8) adapter->scan_mode;
diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/mwifiex/sta_cmd.c
index 5d87195..3f4073b 100644
--- a/drivers/net/wireless/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/mwifiex/sta_cmd.c
@@ -592,7 +592,7 @@ mwifiex_cmd_802_11_key_material(struct mwifiex_private *priv,
 			/* set 0 when re-key */
 			key_material->key_param_set.key[1] = 0;
 
-		if (!is_broadcast_ether_addr(enc_key->mac_addr)) {
+		if (!eth_addr_broadcast(enc_key->mac_addr)) {
 			/* WAPI pairwise key: unicast */
 			key_material->key_param_set.key_info |=
 				cpu_to_le16(KEY_UNICAST);
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index 09e6a26..685d78e 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -778,7 +778,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
 		"info: new BSSID %pM\n", ibss_coal_resp->bssid);
 
 	/* If rsp has NULL BSSID, Just return..... No Action */
-	if (is_zero_ether_addr(ibss_coal_resp->bssid)) {
+	if (eth_addr_zero(ibss_coal_resp->bssid)) {
 		dev_warn(priv->adapter->dev, "new BSSID is NULL\n");
 		return 0;
 	}
diff --git a/drivers/net/wireless/mwifiex/uap_txrx.c b/drivers/net/wireless/mwifiex/uap_txrx.c
index 0966ac2..d71f2d6 100644
--- a/drivers/net/wireless/mwifiex/uap_txrx.c
+++ b/drivers/net/wireless/mwifiex/uap_txrx.c
@@ -134,7 +134,7 @@ int mwifiex_handle_uap_rx_forward(struct mwifiex_private *priv,
 
 	memcpy(ra, rx_pkt_hdr->eth803_hdr.h_dest, ETH_ALEN);
 
-	if (is_multicast_ether_addr(ra)) {
+	if (eth_addr_multicast(ra)) {
 		skb_uap = skb_copy(skb, GFP_ATOMIC);
 		mwifiex_uap_queue_bridged_pkt(priv, skb_uap);
 	} else {
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 5099e53..499c702 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1886,7 +1886,7 @@ mwl8k_txq_xmit(struct ieee80211_hw *hw,
 		qos |= MWL8K_QOS_QLEN_UNSPEC | MWL8K_QOS_EOSP;
 	} else if (ieee80211_is_data(wh->frame_control)) {
 		txdatarate = 1;
-		if (is_multicast_ether_addr(wh->addr1))
+		if (eth_addr_multicast(wh->addr1))
 			txstatus |= MWL8K_TXD_STATUS_MULTICAST_TX;
 
 		qos &= ~MWL8K_QOS_ACK_POLICY_MASK;
diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 3b5508f..b5f3c6b 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -165,8 +165,8 @@ static int orinoco_ioctl_setwap(struct net_device *dev,
 		return -EBUSY;
 
 	/* Enable automatic roaming - no sanity checks are needed */
-	if (is_zero_ether_addr(ap_addr->sa_data) ||
-	    is_broadcast_ether_addr(ap_addr->sa_data)) {
+	if (eth_addr_zero(ap_addr->sa_data) ||
+	    eth_addr_broadcast(ap_addr->sa_data)) {
 		priv->bssid_fixed = 0;
 		memset(priv->desired_bssid, 0, ETH_ALEN);
 
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index 1ef1bfe..d3bb493 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -912,7 +912,7 @@ good_eeprom:
 	if ((synth & PDR_SYNTH_TX_DIV_MASK) == PDR_SYNTH_TX_DIV_SUPPORTED)
 		priv->tx_diversity_mask = 3;
 
-	if (!is_valid_ether_addr(dev->wiphy->perm_addr)) {
+	if (!eth_addr_valid(dev->wiphy->perm_addr)) {
 		u8 perm_addr[ETH_ALEN];
 
 		wiphy_warn(dev->wiphy,
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index bd1f0cb..32f9488 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1060,7 +1060,7 @@ static bool is_associated(struct usbnet *usbdev)
 
 	ret = get_bssid(usbdev, bssid);
 
-	return (ret == 0 && !is_zero_ether_addr(bssid));
+	return (ret == 0 && !eth_addr_zero(bssid));
 }
 
 static int disassociate(struct usbnet *usbdev, bool reset_ssid)
@@ -1425,8 +1425,8 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 		}
 	}
 
-	is_addr_ok = addr && !is_zero_ether_addr(addr) &&
-					!is_broadcast_ether_addr(addr);
+	is_addr_ok = addr && !eth_addr_zero(addr) &&
+					!eth_addr_broadcast(addr);
 	if ((flags & NDIS_80211_ADDKEY_PAIRWISE_KEY) && !is_addr_ok) {
 		netdev_dbg(usbdev->net, "%s(): pairwise but bssid invalid (%pM)\n",
 			   __func__, addr);
@@ -1551,7 +1551,7 @@ static int remove_key(struct usbnet *usbdev, u8 index, const u8 *bssid)
 		remove_key.index = cpu_to_le32(index);
 		if (bssid) {
 			/* pairwise key */
-			if (!is_broadcast_ether_addr(bssid))
+			if (!eth_addr_broadcast(bssid))
 				remove_key.index |=
 					NDIS_80211_ADDKEY_PAIRWISE_KEY;
 			memcpy(remove_key.bssid, bssid,
@@ -2232,8 +2232,8 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 		}
 	}
 
-	if (sme->bssid && !is_zero_ether_addr(sme->bssid) &&
-				!is_broadcast_ether_addr(sme->bssid)) {
+	if (sme->bssid && !eth_addr_zero(sme->bssid) &&
+				!eth_addr_broadcast(sme->bssid)) {
 		ret = set_bssid(usbdev, sme->bssid);
 		if (ret < 0) {
 			netdev_dbg(usbdev->net, "connect: set_bssid failed, %d\n",
@@ -2346,8 +2346,8 @@ static int rndis_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 		}
 	}
 
-	if (params->bssid && !is_zero_ether_addr(params->bssid) &&
-				!is_broadcast_ether_addr(params->bssid)) {
+	if (params->bssid && !eth_addr_zero(params->bssid) &&
+				!eth_addr_broadcast(params->bssid)) {
 		ret = set_bssid(usbdev, params->bssid);
 		if (ret < 0) {
 			netdev_dbg(usbdev->net, "join_ibss: set_bssid failed, %d\n",
@@ -2816,7 +2816,7 @@ static void rndis_wlan_do_link_up_work(struct usbnet *usbdev)
 	match_bss = false;
 	rndis_check_bssid_list(usbdev, bssid, &match_bss);
 
-	if (!is_zero_ether_addr(bssid) && !match_bss) {
+	if (!eth_addr_zero(bssid) && !match_bss) {
 		/* Couldn't get bss from device, we need to manually craft bss
 		 * for cfg80211.
 		 */
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index e3a2d90..f8883b2 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1454,7 +1454,7 @@ static int rt2400pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 * Start validation of the data that has been read.
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
-	if (!is_valid_ether_addr(mac)) {
+	if (!eth_addr_valid(mac)) {
 		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 479d756..0bd01cc 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1584,7 +1584,7 @@ static int rt2500pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 * Start validation of the data that has been read.
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
-	if (!is_valid_ether_addr(mac)) {
+	if (!eth_addr_valid(mac)) {
 		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index a12e84f..e069656 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1351,7 +1351,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 * Start validation of the data that has been read.
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
-	if (!is_valid_ether_addr(mac)) {
+	if (!eth_addr_valid(mac)) {
 		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 01dc889..7fb9a24 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -1165,7 +1165,7 @@ static inline int rt2800_find_wcid(struct rt2x00_dev *rt2x00dev)
 		offset = MAC_WCID_ENTRY(idx);
 		rt2800_register_multiread(rt2x00dev, offset, &wcid_entry,
 					  sizeof(wcid_entry));
-		if (is_broadcast_ether_addr(wcid_entry.mac))
+		if (eth_addr_broadcast(wcid_entry.mac))
 			return idx;
 	}
 
@@ -1351,7 +1351,7 @@ void rt2800_config_intf(struct rt2x00_dev *rt2x00dev, struct rt2x00_intf *intf,
 			update_bssid = true;
 		}
 
-		if (!is_zero_ether_addr((const u8 *)conf->mac)) {
+		if (!eth_addr_zero((const u8 *)conf->mac)) {
 			reg = le32_to_cpu(conf->mac[1]);
 			rt2x00_set_field32(&reg, MAC_ADDR_DW1_UNICAST_TO_ME_MASK, 0xff);
 			conf->mac[1] = cpu_to_le32(reg);
@@ -1362,7 +1362,7 @@ void rt2800_config_intf(struct rt2x00_dev *rt2x00dev, struct rt2x00_intf *intf,
 	}
 
 	if ((flags & CONFIG_UPDATE_BSSID) || update_bssid) {
-		if (!is_zero_ether_addr((const u8 *)conf->bssid)) {
+		if (!eth_addr_zero((const u8 *)conf->bssid)) {
 			reg = le32_to_cpu(conf->bssid[1]);
 			rt2x00_set_field32(&reg, MAC_BSSID_DW1_BSS_ID_MASK, 3);
 			rt2x00_set_field32(&reg, MAC_BSSID_DW1_BSS_BCN_NUM, 7);
@@ -4591,7 +4591,7 @@ static int rt2800_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 * Start validation of the data that has been read.
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
-	if (!is_valid_ether_addr(mac)) {
+	if (!eth_addr_valid(mac)) {
 		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index d6582a2..0a886b0 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2413,7 +2413,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 * Start validation of the data that has been read.
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
-	if (!is_valid_ether_addr(mac)) {
+	if (!eth_addr_valid(mac)) {
 		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index e5eb43b..e0812ca 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1769,7 +1769,7 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 * Start validation of the data that has been read.
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
-	if (!is_valid_ether_addr(mac)) {
+	if (!eth_addr_valid(mac)) {
 		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index 021d83e..d3d267c 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -795,7 +795,7 @@ static void rtl8180_bss_info_changed(struct ieee80211_hw *dev,
 			rtl818x_iowrite8(priv, &priv->map->BSSID[i],
 					 info->bssid[i]);
 
-		if (is_valid_ether_addr(info->bssid)) {
+		if (eth_addr_valid(info->bssid)) {
 			if (vif->type == NL80211_IFTYPE_ADHOC)
 				reg = RTL818X_MSR_ADHOC;
 			else
@@ -1077,7 +1077,7 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 	}
 
 	eeprom_93cx6_multiread(&eeprom, 0x7, (__le16 *)mac_addr, 3);
-	if (!is_valid_ether_addr(mac_addr)) {
+	if (!eth_addr_valid(mac_addr)) {
 		printk(KERN_WARNING "%s (rtl8180): Invalid hwaddr! Using"
 		       " randomly generated MAC addr\n", pci_name(pdev));
 		eth_random_addr(mac_addr);
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index 7811b63..c424c1c 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -1260,7 +1260,7 @@ static void rtl8187_bss_info_changed(struct ieee80211_hw *dev,
 		else
 			reg = 0;
 
-		if (is_valid_ether_addr(info->bssid)) {
+		if (eth_addr_valid(info->bssid)) {
 			if (vif->type == NL80211_IFTYPE_ADHOC)
 				reg |= RTL818X_MSR_ADHOC;
 			else
@@ -1485,7 +1485,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 
 	eeprom_93cx6_multiread(&eeprom, RTL8187_EEPROM_MAC_ADDR,
 			       (__le16 __force *)mac_addr, 3);
-	if (!is_valid_ether_addr(mac_addr)) {
+	if (!eth_addr_valid(mac_addr)) {
 		printk(KERN_WARNING "rtl8187: Invalid hwaddr! Using randomly "
 		       "generated MAC address\n");
 		eth_random_addr(mac_addr);
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 59381fe..1d82a3b 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -339,7 +339,7 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 	hw->sta_data_size = sizeof(struct rtl_sta_info);
 
 	/* <6> mac address */
-	if (is_valid_ether_addr(rtlefuse->dev_addr)) {
+	if (eth_addr_valid(rtlefuse->dev_addr)) {
 		SET_IEEE80211_PERM_ADDR(hw, rtlefuse->dev_addr);
 	} else {
 		u8 rtlmac1[] = { 0x00, 0xe0, 0x4c, 0x81, 0x92, 0x00 };
@@ -881,9 +881,9 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 			}
 		}
 
-		if (is_multicast_ether_addr(ieee80211_get_DA(hdr)))
+		if (eth_addr_multicast(ieee80211_get_DA(hdr)))
 			tcb_desc->multicast = 1;
-		else if (is_broadcast_ether_addr(ieee80211_get_DA(hdr)))
+		else if (eth_addr_broadcast(ieee80211_get_DA(hdr)))
 			tcb_desc->broadcast = 1;
 
 		_rtl_txrate_selectmode(hw, sta, tcb_desc);
diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 5b4b4d4..c539ac9 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -328,7 +328,7 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG, "sta_addr is NULL\n");
 	}
 
-	if (is_zero_ether_addr(sta_addr)) {
+	if (eth_addr_zero(sta_addr)) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
 			 "sta_addr is %pM\n", sta_addr);
 		return;
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index abc306b..4227c7f 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -619,9 +619,9 @@ static void _rtl_receive_one(struct ieee80211_hw *hw, struct sk_buff *skb,
 
 	memcpy(IEEE80211_SKB_RXCB(skb), &rx_status, sizeof(rx_status));
 
-	if (is_broadcast_ether_addr(hdr->addr1)) {
+	if (eth_addr_broadcast(hdr->addr1)) {
 		;/*TODO*/
-	} else if (is_multicast_ether_addr(hdr->addr1)) {
+	} else if (eth_addr_multicast(hdr->addr1)) {
 		;/*TODO*/
 	} else {
 		unicast = true;
@@ -1370,9 +1370,9 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 
 	rtl_action_proc(hw, skb, true);
 
-	if (is_multicast_ether_addr(pda_addr))
+	if (eth_addr_multicast(pda_addr))
 		rtlpriv->stats.txbytesmulticast += skb->len;
-	else if (is_broadcast_ether_addr(pda_addr))
+	else if (eth_addr_broadcast(pda_addr))
 		rtlpriv->stats.txbytesbroadcast += skb->len;
 	else
 		rtlpriv->stats.txbytesunicast += skb->len;
diff --git a/drivers/net/wireless/rtlwifi/rc.c b/drivers/net/wireless/rtlwifi/rc.c
index d5cbf01..b43dd4f 100644
--- a/drivers/net/wireless/rtlwifi/rc.c
+++ b/drivers/net/wireless/rtlwifi/rc.c
@@ -193,8 +193,8 @@ static void rtl_tx_status(void *ppriv,
 	if (rtl_is_special_data(mac->hw, skb, true))
 		return;
 
-	if (is_multicast_ether_addr(ieee80211_get_DA(hdr))
-	    || is_broadcast_ether_addr(ieee80211_get_DA(hdr)))
+	if (eth_addr_multicast(ieee80211_get_DA(hdr))
+	    || eth_addr_broadcast(ieee80211_get_DA(hdr)))
 		return;
 
 	if (sta) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 390d6d4..a080ce7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -759,8 +759,8 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 
 	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
 
-	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
-	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
+	if (eth_addr_multicast(ieee80211_get_DA(hdr)) ||
+	    eth_addr_broadcast(ieee80211_get_DA(hdr))) {
 		SET_TX_DESC_BMC(pdesc, 1);
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 6e66f04..cb3a4e8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -616,8 +616,8 @@ void rtl92cu_tx_fill_desc(struct ieee80211_hw *hw,
 	}
 	if (ieee80211_has_morefrags(fc))
 		SET_TX_DESC_MORE_FRAG(txdesc, 1);
-	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
-	    is_broadcast_ether_addr(ieee80211_get_DA(hdr)))
+	if (eth_addr_multicast(ieee80211_get_DA(hdr)) ||
+	    eth_addr_broadcast(ieee80211_get_DA(hdr)))
 		SET_TX_DESC_BMC(txdesc, 1);
 	_rtl_fill_usb_tx_desc(txdesc);
 	_rtl_tx_desc_checksum(txdesc);
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 030beb4..b843b5b 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -452,9 +452,9 @@ static void _rtl_usb_rx_process_agg(struct ieee80211_hw *hw,
 	if (!stats.crc) {
 		memcpy(IEEE80211_SKB_RXCB(skb), &rx_status, sizeof(rx_status));
 
-		if (is_broadcast_ether_addr(hdr->addr1)) {
+		if (eth_addr_broadcast(hdr->addr1)) {
 			/*TODO*/;
-		} else if (is_multicast_ether_addr(hdr->addr1)) {
+		} else if (eth_addr_multicast(hdr->addr1)) {
 			/*TODO*/
 		} else {
 			unicast = true;
@@ -495,9 +495,9 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 	if (!stats.crc) {
 		memcpy(IEEE80211_SKB_RXCB(skb), &rx_status, sizeof(rx_status));
 
-		if (is_broadcast_ether_addr(hdr->addr1)) {
+		if (eth_addr_broadcast(hdr->addr1)) {
 			/*TODO*/;
-		} else if (is_multicast_ether_addr(hdr->addr1)) {
+		} else if (eth_addr_multicast(hdr->addr1)) {
 			/*TODO*/
 		} else {
 			unicast = true;
@@ -879,9 +879,9 @@ static void _rtl_usb_tx_preprocess(struct ieee80211_hw *hw,
 	}
 
 	rtl_action_proc(hw, skb, true);
-	if (is_multicast_ether_addr(pda_addr))
+	if (eth_addr_multicast(pda_addr))
 		rtlpriv->stats.txbytesmulticast += skb->len;
-	else if (is_broadcast_ether_addr(pda_addr))
+	else if (eth_addr_broadcast(pda_addr))
 		rtlpriv->stats.txbytesbroadcast += skb->len;
 	else
 		rtlpriv->stats.txbytesunicast += skb->len;
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 441cbcc..822d1f2 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -338,7 +338,7 @@ static int wl1251_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 	 * Join command applies filters, and if we are not associated,
 	 * BSSID filter must be disabled for association to work.
 	 */
-	if (is_zero_ether_addr(wl->bssid))
+	if (eth_addr_zero(wl->bssid))
 		wl->rx_config &= ~CFG_BSSID_FILTER_EN;
 
 	ret = wl1251_cmd_join(wl, bss_type, channel, beacon_interval,
@@ -703,7 +703,7 @@ static void wl1251_op_configure_filter(struct ieee80211_hw *hw,
 	}
 	if (*total & FIF_CONTROL)
 		wl->rx_filter |= CFG_RX_CTL_EN;
-	if (*total & FIF_OTHER_BSS || is_zero_ether_addr(wl->bssid))
+	if (*total & FIF_OTHER_BSS || eth_addr_zero(wl->bssid))
 		wl->rx_config &= ~CFG_BSSID_FILTER_EN;
 	if (*total & FIF_PROBE_REQ)
 		wl->rx_filter |= CFG_RX_PREQ_EN;
@@ -734,7 +734,7 @@ static int wl1251_set_key_type(struct wl1251 *wl,
 	switch (mac80211_key->cipher) {
 	case WLAN_CIPHER_SUITE_WEP40:
 	case WLAN_CIPHER_SUITE_WEP104:
-		if (is_broadcast_ether_addr(addr))
+		if (eth_addr_broadcast(addr))
 			key->key_type = KEY_WEP_DEFAULT;
 		else
 			key->key_type = KEY_WEP_ADDR;
@@ -742,7 +742,7 @@ static int wl1251_set_key_type(struct wl1251 *wl,
 		mac80211_key->hw_key_idx = mac80211_key->keyidx;
 		break;
 	case WLAN_CIPHER_SUITE_TKIP:
-		if (is_broadcast_ether_addr(addr))
+		if (eth_addr_broadcast(addr))
 			key->key_type = KEY_TKIP_MIC_GROUP;
 		else
 			key->key_type = KEY_TKIP_MIC_PAIRWISE;
@@ -750,7 +750,7 @@ static int wl1251_set_key_type(struct wl1251 *wl,
 		mac80211_key->hw_key_idx = mac80211_key->keyidx;
 		break;
 	case WLAN_CIPHER_SUITE_CCMP:
-		if (is_broadcast_ether_addr(addr))
+		if (eth_addr_broadcast(addr))
 			key->key_type = KEY_AES_GROUP;
 		else
 			key->key_type = KEY_AES_PAIRWISE;
@@ -793,7 +793,7 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		     key->cipher, key->keyidx, key->keylen, key->flags);
 	wl1251_dump(DEBUG_CRYPT, "KEY: ", key->key, key->keylen);
 
-	if (is_zero_ether_addr(addr)) {
+	if (eth_addr_zero(addr)) {
 		/* We dont support TX only encryption */
 		ret = -EOPNOTSUPP;
 		goto out;
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index eaef3f4..3e40415 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -1268,7 +1268,7 @@ int wl1271_cmd_set_sta_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	if (key_type == KEY_WEP)
 		cmd->lid_key_type = WEP_DEFAULT_LID_TYPE;
-	else if (is_broadcast_ether_addr(addr))
+	else if (eth_addr_broadcast(addr))
 		cmd->lid_key_type = BROADCAST_LID_TYPE;
 	else
 		cmd->lid_key_type = UNICAST_LID_TYPE;
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 25530c8..d421844 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -3020,7 +3020,7 @@ static int wl1271_set_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 		addr = sta ? sta->addr : bcast_addr;
 
-		if (is_zero_ether_addr(addr)) {
+		if (eth_addr_zero(addr)) {
 			/* We dont support TX only encryption */
 			return -EOPNOTSUPP;
 		}
@@ -3029,7 +3029,7 @@ static int wl1271_set_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		   will be cleared automatically on next CMD_JOIN. Ignore the
 		   request silently, as we dont want the mac80211 to emit
 		   an error message. */
-		if (action == KEY_REMOVE && !is_broadcast_ether_addr(addr))
+		if (action == KEY_REMOVE && !eth_addr_broadcast(addr))
 			return 0;
 
 		/* don't remove key if hlid was already deleted */
@@ -3871,7 +3871,7 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 	}
 
 	if (changed & BSS_CHANGED_BSSID)
-		if (!is_zero_ether_addr(bss_conf->bssid)) {
+		if (!eth_addr_zero(bss_conf->bssid)) {
 			ret = wl12xx_cmd_build_null_data(wl, wlvif);
 			if (ret < 0)
 				goto out;
diff --git a/drivers/net/wireless/ti/wlcore/tx.c b/drivers/net/wireless/ti/wlcore/tx.c
index a90d3cd..03e966e 100644
--- a/drivers/net/wireless/ti/wlcore/tx.c
+++ b/drivers/net/wireless/ti/wlcore/tx.c
@@ -145,7 +145,7 @@ static u8 wl12xx_tx_get_hlid_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 			return wl->system_hlid;
 
 		hdr = (struct ieee80211_hdr *)skb->data;
-		if (is_multicast_ether_addr(ieee80211_get_DA(hdr)))
+		if (eth_addr_multicast(ieee80211_get_DA(hdr)))
 			return wlvif->ap.bcast_hlid;
 		else
 			return wlvif->ap.global_hlid;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 730186d..804a15a 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1525,7 +1525,7 @@ static int wl3501_set_wap(struct net_device *dev, struct iw_request_info *info,
 	/* FIXME: we support other ARPHRDs...*/
 	if (wrqu->ap_addr.sa_family != ARPHRD_ETHER)
 		goto out;
-	if (is_broadcast_ether_addr(wrqu->ap_addr.sa_data)) {
+	if (eth_addr_broadcast(wrqu->ap_addr.sa_data)) {
 		/* FIXME: rescan? */
 	} else
 		memcpy(this->bssid, wrqu->ap_addr.sa_data, ETH_ALEN);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 114364b..ce32bb5 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1335,7 +1335,7 @@ static void zd_op_bss_info_changed(struct ieee80211_hw *hw,
 					       mac->type);
 		}
 	} else
-		associated = is_valid_ether_addr(bss_conf->bssid);
+		associated = eth_addr_valid(bss_conf->bssid);
 
 	spin_lock_irq(&mac->lock);
 	mac->associated = associated;
-- 
1.7.8.111.gad25c.dirty
