From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-12-05
Date: Thu, 5 Dec 2013 11:51:42 -0500
Message-ID: <20131205165141.GB2307@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intende for the 3.13 stream!

For the mac80211 bits, Johannes says:

"For now I have various fixes all over, mostly for issues introduced in
relatively recent patches. There's no real pattern to it. Some of the
issues like go back longer, but still seemed 3.13 material."

And...

"These are just two patches disabling the broken CSA code. Once this
goes into your tree I'll merge it into mac80211-next and revert there
(since we fixed the bugs there)."

For the iwlwifi bits, Emmanuel says:

"I have here a few fixes for BT Coex. One of them is a NULL pointer
dereference. Another one avoids to enable a feature that can make the
firmware unhappy since the firmware isn't ready for it yet. WE also
avoid a WARNING that can be triggered upon association in not-so-bad
cases even if the association succeeded. We add support for new NICs
(not yet on the market) and bump the API so that 3.13 will be able to
work with the new firmware that will be out soon hopefully.
I also have a boundary check from Johannes."

In addition to those...

- Arend van Spriel fixes a brcmfmac problem that could use an
uninitialized variable in an error path.

- Borislav Petkov fixes a Kconfig-based build breakage problem for
brcmsmac.

- Michal Nazarewicz fixes a couple of NULL pointer dereference problems
in ath9k and wcn36xx.

- Sujith Manoharan fixes a couple of ath9k problems related to
incorrect interpretation of EEPROM configuration data.

- Ujjal Roy fixes a memory leak in mwifiex.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 988bf4f01e6a1eefdedd76e961044f01fe6a304c:

  Merge branch 'cxgb4' (2013-12-03 16:55:49 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to aa489f0f268595bd33d9649030bd1a43c28927a0:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-12-05 09:29:56 -0500)

----------------------------------------------------------------

Alexander Bondar (1):
      iwlwifi: pcie: stop sending commands to dead firmware

Arend van Spriel (1):
      brcmfmac: fix uninitialized warning

Bob Copeland (1):
      Revert "mac80211: allow disable power save in mesh"

Borislav Petkov (1):
      brcmsmac: Fix build dep on LEDS_CLASS

Chun-Yeow Yeoh (1):
      mac80211: fix the mesh channel switch support

Eliad Peller (1):
      mac80211: fix connection polling

Emmanuel Grumbach (5):
      iwlwifi: pcie: fix interrupt coalescing for 7260 / 3160
      iwlwifi: mvm: BT Coex - don't enable MULTI_PRIO_LUT
      iwlwifi: mvm: BT Coex fix another NULL pointer dereference
      iwlwifi: mvm: don't WARN about unsuccessful time event
      iwlwifi: bump required firmware API version for 3160/7260

Felix Fietkau (2):
      mac80211: fix crash when using AP VLAN interfaces
      cfg80211: ignore supported rates for nonexistant bands on scan

Janusz Dziedzic (1):
      mac80211: DFS setup chandef for radar_event correctly

Javier Lopez (1):
      mac80211: fix for mesh beacon update on powersave

Johannes Berg (7):
      mac80211: fix scheduled scan rtnl deadlock
      nl80211: check nla_put_* return values
      nl80211: fix error path in nl80211_get_key()
      nl80211: check nla_nest_start() return value
      cfg80211: disable 5/10 MHz support for all drivers
      mac80211: don't attempt to reorder multicast frames
      iwlwifi: mvm: check sta_id/drain values in debugfs

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fix=
es
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jouni Malinen (2):
      mac80211_hwsim: Fix radiotap header for ACK frames
      mac80211_hwsim: Fix bcn_en_iter to use atomic iteration

Karl Beldan (3):
      mac80211: minstrel_ht: fix rates selection
      mac80211: use capped prob when computing throughputs
      mac80211: set hw initial idle state

Luciano Coelho (2):
      iwlwifi: mvm: set seqno also when no keys are set
      iwlwifi: mvm: use a cast to calculate the last seqno from the next one

Michal Nazarewicz (2):
      net: wireless: ath9k: avoid possible NULL pointer dereference
      net: wireless: wcn36xx: fix potential NULL pointer dereference

Oren Givon (1):
      iwlwifi: add new HW - 7265 series

Simon Wunderlich (3):
      cfg80211: fix ibss wext chandef creation
      cfg80211: disable CSA for all drivers
      mac80211: check csa wiphy flag in ibss before switching

Sujith Manoharan (2):
      ath9k: Fix QuickDrop usage
      ath9k: Fix XLNA bias strength

Ujjal Roy (1):
      mwifiex: fix memory leak issue for ibss join

 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     | 22 ++++----
 drivers/net/wireless/ath/ath9k/hw.c                |  7 ++-
 drivers/net/wireless/ath/wcn36xx/smd.c             | 19 ++++---
 drivers/net/wireless/brcm80211/Kconfig             |  2 +
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  2 +
 drivers/net/wireless/iwlwifi/iwl-7000.c            | 29 ++++++++++-
 drivers/net/wireless/iwlwifi/iwl-config.h          |  5 ++
 drivers/net/wireless/iwlwifi/iwl-csr.h             |  5 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |  6 ++-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  5 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  4 ++
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |  7 ++-
 drivers/net/wireless/iwlwifi/pcie/drv.c            | 21 ++++++++
 drivers/net/wireless/iwlwifi/pcie/internal.h       |  8 +++
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  7 ++-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  3 --
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  6 +--
 drivers/net/wireless/mac80211_hwsim.c              | 16 ++++--
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  4 +-
 net/mac80211/cfg.c                                 | 15 ++++--
 net/mac80211/ibss.c                                |  4 ++
 net/mac80211/ieee80211_i.h                         |  1 +
 net/mac80211/iface.c                               |  1 -
 net/mac80211/main.c                                |  3 ++
 net/mac80211/mesh.c                                | 20 +++++---
 net/mac80211/mlme.c                                |  2 +
 net/mac80211/rc80211_minstrel_ht.c                 |  7 +--
 net/mac80211/rx.c                                  |  3 +-
 net/mac80211/scan.c                                |  2 +-
 net/mac80211/spectmgmt.c                           |  2 +
 net/mac80211/util.c                                | 11 +---
 net/wireless/core.c                                |  9 ++++
 net/wireless/ibss.c                                | 18 +++----
 net/wireless/nl80211.c                             | 60 +++++++++++++-----=
----
 34 files changed, 233 insertions(+), 103 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/w=
ireless/ath/ath9k/ar9003_eeprom.c
index 1ec52356b5a1..130657db5c43 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -3984,18 +3984,20 @@ static void ar9003_hw_quick_drop_apply(struct ath_h=
w *ah, u16 freq)
 	int quick_drop;
 	s32 t[3], f[3] =3D {5180, 5500, 5785};
=20
-	if (!(pBase->miscConfiguration & BIT(1)))
+	if (!(pBase->miscConfiguration & BIT(4)))
 		return;
=20
-	if (freq < 4000)
-		quick_drop =3D eep->modalHeader2G.quick_drop;
-	else {
-		t[0] =3D eep->base_ext1.quick_drop_low;
-		t[1] =3D eep->modalHeader5G.quick_drop;
-		t[2] =3D eep->base_ext1.quick_drop_high;
-		quick_drop =3D ar9003_hw_power_interpolate(freq, f, t, 3);
+	if (AR_SREV_9300(ah) || AR_SREV_9580(ah) || AR_SREV_9340(ah)) {
+		if (freq < 4000) {
+			quick_drop =3D eep->modalHeader2G.quick_drop;
+		} else {
+			t[0] =3D eep->base_ext1.quick_drop_low;
+			t[1] =3D eep->modalHeader5G.quick_drop;
+			t[2] =3D eep->base_ext1.quick_drop_high;
+			quick_drop =3D ar9003_hw_power_interpolate(freq, f, t, 3);
+		}
+		REG_RMW_FIELD(ah, AR_PHY_AGC, AR_PHY_AGC_QUICK_DROP, quick_drop);
 	}
-	REG_RMW_FIELD(ah, AR_PHY_AGC, AR_PHY_AGC_QUICK_DROP, quick_drop);
 }
=20
 static void ar9003_hw_txend_to_xpa_off_apply(struct ath_hw *ah, bool is2gh=
z)
@@ -4035,7 +4037,7 @@ static void ar9003_hw_xlna_bias_strength_apply(struct=
 ath_hw *ah, bool is2ghz)
 	struct ar9300_eeprom *eep =3D &ah->eeprom.ar9300_eep;
 	u8 bias;
=20
-	if (!(eep->baseEepHeader.featureEnable & 0x40))
+	if (!(eep->baseEepHeader.miscConfiguration & 0x40))
 		return;
=20
 	if (!AR_SREV_9300(ah))
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 54b04155e43b..8918035da3a3 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -146,10 +146,9 @@ static void ath9k_hw_set_clockrate(struct ath_hw *ah)
 	else
 		clockrate =3D ATH9K_CLOCK_RATE_5GHZ_OFDM;
=20
-	if (IS_CHAN_HT40(chan))
-		clockrate *=3D 2;
-
-	if (ah->curchan) {
+	if (chan) {
+		if (IS_CHAN_HT40(chan))
+			clockrate *=3D 2;
 		if (IS_CHAN_HALF_RATE(chan))
 			clockrate /=3D 2;
 		if (IS_CHAN_QUARTER_RATE(chan))
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/=
ath/wcn36xx/smd.c
index de9eb2cfbf4b..366339421d4f 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2041,13 +2041,20 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx =
*wcn, void *buf, size_t len)
 	case WCN36XX_HAL_DELETE_STA_CONTEXT_IND:
 		mutex_lock(&wcn->hal_ind_mutex);
 		msg_ind =3D kmalloc(sizeof(*msg_ind), GFP_KERNEL);
-		msg_ind->msg_len =3D len;
-		msg_ind->msg =3D kmalloc(len, GFP_KERNEL);
-		memcpy(msg_ind->msg, buf, len);
-		list_add_tail(&msg_ind->list, &wcn->hal_ind_queue);
-		queue_work(wcn->hal_ind_wq, &wcn->hal_ind_work);
-		wcn36xx_dbg(WCN36XX_DBG_HAL, "indication arrived\n");
+		if (msg_ind) {
+			msg_ind->msg_len =3D len;
+			msg_ind->msg =3D kmalloc(len, GFP_KERNEL);
+			memcpy(msg_ind->msg, buf, len);
+			list_add_tail(&msg_ind->list, &wcn->hal_ind_queue);
+			queue_work(wcn->hal_ind_wq, &wcn->hal_ind_work);
+			wcn36xx_dbg(WCN36XX_DBG_HAL, "indication arrived\n");
+		}
 		mutex_unlock(&wcn->hal_ind_mutex);
+		if (msg_ind)
+			break;
+		/* FIXME: Do something smarter then just printing an error. */
+		wcn36xx_err("Run out of memory while handling SMD_EVENT (%d)\n",
+			    msg_header->msg_type);
 		break;
 	default:
 		wcn36xx_err("SMD_EVENT (%d) not supported\n",
diff --git a/drivers/net/wireless/brcm80211/Kconfig b/drivers/net/wireless/=
brcm80211/Kconfig
index b00a7e92225f..54e36fcb3954 100644
--- a/drivers/net/wireless/brcm80211/Kconfig
+++ b/drivers/net/wireless/brcm80211/Kconfig
@@ -5,6 +5,8 @@ config BRCMSMAC
 	tristate "Broadcom IEEE802.11n PCIe SoftMAC WLAN driver"
 	depends on MAC80211
 	depends on BCMA
+	select NEW_LEDS if BCMA_DRIVER_GPIO
+	select LEDS_CLASS if BCMA_DRIVER_GPIO
 	select BRCMUTIL
 	select FW_LOADER
 	select CRC_CCITT
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c b/drive=
rs/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
index 905704e335d7..abc9ceca70f3 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
@@ -109,6 +109,8 @@ static inline int brcmf_sdioh_f0_write_byte(struct brcm=
f_sdio_dev *sdiodev,
 					brcmf_err("Disable F2 failed:%d\n",
 						  err_ret);
 			}
+		} else {
+			err_ret =3D -ENOENT;
 		}
 	} else if ((regaddr =3D=3D SDIO_CCCR_ABORT) ||
 		   (regaddr =3D=3D SDIO_CCCR_IENx)) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-7000.c b/drivers/net/wireless=
/iwlwifi/iwl-7000.c
index 85879dbaa402..3c34a72a5d64 100644
--- a/drivers/net/wireless/iwlwifi/iwl-7000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-7000.c
@@ -67,8 +67,8 @@
 #include "iwl-agn-hw.h"
=20
 /* Highest firmware API version supported */
-#define IWL7260_UCODE_API_MAX	7
-#define IWL3160_UCODE_API_MAX	7
+#define IWL7260_UCODE_API_MAX	8
+#define IWL3160_UCODE_API_MAX	8
=20
 /* Oldest version we won't warn about */
 #define IWL7260_UCODE_API_OK	7
@@ -130,6 +130,7 @@ const struct iwl_cfg iwl7260_2ac_cfg =3D {
 	.ht_params =3D &iwl7000_ht_params,
 	.nvm_ver =3D IWL7260_NVM_VERSION,
 	.nvm_calib_ver =3D IWL7260_TX_POWER_VERSION,
+	.host_interrupt_operation_mode =3D true,
 };
=20
 const struct iwl_cfg iwl7260_2ac_cfg_high_temp =3D {
@@ -140,6 +141,7 @@ const struct iwl_cfg iwl7260_2ac_cfg_high_temp =3D {
 	.nvm_ver =3D IWL7260_NVM_VERSION,
 	.nvm_calib_ver =3D IWL7260_TX_POWER_VERSION,
 	.high_temp =3D true,
+	.host_interrupt_operation_mode =3D true,
 };
=20
 const struct iwl_cfg iwl7260_2n_cfg =3D {
@@ -149,6 +151,7 @@ const struct iwl_cfg iwl7260_2n_cfg =3D {
 	.ht_params =3D &iwl7000_ht_params,
 	.nvm_ver =3D IWL7260_NVM_VERSION,
 	.nvm_calib_ver =3D IWL7260_TX_POWER_VERSION,
+	.host_interrupt_operation_mode =3D true,
 };
=20
 const struct iwl_cfg iwl7260_n_cfg =3D {
@@ -158,6 +161,7 @@ const struct iwl_cfg iwl7260_n_cfg =3D {
 	.ht_params =3D &iwl7000_ht_params,
 	.nvm_ver =3D IWL7260_NVM_VERSION,
 	.nvm_calib_ver =3D IWL7260_TX_POWER_VERSION,
+	.host_interrupt_operation_mode =3D true,
 };
=20
 const struct iwl_cfg iwl3160_2ac_cfg =3D {
@@ -167,6 +171,7 @@ const struct iwl_cfg iwl3160_2ac_cfg =3D {
 	.ht_params =3D &iwl7000_ht_params,
 	.nvm_ver =3D IWL3160_NVM_VERSION,
 	.nvm_calib_ver =3D IWL3160_TX_POWER_VERSION,
+	.host_interrupt_operation_mode =3D true,
 };
=20
 const struct iwl_cfg iwl3160_2n_cfg =3D {
@@ -176,6 +181,7 @@ const struct iwl_cfg iwl3160_2n_cfg =3D {
 	.ht_params =3D &iwl7000_ht_params,
 	.nvm_ver =3D IWL3160_NVM_VERSION,
 	.nvm_calib_ver =3D IWL3160_TX_POWER_VERSION,
+	.host_interrupt_operation_mode =3D true,
 };
=20
 const struct iwl_cfg iwl3160_n_cfg =3D {
@@ -185,6 +191,7 @@ const struct iwl_cfg iwl3160_n_cfg =3D {
 	.ht_params =3D &iwl7000_ht_params,
 	.nvm_ver =3D IWL3160_NVM_VERSION,
 	.nvm_calib_ver =3D IWL3160_TX_POWER_VERSION,
+	.host_interrupt_operation_mode =3D true,
 };
=20
 const struct iwl_cfg iwl7265_2ac_cfg =3D {
@@ -196,5 +203,23 @@ const struct iwl_cfg iwl7265_2ac_cfg =3D {
 	.nvm_calib_ver =3D IWL7265_TX_POWER_VERSION,
 };
=20
+const struct iwl_cfg iwl7265_2n_cfg =3D {
+	.name =3D "Intel(R) Dual Band Wireless N 7265",
+	.fw_name_pre =3D IWL7265_FW_PRE,
+	IWL_DEVICE_7000,
+	.ht_params =3D &iwl7000_ht_params,
+	.nvm_ver =3D IWL7265_NVM_VERSION,
+	.nvm_calib_ver =3D IWL7265_TX_POWER_VERSION,
+};
+
+const struct iwl_cfg iwl7265_n_cfg =3D {
+	.name =3D "Intel(R) Wireless N 7265",
+	.fw_name_pre =3D IWL7265_FW_PRE,
+	IWL_DEVICE_7000,
+	.ht_params =3D &iwl7000_ht_params,
+	.nvm_ver =3D IWL7265_NVM_VERSION,
+	.nvm_calib_ver =3D IWL7265_TX_POWER_VERSION,
+};
+
 MODULE_FIRMWARE(IWL7260_MODULE_FIRMWARE(IWL7260_UCODE_API_OK));
 MODULE_FIRMWARE(IWL3160_MODULE_FIRMWARE(IWL3160_UCODE_API_OK));
diff --git a/drivers/net/wireless/iwlwifi/iwl-config.h b/drivers/net/wirele=
ss/iwlwifi/iwl-config.h
index 18f232e8e812..03fd9aa8bfda 100644
--- a/drivers/net/wireless/iwlwifi/iwl-config.h
+++ b/drivers/net/wireless/iwlwifi/iwl-config.h
@@ -207,6 +207,8 @@ struct iwl_eeprom_params {
  * @rx_with_siso_diversity: 1x1 device with rx antenna diversity
  * @internal_wimax_coex: internal wifi/wimax combo device
  * @high_temp: Is this NIC is designated to be in high temperature.
+ * @host_interrupt_operation_mode: device needs host interrupt operation
+ *	mode set
  *
  * We enable the driver to be backward compatible wrt. hardware features.
  * API differences in uCode shouldn't be handled here but through TLVs
@@ -235,6 +237,7 @@ struct iwl_cfg {
 	enum iwl_led_mode led_mode;
 	const bool rx_with_siso_diversity;
 	const bool internal_wimax_coex;
+	const bool host_interrupt_operation_mode;
 	bool high_temp;
 };
=20
@@ -294,6 +297,8 @@ extern const struct iwl_cfg iwl3160_2ac_cfg;
 extern const struct iwl_cfg iwl3160_2n_cfg;
 extern const struct iwl_cfg iwl3160_n_cfg;
 extern const struct iwl_cfg iwl7265_2ac_cfg;
+extern const struct iwl_cfg iwl7265_2n_cfg;
+extern const struct iwl_cfg iwl7265_n_cfg;
 #endif /* CONFIG_IWLMVM */
=20
 #endif /* __IWL_CONFIG_H__ */
diff --git a/drivers/net/wireless/iwlwifi/iwl-csr.h b/drivers/net/wireless/=
iwlwifi/iwl-csr.h
index 54a4fdc631b7..da4eca8b3007 100644
--- a/drivers/net/wireless/iwlwifi/iwl-csr.h
+++ b/drivers/net/wireless/iwlwifi/iwl-csr.h
@@ -495,14 +495,11 @@ enum secure_load_status_reg {
  * the CSR_INT_COALESCING is an 8 bit register in 32-usec unit
  *
  * default interrupt coalescing timer is 64 x 32 =3D 2048 usecs
- * default interrupt coalescing calibration timer is 16 x 32 =3D 512 usecs
  */
 #define IWL_HOST_INT_TIMEOUT_MAX	(0xFF)
 #define IWL_HOST_INT_TIMEOUT_DEF	(0x40)
 #define IWL_HOST_INT_TIMEOUT_MIN	(0x0)
-#define IWL_HOST_INT_CALIB_TIMEOUT_MAX	(0xFF)
-#define IWL_HOST_INT_CALIB_TIMEOUT_DEF	(0x10)
-#define IWL_HOST_INT_CALIB_TIMEOUT_MIN	(0x0)
+#define IWL_HOST_INT_OPER_MODE		BIT(31)
=20
 /*************************************************************************=
****
  *                        7000/3000 series SHR DTS addresses              =
   *
diff --git a/drivers/net/wireless/iwlwifi/mvm/bt-coex.c b/drivers/net/wirel=
ess/iwlwifi/mvm/bt-coex.c
index 5d066cbc5ac7..75b72a956552 100644
--- a/drivers/net/wireless/iwlwifi/mvm/bt-coex.c
+++ b/drivers/net/wireless/iwlwifi/mvm/bt-coex.c
@@ -391,7 +391,6 @@ int iwl_send_bt_init_conf(struct iwl_mvm *mvm)
 					    BT_VALID_LUT |
 					    BT_VALID_WIFI_RX_SW_PRIO_BOOST |
 					    BT_VALID_WIFI_TX_SW_PRIO_BOOST |
-					    BT_VALID_MULTI_PRIO_LUT |
 					    BT_VALID_CORUN_LUT_20 |
 					    BT_VALID_CORUN_LUT_40 |
 					    BT_VALID_ANT_ISOLATION |
@@ -842,6 +841,11 @@ static void iwl_mvm_bt_rssi_iterator(void *_data, u8 *=
mac,
=20
 	sta =3D rcu_dereference_protected(mvm->fw_id_to_mac_id[mvmvif->ap_sta_id],
 					lockdep_is_held(&mvm->mutex));
+
+	/* This can happen if the station has been removed right now */
+	if (IS_ERR_OR_NULL(sta))
+		return;
+
 	mvmsta =3D (void *)sta->drv_priv;
=20
 	data->num_bss_ifaces++;
diff --git a/drivers/net/wireless/iwlwifi/mvm/d3.c b/drivers/net/wireless/i=
wlwifi/mvm/d3.c
index 6f45966817bb..b9b81e881dd0 100644
--- a/drivers/net/wireless/iwlwifi/mvm/d3.c
+++ b/drivers/net/wireless/iwlwifi/mvm/d3.c
@@ -895,7 +895,7 @@ static int iwl_mvm_get_last_nonqos_seq(struct iwl_mvm *=
mvm,
 		/* new API returns next, not last-used seqno */
 		if (mvm->fw->ucode_capa.flags &
 				IWL_UCODE_TLV_FLAGS_D3_CONTINUITY_API)
-			err -=3D 0x10;
+			err =3D (u16) (err - 0x10);
 	}
=20
 	iwl_free_resp(&cmd);
@@ -1549,7 +1549,7 @@ static bool iwl_mvm_setup_connection_keep(struct iwl_=
mvm *mvm,
 	if (gtkdata.unhandled_cipher)
 		return false;
 	if (!gtkdata.num_keys)
-		return true;
+		goto out;
 	if (!gtkdata.last_gtk)
 		return false;
=20
@@ -1600,6 +1600,7 @@ static bool iwl_mvm_setup_connection_keep(struct iwl_=
mvm *mvm,
 					   (void *)&replay_ctr, GFP_KERNEL);
 	}
=20
+out:
 	mvmvif->seqno_valid =3D true;
 	/* +0x10 because the set API expects next-to-use, not last-used */
 	mvmvif->seqno =3D le16_to_cpu(status->non_qos_seq_ctr) + 0x10;
diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs.c b/drivers/net/wirel=
ess/iwlwifi/mvm/debugfs.c
index 9864d713eb2c..a8fe6b41f9a3 100644
--- a/drivers/net/wireless/iwlwifi/mvm/debugfs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/debugfs.c
@@ -119,6 +119,10 @@ static ssize_t iwl_dbgfs_sta_drain_write(struct file *=
file,
=20
 	if (sscanf(buf, "%d %d", &sta_id, &drain) !=3D 2)
 		return -EINVAL;
+	if (sta_id < 0 || sta_id >=3D IWL_MVM_STATION_COUNT)
+		return -EINVAL;
+	if (drain < 0 || drain > 1)
+		return -EINVAL;
=20
 	mutex_lock(&mvm->mutex);
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.c b/drivers/net/wi=
reless/iwlwifi/mvm/time-event.c
index 33cf56fdfc41..95ce4b601fef 100644
--- a/drivers/net/wireless/iwlwifi/mvm/time-event.c
+++ b/drivers/net/wireless/iwlwifi/mvm/time-event.c
@@ -176,8 +176,11 @@ static void iwl_mvm_te_handle_notif(struct iwl_mvm *mv=
m,
 	 * P2P Device discoveribility, while there are other higher priority
 	 * events in the system).
 	 */
-	if (WARN_ONCE(!le32_to_cpu(notif->status),
-		      "Failed to schedule time event\n")) {
+	if (!le32_to_cpu(notif->status)) {
+		bool start =3D le32_to_cpu(notif->action) &
+				TE_V2_NOTIF_HOST_EVENT_START;
+		IWL_WARN(mvm, "Time Event %s notification failure\n",
+			 start ? "start" : "end");
 		if (iwl_mvm_te_check_disconnect(mvm, te_data->vif, NULL)) {
 			iwl_mvm_te_clear_data(mvm, te_data);
 			return;
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index 941c0c88f982..86605027c41d 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -353,6 +353,27 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
=20
 /* 7265 Series */
 	{IWL_PCI_DEVICE(0x095A, 0x5010, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5110, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5310, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5302, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5210, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5012, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x500A, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5410, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x1010, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5000, iwl7265_2n_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5200, iwl7265_2n_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5002, iwl7265_n_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5202, iwl7265_n_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9010, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9210, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9410, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5020, iwl7265_2n_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x502A, iwl7265_2n_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5420, iwl7265_2n_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5090, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5290, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5490, iwl7265_2ac_cfg)},
 #endif /* CONFIG_IWLMVM */
=20
 	{0}
diff --git a/drivers/net/wireless/iwlwifi/pcie/internal.h b/drivers/net/wir=
eless/iwlwifi/pcie/internal.h
index fa22639b63c9..051268c037b1 100644
--- a/drivers/net/wireless/iwlwifi/pcie/internal.h
+++ b/drivers/net/wireless/iwlwifi/pcie/internal.h
@@ -477,4 +477,12 @@ static inline bool iwl_is_rfkill_set(struct iwl_trans =
*trans)
 		CSR_GP_CNTRL_REG_FLAG_HW_RF_KILL_SW);
 }
=20
+static inline void iwl_nic_error(struct iwl_trans *trans)
+{
+	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
+
+	set_bit(STATUS_FW_ERROR, &trans_pcie->status);
+	iwl_op_mode_nic_error(trans->op_mode);
+}
+
 #endif /* __iwl_trans_int_pcie_h__ */
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/=
iwlwifi/pcie/rx.c
index 3f237b42eb36..be3995afa9d0 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -489,6 +489,10 @@ static void iwl_pcie_rx_hw_init(struct iwl_trans *tran=
s, struct iwl_rxq *rxq)
=20
 	/* Set interrupt coalescing timer to default (2048 usecs) */
 	iwl_write8(trans, CSR_INT_COALESCING, IWL_HOST_INT_TIMEOUT_DEF);
+
+	/* W/A for interrupt coalescing bug in 7260 and 3160 */
+	if (trans->cfg->host_interrupt_operation_mode)
+		iwl_set_bit(trans, CSR_INT_COALESCING, IWL_HOST_INT_OPER_MODE);
 }
=20
 static void iwl_pcie_rx_init_rxb_lists(struct iwl_rxq *rxq)
@@ -796,12 +800,13 @@ static void iwl_pcie_irq_handle_error(struct iwl_tran=
s *trans)
 	iwl_pcie_dump_csr(trans);
 	iwl_dump_fh(trans, NULL);
=20
+	/* set the ERROR bit before we wake up the caller */
 	set_bit(STATUS_FW_ERROR, &trans_pcie->status);
 	clear_bit(STATUS_HCMD_ACTIVE, &trans_pcie->status);
 	wake_up(&trans_pcie->wait_command_queue);
=20
 	local_bh_disable();
-	iwl_op_mode_nic_error(trans->op_mode);
+	iwl_nic_error(trans);
 	local_bh_enable();
 }
=20
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 5d9337bec67a..cde9c16f6e4f 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -279,9 +279,6 @@ static int iwl_pcie_nic_init(struct iwl_trans *trans)
 	spin_lock_irqsave(&trans_pcie->irq_lock, flags);
 	iwl_pcie_apm_init(trans);
=20
-	/* Set interrupt coalescing calibration timer to default (512 usecs) */
-	iwl_write8(trans, CSR_INT_COALESCING, IWL_HOST_INT_CALIB_TIMEOUT_DEF);
-
 	spin_unlock_irqrestore(&trans_pcie->irq_lock, flags);
=20
 	iwl_pcie_set_pwr(trans, false);
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/=
iwlwifi/pcie/tx.c
index 059c5acad3a0..0adde919a258 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -207,7 +207,7 @@ static void iwl_pcie_txq_stuck_timer(unsigned long data)
 		IWL_ERR(trans, "scratch %d =3D 0x%08x\n", i,
 			le32_to_cpu(txq->scratchbufs[i].scratch));
=20
-	iwl_op_mode_nic_error(trans->op_mode);
+	iwl_nic_error(trans);
 }
=20
 /*
@@ -1023,7 +1023,7 @@ static void iwl_pcie_cmdq_reclaim(struct iwl_trans *t=
rans, int txq_id, int idx)
 		if (nfreed++ > 0) {
 			IWL_ERR(trans, "HCMD skipped: index (%d) %d %d\n",
 				idx, q->write_ptr, q->read_ptr);
-			iwl_op_mode_nic_error(trans->op_mode);
+			iwl_nic_error(trans);
 		}
 	}
=20
@@ -1562,7 +1562,7 @@ static int iwl_pcie_send_hcmd_sync(struct iwl_trans *=
trans,
 				       get_cmd_string(trans_pcie, cmd->id));
 			ret =3D -ETIMEDOUT;
=20
-			iwl_op_mode_nic_error(trans->op_mode);
+			iwl_nic_error(trans);
=20
 			goto cancel;
 		}
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/m=
ac80211_hwsim.c
index 9df7bc91a26f..c72438bb2faf 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -383,6 +383,14 @@ struct hwsim_radiotap_hdr {
 	__le16 rt_chbitmask;
 } __packed;
=20
+struct hwsim_radiotap_ack_hdr {
+	struct ieee80211_radiotap_header hdr;
+	u8 rt_flags;
+	u8 pad;
+	__le16 rt_channel;
+	__le16 rt_chbitmask;
+} __packed;
+
 /* MAC80211_HWSIM netlinf family */
 static struct genl_family hwsim_genl_family =3D {
 	.id =3D GENL_ID_GENERATE,
@@ -500,7 +508,7 @@ static void mac80211_hwsim_monitor_ack(struct ieee80211=
_channel *chan,
 				       const u8 *addr)
 {
 	struct sk_buff *skb;
-	struct hwsim_radiotap_hdr *hdr;
+	struct hwsim_radiotap_ack_hdr *hdr;
 	u16 flags;
 	struct ieee80211_hdr *hdr11;
=20
@@ -511,14 +519,14 @@ static void mac80211_hwsim_monitor_ack(struct ieee802=
11_channel *chan,
 	if (skb =3D=3D NULL)
 		return;
=20
-	hdr =3D (struct hwsim_radiotap_hdr *) skb_put(skb, sizeof(*hdr));
+	hdr =3D (struct hwsim_radiotap_ack_hdr *) skb_put(skb, sizeof(*hdr));
 	hdr->hdr.it_version =3D PKTHDR_RADIOTAP_VERSION;
 	hdr->hdr.it_pad =3D 0;
 	hdr->hdr.it_len =3D cpu_to_le16(sizeof(*hdr));
 	hdr->hdr.it_present =3D cpu_to_le32((1 << IEEE80211_RADIOTAP_FLAGS) |
 					  (1 << IEEE80211_RADIOTAP_CHANNEL));
 	hdr->rt_flags =3D 0;
-	hdr->rt_rate =3D 0;
+	hdr->pad =3D 0;
 	hdr->rt_channel =3D cpu_to_le16(chan->center_freq);
 	flags =3D IEEE80211_CHAN_2GHZ;
 	hdr->rt_chbitmask =3D cpu_to_le16(flags);
@@ -1230,7 +1238,7 @@ static void mac80211_hwsim_bss_info_changed(struct ie=
ee80211_hw *hw,
 					      HRTIMER_MODE_REL);
 		} else if (!info->enable_beacon) {
 			unsigned int count =3D 0;
-			ieee80211_iterate_active_interfaces(
+			ieee80211_iterate_active_interfaces_atomic(
 				data->hw, IEEE80211_IFACE_ITER_NORMAL,
 				mac80211_hwsim_bcn_en_iter, &count);
 			wiphy_debug(hw->wiphy, "  beaconing vifs remaining: %u",
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index c8e029df770e..a09398fe9e2a 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -319,8 +319,8 @@ int mwifiex_bss_start(struct mwifiex_private *priv, str=
uct cfg80211_bss *bss,
 		if (bss_desc && bss_desc->ssid.ssid_len &&
 		    (!mwifiex_ssid_cmp(&priv->curr_bss_params.bss_descriptor.
 				       ssid, &bss_desc->ssid))) {
-			kfree(bss_desc);
-			return 0;
+			ret =3D 0;
+			goto done;
 		}
=20
 		/* Exit Adhoc mode first */
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 95667b088c5b..364ce0c5962f 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1368,7 +1368,7 @@ static int sta_apply_parameters(struct ieee80211_loca=
l *local,
 			changed |=3D
 			      ieee80211_mps_set_sta_local_pm(sta,
 							     params->local_pm);
-		ieee80211_bss_info_change_notify(sdata, changed);
+		ieee80211_mbss_info_change_notify(sdata, changed);
 #endif
 	}
=20
@@ -2488,8 +2488,7 @@ static int ieee80211_set_power_mgmt(struct wiphy *wip=
hy, struct net_device *dev,
 	struct ieee80211_sub_if_data *sdata =3D IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local =3D wdev_priv(dev->ieee80211_ptr);
=20
-	if (sdata->vif.type !=3D NL80211_IFTYPE_STATION &&
-	    sdata->vif.type !=3D NL80211_IFTYPE_MESH_POINT)
+	if (sdata->vif.type !=3D NL80211_IFTYPE_STATION)
 		return -EOPNOTSUPP;
=20
 	if (!(local->hw.flags & IEEE80211_HW_SUPPORTS_PS))
@@ -3120,9 +3119,17 @@ static int ieee80211_channel_switch(struct wiphy *wi=
phy, struct net_device *dev,
 		    params->chandef.chan->band)
 			return -EINVAL;
=20
+		ifmsh->chsw_init =3D true;
+		if (!ifmsh->pre_value)
+			ifmsh->pre_value =3D 1;
+		else
+			ifmsh->pre_value++;
+
 		err =3D ieee80211_mesh_csa_beacon(sdata, params, true);
-		if (err < 0)
+		if (err < 0) {
+			ifmsh->chsw_init =3D false;
 			return err;
+		}
 		break;
 #endif
 	default:
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 531be040b9ae..27a39de89679 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -823,6 +823,10 @@ ieee80211_ibss_process_chanswitch(struct ieee80211_sub=
_if_data *sdata,
 	if (err)
 		return false;
=20
+	/* channel switch is not supported, disconnect */
+	if (!(sdata->local->hw.wiphy->flags & WIPHY_FLAG_HAS_CHANNEL_SWITCH))
+		goto disconnect;
+
 	params.count =3D csa_ie.count;
 	params.chandef =3D csa_ie.chandef;
=20
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 29dc505be125..4aea4e791113 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1228,6 +1228,7 @@ struct ieee80211_csa_ie {
 	u8 mode;
 	u8 count;
 	u8 ttl;
+	u16 pre_value;
 };
=20
 /* Parsed Information Elements */
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index ff101ea1d9ae..36c3a4cbcabf 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1325,7 +1325,6 @@ static void ieee80211_setup_sdata(struct ieee80211_su=
b_if_data *sdata,
 		sdata->vif.bss_conf.bssid =3D NULL;
 		break;
 	case NL80211_IFTYPE_AP_VLAN:
-		break;
 	case NL80211_IFTYPE_P2P_DEVICE:
 		sdata->vif.bss_conf.bssid =3D sdata->vif.addr;
 		break;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 21d5d44444d0..7d1c3ac48ed9 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -940,6 +940,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 		wiphy_debug(local->hw.wiphy, "Failed to initialize wep: %d\n",
 			    result);
=20
+	local->hw.conf.flags =3D IEEE80211_CONF_IDLE;
+
 	ieee80211_led_init(local);
=20
 	rtnl_lock();
@@ -1047,6 +1049,7 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
=20
 	cancel_work_sync(&local->restart_work);
 	cancel_work_sync(&local->reconfig_filter);
+	flush_work(&local->sched_scan_stopped_work);
=20
 	ieee80211_clear_tx_pending(local);
 	rate_control_deinitialize(local);
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 896fe3bd599e..ba105257d03f 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -943,14 +943,19 @@ ieee80211_mesh_process_chnswitch(struct ieee80211_sub=
_if_data *sdata,
 		 params.chandef.chan->center_freq);
=20
 	params.block_tx =3D csa_ie.mode & WLAN_EID_CHAN_SWITCH_PARAM_TX_RESTRICT;
-	if (beacon)
+	if (beacon) {
 		ifmsh->chsw_ttl =3D csa_ie.ttl - 1;
-	else
-		ifmsh->chsw_ttl =3D 0;
+		if (ifmsh->pre_value >=3D csa_ie.pre_value)
+			return false;
+		ifmsh->pre_value =3D csa_ie.pre_value;
+	}
=20
-	if (ifmsh->chsw_ttl > 0)
+	if (ifmsh->chsw_ttl < ifmsh->mshcfg.dot11MeshTTL) {
 		if (ieee80211_mesh_csa_beacon(sdata, &params, false) < 0)
 			return false;
+	} else {
+		return false;
+	}
=20
 	sdata->csa_radar_required =3D params.radar_required;
=20
@@ -1163,7 +1168,6 @@ static int mesh_fwd_csa_frame(struct ieee80211_sub_if=
_data *sdata,
 	offset_ttl =3D (len < 42) ? 7 : 10;
 	*(pos + offset_ttl) -=3D 1;
 	*(pos + offset_ttl + 1) &=3D ~WLAN_EID_CHAN_SWITCH_PARAM_INITIATOR;
-	sdata->u.mesh.chsw_ttl =3D *(pos + offset_ttl);
=20
 	memcpy(mgmt_fwd, mgmt, len);
 	eth_broadcast_addr(mgmt_fwd->da);
@@ -1182,7 +1186,7 @@ static void mesh_rx_csa_frame(struct ieee80211_sub_if=
_data *sdata,
 	u16 pre_value;
 	bool fwd_csa =3D true;
 	size_t baselen;
-	u8 *pos, ttl;
+	u8 *pos;
=20
 	if (mgmt->u.action.u.measurement.action_code !=3D
 	    WLAN_ACTION_SPCT_CHL_SWITCH)
@@ -1193,8 +1197,8 @@ static void mesh_rx_csa_frame(struct ieee80211_sub_if=
_data *sdata,
 			   u.action.u.chan_switch.variable);
 	ieee802_11_parse_elems(pos, len - baselen, false, &elems);
=20
-	ttl =3D elems.mesh_chansw_params_ie->mesh_ttl;
-	if (!--ttl)
+	ifmsh->chsw_ttl =3D elems.mesh_chansw_params_ie->mesh_ttl;
+	if (!--ifmsh->chsw_ttl)
 		fwd_csa =3D false;
=20
 	pre_value =3D le16_to_cpu(elems.mesh_chansw_params_ie->mesh_pre_value);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index d7504ab61a34..b3a3ce316656 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1910,6 +1910,8 @@ static void ieee80211_mgd_probe_ap(struct ieee80211_s=
ub_if_data *sdata,
 	if (ifmgd->flags & IEEE80211_STA_CONNECTION_POLL)
 		already =3D true;
=20
+	ifmgd->flags |=3D IEEE80211_STA_CONNECTION_POLL;
+
 	mutex_unlock(&sdata->local->mtx);
=20
 	if (already)
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_mins=
trel_ht.c
index 5d60779a0c1b..4096ff6cc24f 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -226,7 +226,7 @@ minstrel_ht_calc_tp(struct minstrel_ht_sta *mi, int gro=
up, int rate)
 		nsecs =3D 1000 * mi->overhead / MINSTREL_TRUNC(mi->avg_ampdu_len);
=20
 	nsecs +=3D minstrel_mcs_groups[group].duration[rate];
-	tp =3D 1000000 * ((mr->probability * 1000) / nsecs);
+	tp =3D 1000000 * ((prob * 1000) / nsecs);
=20
 	mr->cur_tp =3D MINSTREL_TRUNC(tp);
 }
@@ -277,13 +277,15 @@ minstrel_ht_update_stats(struct minstrel_priv *mp, st=
ruct minstrel_ht_sta *mi)
 			if (!(mg->supported & BIT(i)))
 				continue;
=20
+			index =3D MCS_GROUP_RATES * group + i;
+
 			/* initialize rates selections starting indexes */
 			if (!mg_rates_valid) {
 				mg->max_tp_rate =3D mg->max_tp_rate2 =3D
 					mg->max_prob_rate =3D i;
 				if (!mi_rates_valid) {
 					mi->max_tp_rate =3D mi->max_tp_rate2 =3D
-						mi->max_prob_rate =3D i;
+						mi->max_prob_rate =3D index;
 					mi_rates_valid =3D true;
 				}
 				mg_rates_valid =3D true;
@@ -291,7 +293,6 @@ minstrel_ht_update_stats(struct minstrel_priv *mp, stru=
ct minstrel_ht_sta *mi)
=20
 			mr =3D &mg->rates[i];
 			mr->retry_updated =3D false;
-			index =3D MCS_GROUP_RATES * group + i;
 			minstrel_calc_rate_ewma(mr);
 			minstrel_ht_calc_tp(mi, group, i);
=20
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index caecef870c0e..2b0debb0422b 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -911,7 +911,8 @@ static void ieee80211_rx_reorder_ampdu(struct ieee80211=
_rx_data *rx,
 	u16 sc;
 	u8 tid, ack_policy;
=20
-	if (!ieee80211_is_data_qos(hdr->frame_control))
+	if (!ieee80211_is_data_qos(hdr->frame_control) ||
+	    is_multicast_ether_addr(hdr->addr1))
 		goto dont_reorder;
=20
 	/*
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 5ad66a83ef7f..bcc4833d7542 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -1088,6 +1088,6 @@ void ieee80211_sched_scan_stopped(struct ieee80211_hw=
 *hw)
=20
 	trace_api_sched_scan_stopped(local);
=20
-	ieee80211_queue_work(&local->hw, &local->sched_scan_stopped_work);
+	schedule_work(&local->sched_scan_stopped_work);
 }
 EXPORT_SYMBOL(ieee80211_sched_scan_stopped);
diff --git a/net/mac80211/spectmgmt.c b/net/mac80211/spectmgmt.c
index a40da20b32e0..6ab009070084 100644
--- a/net/mac80211/spectmgmt.c
+++ b/net/mac80211/spectmgmt.c
@@ -78,6 +78,8 @@ int ieee80211_parse_ch_switch_ie(struct ieee80211_sub_if_=
data *sdata,
 	if (elems->mesh_chansw_params_ie) {
 		csa_ie->ttl =3D elems->mesh_chansw_params_ie->mesh_ttl;
 		csa_ie->mode =3D elems->mesh_chansw_params_ie->mesh_flags;
+		csa_ie->pre_value =3D le16_to_cpu(
+				elems->mesh_chansw_params_ie->mesh_pre_value);
 	}
=20
 	new_freq =3D ieee80211_channel_to_frequency(new_chan_no, new_band);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 592a18171f95..9f9b9bd3fd44 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -2278,17 +2278,15 @@ void ieee80211_dfs_radar_detected_work(struct work_=
struct *work)
 {
 	struct ieee80211_local *local =3D
 		container_of(work, struct ieee80211_local, radar_detected_work);
-	struct cfg80211_chan_def chandef;
+	struct cfg80211_chan_def chandef =3D local->hw.conf.chandef;
=20
 	ieee80211_dfs_cac_cancel(local);
=20
 	if (local->use_chanctx)
 		/* currently not handled */
 		WARN_ON(1);
-	else {
-		chandef =3D local->hw.conf.chandef;
+	else
 		cfg80211_radar_event(local->hw.wiphy, &chandef, GFP_KERNEL);
-	}
 }
=20
 void ieee80211_radar_detected(struct ieee80211_hw *hw)
@@ -2459,14 +2457,9 @@ int ieee80211_send_action_csa(struct ieee80211_sub_i=
f_data *sdata,
 			  WLAN_EID_CHAN_SWITCH_PARAM_TX_RESTRICT : 0x00;
 		put_unaligned_le16(WLAN_REASON_MESH_CHAN, pos); /* Reason Cd */
 		pos +=3D 2;
-		if (!ifmsh->pre_value)
-			ifmsh->pre_value =3D 1;
-		else
-			ifmsh->pre_value++;
 		pre_value =3D cpu_to_le16(ifmsh->pre_value);
 		memcpy(pos, &pre_value, 2);		/* Precedence Value */
 		pos +=3D 2;
-		ifmsh->chsw_init =3D true;
 	}
=20
 	ieee80211_tx_skb(sdata, skb);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index aff959e5a1b3..52b865fb7351 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -451,6 +451,15 @@ int wiphy_register(struct wiphy *wiphy)
 	int i;
 	u16 ifmodes =3D wiphy->interface_modes;
=20
+	/* support for 5/10 MHz is broken due to nl80211 API mess - disable */
+	wiphy->flags &=3D ~WIPHY_FLAG_SUPPORTS_5_10_MHZ;
+
+	/*
+	 * There are major locking problems in nl80211/mac80211 for CSA,
+	 * disable for all drivers until this has been reworked.
+	 */
+	wiphy->flags &=3D ~WIPHY_FLAG_HAS_CHANNEL_SWITCH;
+
 #ifdef CONFIG_PM
 	if (WARN_ON(wiphy->wowlan &&
 		    (wiphy->wowlan->flags & WIPHY_WOWLAN_GTK_REKEY_FAILURE) &&
diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index 9d797df56649..89737ee2669a 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -262,7 +262,7 @@ int cfg80211_ibss_wext_join(struct cfg80211_registered_=
device *rdev,
=20
 	/* try to find an IBSS channel if none requested ... */
 	if (!wdev->wext.ibss.chandef.chan) {
-		wdev->wext.ibss.chandef.width =3D NL80211_CHAN_WIDTH_20_NOHT;
+		struct ieee80211_channel *new_chan =3D NULL;
=20
 		for (band =3D 0; band < IEEE80211_NUM_BANDS; band++) {
 			struct ieee80211_supported_band *sband;
@@ -278,18 +278,19 @@ int cfg80211_ibss_wext_join(struct cfg80211_registere=
d_device *rdev,
 					continue;
 				if (chan->flags & IEEE80211_CHAN_DISABLED)
 					continue;
-				wdev->wext.ibss.chandef.chan =3D chan;
-				wdev->wext.ibss.chandef.center_freq1 =3D
-					chan->center_freq;
+				new_chan =3D chan;
 				break;
 			}
=20
-			if (wdev->wext.ibss.chandef.chan)
+			if (new_chan)
 				break;
 		}
=20
-		if (!wdev->wext.ibss.chandef.chan)
+		if (!new_chan)
 			return -EINVAL;
+
+		cfg80211_chandef_create(&wdev->wext.ibss.chandef, new_chan,
+					NL80211_CHAN_NO_HT);
 	}
=20
 	/* don't join -- SSID is not there */
@@ -363,9 +364,8 @@ int cfg80211_ibss_wext_siwfreq(struct net_device *dev,
 		return err;
=20
 	if (chan) {
-		wdev->wext.ibss.chandef.chan =3D chan;
-		wdev->wext.ibss.chandef.width =3D NL80211_CHAN_WIDTH_20_NOHT;
-		wdev->wext.ibss.chandef.center_freq1 =3D freq;
+		cfg80211_chandef_create(&wdev->wext.ibss.chandef, chan,
+					NL80211_CHAN_NO_HT);
 		wdev->wext.ibss.channel_fixed =3D true;
 	} else {
 		/* cfg80211_ibss_wext_join will pick one if needed */
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index a1eb21073176..138dc3bb8b67 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2687,7 +2687,7 @@ static int nl80211_get_key(struct sk_buff *skb, struc=
t genl_info *info)
 	hdr =3D nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_NEW_KEY);
 	if (!hdr)
-		return -ENOBUFS;
+		goto nla_put_failure;
=20
 	cookie.msg =3D msg;
 	cookie.idx =3D key_idx;
@@ -5349,6 +5349,10 @@ static int nl80211_trigger_scan(struct sk_buff *skb,=
 struct genl_info *info)
 				err =3D -EINVAL;
 				goto out_free;
 			}
+
+			if (!wiphy->bands[band])
+				continue;
+
 			err =3D ieee80211_get_ratemask(wiphy->bands[band],
 						     nla_data(attr),
 						     nla_len(attr),
@@ -9633,8 +9637,9 @@ static int nl80211_add_scan_req(struct sk_buff *msg,
 	    nla_put(msg, NL80211_ATTR_IE, req->ie_len, req->ie))
 		goto nla_put_failure;
=20
-	if (req->flags)
-		nla_put_u32(msg, NL80211_ATTR_SCAN_FLAGS, req->flags);
+	if (req->flags &&
+	    nla_put_u32(msg, NL80211_ATTR_SCAN_FLAGS, req->flags))
+		goto nla_put_failure;
=20
 	return 0;
  nla_put_failure:
@@ -11093,6 +11098,8 @@ void cfg80211_report_wowlan_wakeup(struct wireless_=
dev *wdev,
 		struct nlattr *reasons;
=20
 		reasons =3D nla_nest_start(msg, NL80211_ATTR_WOWLAN_TRIGGERS);
+		if (!reasons)
+			goto free_msg;
=20
 		if (wakeup->disconnect &&
 		    nla_put_flag(msg, NL80211_WOWLAN_TRIG_DISCONNECT))
@@ -11118,16 +11125,18 @@ void cfg80211_report_wowlan_wakeup(struct wireles=
s_dev *wdev,
 				wakeup->pattern_idx))
 			goto free_msg;
=20
-		if (wakeup->tcp_match)
-			nla_put_flag(msg, NL80211_WOWLAN_TRIG_WAKEUP_TCP_MATCH);
+		if (wakeup->tcp_match &&
+		    nla_put_flag(msg, NL80211_WOWLAN_TRIG_WAKEUP_TCP_MATCH))
+			goto free_msg;
=20
-		if (wakeup->tcp_connlost)
-			nla_put_flag(msg,
-				     NL80211_WOWLAN_TRIG_WAKEUP_TCP_CONNLOST);
+		if (wakeup->tcp_connlost &&
+		    nla_put_flag(msg, NL80211_WOWLAN_TRIG_WAKEUP_TCP_CONNLOST))
+			goto free_msg;
=20
-		if (wakeup->tcp_nomoretokens)
-			nla_put_flag(msg,
-				NL80211_WOWLAN_TRIG_WAKEUP_TCP_NOMORETOKENS);
+		if (wakeup->tcp_nomoretokens &&
+		    nla_put_flag(msg,
+				 NL80211_WOWLAN_TRIG_WAKEUP_TCP_NOMORETOKENS))
+			goto free_msg;
=20
 		if (wakeup->packet) {
 			u32 pkt_attr =3D NL80211_WOWLAN_TRIG_WAKEUP_PKT_80211;
@@ -11263,24 +11272,29 @@ void cfg80211_ft_event(struct net_device *netdev,
 		return;
=20
 	hdr =3D nl80211hdr_put(msg, 0, 0, 0, NL80211_CMD_FT_EVENT);
-	if (!hdr) {
-		nlmsg_free(msg);
-		return;
-	}
+	if (!hdr)
+		goto out;
=20
-	nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx);
-	nla_put_u32(msg, NL80211_ATTR_IFINDEX, netdev->ifindex);
-	nla_put(msg, NL80211_ATTR_MAC, ETH_ALEN, ft_event->target_ap);
-	if (ft_event->ies)
-		nla_put(msg, NL80211_ATTR_IE, ft_event->ies_len, ft_event->ies);
-	if (ft_event->ric_ies)
-		nla_put(msg, NL80211_ATTR_IE_RIC, ft_event->ric_ies_len,
-			ft_event->ric_ies);
+	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
+	    nla_put_u32(msg, NL80211_ATTR_IFINDEX, netdev->ifindex) ||
+	    nla_put(msg, NL80211_ATTR_MAC, ETH_ALEN, ft_event->target_ap))
+		goto out;
+
+	if (ft_event->ies &&
+	    nla_put(msg, NL80211_ATTR_IE, ft_event->ies_len, ft_event->ies))
+		goto out;
+	if (ft_event->ric_ies &&
+	    nla_put(msg, NL80211_ATTR_IE_RIC, ft_event->ric_ies_len,
+		    ft_event->ric_ies))
+		goto out;
=20
 	genlmsg_end(msg, hdr);
=20
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				NL80211_MCGRP_MLME, GFP_KERNEL);
+	return;
+ out:
+	nlmsg_free(msg);
 }
 EXPORT_SYMBOL(cfg80211_ft_event);
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSoK8dAAoJEJctW/TcYTgGeuIQAI66lHtBBgmRCjXK2LXZ+Qrq
VR/Lzm5mBBOHYyHmKzfPmqUHkYR4KnXrSPYltfI6V8esNULt+LAwjioyUPwmuoh0
PNtGYuum/ROqg9Arsqtr5YKpauIMrUcklCIYljJEwrYQsC+Dlz3Yo+iKnt9Dy4K9
Tg3Mb/Hwa4MttRI2JDKAn8fz44QgNXUoEv6r5999bDFQ31cT38wz0pq9M7NFfeg7
rQZPNZk6q5tcMsvFTNm5VRfWkgXanPqyvplVFhwQ3SEzI637eYF7F0+JSWdFYmnZ
w21WEsxJNbaBtSArjJth9BhjZPhFf5foIKnKlSjDY/Zg9qbQ3sxCCfD7pu2ABRWO
JJIu0e7TmlIqNEP0AEQFRveClaN7qQaC25fd8losABzBP75N3gT/qsQAreFKb+Mu
+KMdSijQvq4oPlDxfGJOX3V6NBJpxFbOv+aavilP+gdRali/Qomns+fb8gNtbtiI
VTQNQLIL86I8Hk/kQUKDOLE+KP+O6evrrKCo7g0SX50GCMbHRnNnVzu5nRwYi7+W
aaq9ote8BeiK6aXpVkHn+m1NyOYtgL1J566390JjIo2XIhEmOvf+E1auRUPldXxX
zQM2TVuzZIAWrBSUZOVKFNjnZAebg3onKq2qOtchwT9ltyz6JBftgosHM+AghieX
AY24VcJBo18KxDBU8Vmv
=EX/c
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--
