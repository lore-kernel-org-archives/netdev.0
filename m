From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-01-04
Date: Fri, 4 Jan 2013 15:53:43 -0500
Message-ID: <20130104205343.GB21871@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BOKacYhQ+x31HxR3"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is a batch of fixes intended for 3.8.

Arend "fixes" a copyright notice in brcmsmac -- seems harmless.

Christian Lamparter adds a device ID to p54usb, and changes the
interface combinations reported by carl9170 in order to get it
working again.

Geert Uytterhoeven gives us a pair of fixes for Kconfig warnings
about bcma and ssb.

Hante Meuleman fixes some IE parsing to get AP mode working with
WPA2 security.

Jesper Juhl fixes a urb leak in rtlwifi.

Jussi Kivilinna fixes some mis-usage of usb_alloc_coherent in rtlwifi,
avoiding a BUG on ARM.

Larry Finger provides a handful of rtlwifi fixes to avoid some log
SPAM due to not checking the return of pci_map_single.

Niels Ole Salscheider changes a usleep_range in brcmsmac to use udelay
instead, avoiding a "BUG: scheduling while atomic".

Rafa=C5=82 Mi=C5=82ecki fixes an ID for a serial flash in the bcma code.

Sujith Manoharan provides a pair of ath9k fixes, one for a compilation
break and one to correct some gain-related initvals.

Tomasz Guszkowski adds a device ID to p54usb.

Vladimir Kondratiev fixes a Kconfig problem which cause ath9k_htc
not to build properly.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit fdb184d1467f9ed5b17c553b85eb1bb72bdbf62f:

  bridge: add empty br_mdb_init() and br_mdb_uninit() definitions. (2013-01=
-03 03:35:22 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 7b87e573413c3d6a006f572fb4d2105ff5d97fda:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-01-04 15:22:52 -0500)

----------------------------------------------------------------

Arend van Spriel (1):
      brcmsmac: add copyright information for Canonical

Christian Lamparter (2):
      carl9170: fix -EINVAL bailout during init with !CONFIG_MAC80211_MESH
      p54usb: add USBIDs for two more p54usb devices

Geert Uytterhoeven (2):
      bcma: BCMA_DRIVER_GPIO should depend on GPIOLIB instead of selecting =
it
      ssb: SSB_DRIVER_GPIO should depend on GPIOLIB instead of selecting it

Hante Meuleman (1):
      brcmfmac: fix parsing rsn ie for ap mode.

Jesper Juhl (1):
      rtlwifi: Don't leak on error in _rtl_usb_receive()

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jussi Kivilinna (1):
      rtlwifi: fix incorrect use of usb_alloc_coherent with usb_control_msg

Larry Finger (5):
      rtlwifi: Fix warning for unchecked pci_map_single() call
      rtlwifi: rtl8192ce: Fix warning for unchecked pci_map_single() call
      rtlwifi: rtl8192de: Fix warning for unchecked pci_map_single() call
      rtlwifi: rtl8192se: Fix warning for unchecked pci_map_single() call
      rtlwifi: rtl8723ae: Fix warning for unchecked pci_map_single() call

Niels Ole Salscheider (1):
      brcmsmac: Use udelay instead of usleep_range

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: correct M25P32 serial flash ID

Sujith Manoharan (2):
      ath9k: Fix compilation breakage
      ath9k_hw: Fix RX gain initvals for AR9485

Tomasz Guszkowski (1):
      p54usb: add USB ID for T-Com Sinus 154 data II

Vladimir Kondratiev (1):
      ath9k: Fix Kconfig for ATH9K_HTC

 drivers/bcma/Kconfig                                  |  3 +--
 drivers/bcma/driver_chipcommon_sflash.c               |  2 +-
 drivers/net/wireless/ath/ath9k/Kconfig                |  5 +++--
 drivers/net/wireless/ath/ath9k/ar9003_hw.c            |  2 +-
 drivers/net/wireless/ath/carl9170/fw.c                |  6 +++++-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  5 +++--
 drivers/net/wireless/brcm80211/brcmsmac/debug.h       |  1 +
 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c |  4 ++--
 drivers/net/wireless/p54/p54usb.c                     |  4 ++++
 drivers/net/wireless/rtlwifi/pci.c                    |  6 ++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c          | 11 +++++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c          | 10 ++++++++++
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c          | 13 ++++++++++++-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c          | 10 ++++++++++
 drivers/net/wireless/rtlwifi/usb.c                    |  8 ++++----
 drivers/ssb/Kconfig                                   |  3 +--
 16 files changed, 75 insertions(+), 18 deletions(-)

diff --git a/drivers/bcma/Kconfig b/drivers/bcma/Kconfig
index d7b56a8..8b4221c 100644
--- a/drivers/bcma/Kconfig
+++ b/drivers/bcma/Kconfig
@@ -67,8 +67,7 @@ config BCMA_DRIVER_GMAC_CMN
=20
 config BCMA_DRIVER_GPIO
 	bool "BCMA GPIO driver"
-	depends on BCMA
-	select GPIOLIB
+	depends on BCMA && GPIOLIB
 	help
 	  Driver to provide access to the GPIO pins of the bcma bus.
=20
diff --git a/drivers/bcma/driver_chipcommon_sflash.c b/drivers/bcma/driver_=
chipcommon_sflash.c
index 63e6883..1e694db 100644
--- a/drivers/bcma/driver_chipcommon_sflash.c
+++ b/drivers/bcma/driver_chipcommon_sflash.c
@@ -35,7 +35,7 @@ static struct bcma_sflash_tbl_e bcma_sflash_st_tbl[] =3D {
 	{ "M25P40", 0x12, 0x10000, 8, },
=20
 	{ "M25P16", 0x14, 0x10000, 32, },
-	{ "M25P32", 0x14, 0x10000, 64, },
+	{ "M25P32", 0x15, 0x10000, 64, },
 	{ "M25P64", 0x16, 0x10000, 128, },
 	{ "M25FL128", 0x17, 0x10000, 256, },
 	{ 0 },
diff --git a/drivers/net/wireless/ath/ath9k/Kconfig b/drivers/net/wireless/=
ath/ath9k/Kconfig
index 5fc15bf..7647ed6 100644
--- a/drivers/net/wireless/ath/ath9k/Kconfig
+++ b/drivers/net/wireless/ath/ath9k/Kconfig
@@ -2,6 +2,7 @@ config ATH9K_HW
 	tristate
 config ATH9K_COMMON
 	tristate
+	select ATH_COMMON
 config ATH9K_DFS_DEBUGFS
 	def_bool y
 	depends on ATH9K_DEBUGFS && ATH9K_DFS_CERTIFIED
@@ -17,7 +18,6 @@ config ATH9K_BTCOEX_SUPPORT
 config ATH9K
 	tristate "Atheros 802.11n wireless cards support"
 	depends on MAC80211
-	select ATH_COMMON
 	select ATH9K_HW
 	select MAC80211_LEDS
 	select LEDS_CLASS
@@ -56,7 +56,8 @@ config ATH9K_AHB
=20
 config ATH9K_DEBUGFS
 	bool "Atheros ath9k debugging"
-	depends on ATH9K && DEBUG_FS
+	depends on ATH9K
+	select MAC80211_DEBUGFS
 	---help---
 	  Say Y, if you need access to ath9k's statistics for
 	  interrupts, rate control, etc.
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_hw.c b/drivers/net/wirel=
ess/ath/ath9k/ar9003_hw.c
index 74fd397..59bf5f3 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_hw.c
@@ -544,7 +544,7 @@ static void ar9003_rx_gain_table_mode0(struct ath_hw *a=
h)
 				ar9340Common_rx_gain_table_1p0);
 	else if (AR_SREV_9485_11(ah))
 		INIT_INI_ARRAY(&ah->iniModesRxGain,
-				ar9485Common_wo_xlna_rx_gain_1_1);
+			       ar9485_common_rx_gain_1_1);
 	else if (AR_SREV_9550(ah)) {
 		INIT_INI_ARRAY(&ah->iniModesRxGain,
 				ar955x_1p0_common_rx_gain_table);
diff --git a/drivers/net/wireless/ath/carl9170/fw.c b/drivers/net/wireless/=
ath/carl9170/fw.c
index aaebecd..63fd9af 100644
--- a/drivers/net/wireless/ath/carl9170/fw.c
+++ b/drivers/net/wireless/ath/carl9170/fw.c
@@ -336,8 +336,12 @@ static int carl9170_fw(struct ar9170 *ar, const __u8 *=
data, size_t len)
 		if (SUPP(CARL9170FW_WLANTX_CAB)) {
 			if_comb_types |=3D
 				BIT(NL80211_IFTYPE_AP) |
-				BIT(NL80211_IFTYPE_MESH_POINT) |
 				BIT(NL80211_IFTYPE_P2P_GO);
+
+#ifdef CONFIG_MAC80211_MESH
+			if_comb_types |=3D
+				BIT(NL80211_IFTYPE_MESH_POINT);
+#endif /* CONFIG_MAC80211_MESH */
 		}
 	}
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 1261a9b..75464ad 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -3091,10 +3091,11 @@ brcmf_configure_wpaie(struct net_device *ndev, stru=
ct brcmf_vs_tlv *wpa_ie,
=20
 	len =3D wpa_ie->len + TLV_HDR_LEN;
 	data =3D (u8 *)wpa_ie;
-	offset =3D 0;
+	offset =3D TLV_HDR_LEN;
 	if (!is_rsn_ie)
 		offset +=3D VS_IE_FIXED_HDR_LEN;
-	offset +=3D WPA_IE_VERSION_LEN;
+	else
+		offset +=3D WPA_IE_VERSION_LEN;
=20
 	/* check for multicast cipher suite */
 	if (offset + WPA_IE_MIN_OUI_LEN > len) {
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/debug.h b/drivers/net/=
wireless/brcm80211/brcmsmac/debug.h
index 796836b..822781c 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/debug.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/debug.h
@@ -1,5 +1,6 @@
 /*
  * Copyright (c) 2012 Broadcom Corporation
+ * Copyright (c) 2012 Canonical Ltd.
  *
  * Permission to use, copy, modify, and/or distribute this software for any
  * purpose with or without fee is hereby granted, provided that the above
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c b/driver=
s/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
index 606b534..21a8242 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
@@ -1343,13 +1343,13 @@ static bool wlc_lcnphy_rx_iq_cal_gain(struct brcms_=
phy *pi, u16 biq1_gain,
=20
 	wlc_lcnphy_rx_gain_override_enable(pi, true);
 	wlc_lcnphy_start_tx_tone(pi, 2000, (40 >> 1), 0);
-	usleep_range(500, 500);
+	udelay(500);
 	write_radio_reg(pi, RADIO_2064_REG112, 0);
 	if (!wlc_lcnphy_rx_iq_est(pi, 1024, 32, &iq_est_l))
 		return false;
=20
 	wlc_lcnphy_start_tx_tone(pi, 2000, 40, 0);
-	usleep_range(500, 500);
+	udelay(500);
 	write_radio_reg(pi, RADIO_2064_REG112, 0);
 	if (!wlc_lcnphy_rx_iq_est(pi, 1024, 32, &iq_est_h))
 		return false;
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p=
54usb.c
index e71c702..800a165 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -47,6 +47,7 @@ static struct usb_device_id p54u_table[] =3D {
 	{USB_DEVICE(0x0411, 0x0050)},	/* Buffalo WLI2-USB2-G54 */
 	{USB_DEVICE(0x045e, 0x00c2)},	/* Microsoft MN-710 */
 	{USB_DEVICE(0x0506, 0x0a11)},	/* 3COM 3CRWE254G72 */
+	{USB_DEVICE(0x0675, 0x0530)},	/* DrayTek Vigor 530 */
 	{USB_DEVICE(0x06b9, 0x0120)},	/* Thomson SpeedTouch 120g */
 	{USB_DEVICE(0x0707, 0xee06)},	/* SMC 2862W-G */
 	{USB_DEVICE(0x07aa, 0x001c)},	/* Corega CG-WLUSB2GT */
@@ -82,6 +83,8 @@ static struct usb_device_id p54u_table[] =3D {
 	{USB_DEVICE(0x06a9, 0x000e)},	/* Westell 802.11g USB (A90-211WG-01) */
 	{USB_DEVICE(0x06b9, 0x0121)},	/* Thomson SpeedTouch 121g */
 	{USB_DEVICE(0x0707, 0xee13)},   /* SMC 2862W-G version 2 */
+	{USB_DEVICE(0x0803, 0x4310)},	/* Zoom 4410a */
+	{USB_DEVICE(0x083a, 0x4503)},	/* T-Com Sinus 154 data II */
 	{USB_DEVICE(0x083a, 0x4521)},   /* Siemens Gigaset USB Adapter 54 version=
 2 */
 	{USB_DEVICE(0x083a, 0xc501)},	/* Zoom Wireless-G 4410 */
 	{USB_DEVICE(0x083a, 0xf503)},	/* Accton FD7050E ver 1010ec  */
@@ -101,6 +104,7 @@ static struct usb_device_id p54u_table[] =3D {
 	{USB_DEVICE(0x13B1, 0x000C)},	/* Linksys WUSB54AG */
 	{USB_DEVICE(0x1413, 0x5400)},   /* Telsey 802.11g USB2.0 Adapter */
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
+	/* {USB_DEVICE(0x15a9, 0x0002)}, * Also SparkLAN WL-682 with 3887 */
 	{USB_DEVICE(0x1668, 0x1050)},	/* Actiontec 802UIG-1 */
 	{USB_DEVICE(0x1740, 0x1000)},	/* Senao NUB-350 */
 	{USB_DEVICE(0x2001, 0x3704)},	/* DLink DWL-G122 rev A2 */
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 3deacaf..4261e8e 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -743,6 +743,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *=
hw)
=20
 done:
 		bufferaddress =3D (*((dma_addr_t *)skb->cb));
+		if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress))
+			return;
 		tmp_one =3D 1;
 		rtlpriv->cfg->ops->set_desc((u8 *) pdesc, false,
 					    HW_DESC_RXBUFF_ADDR,
@@ -1115,6 +1117,10 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw=
 *hw)
 					   PCI_DMA_FROMDEVICE);
=20
 			bufferaddress =3D (*((dma_addr_t *)skb->cb));
+			if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress)) {
+				dev_kfree_skb_any(skb);
+				return 1;
+			}
 			rtlpriv->cfg->ops->set_desc((u8 *)entry, false,
 						    HW_DESC_RXBUFF_ADDR,
 						    (u8 *)&bufferaddress);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192ce/trx.c
index 1734247..c31795e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -611,8 +611,14 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 	dma_addr_t mapping =3D pci_map_single(rtlpci->pdev,
 					    skb->data, skb->len,
 					    PCI_DMA_TODEVICE);
+
 	u8 bw_40 =3D 0;
=20
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	rcu_read_lock();
 	sta =3D get_sta(hw, mac->vif, mac->bssid);
 	if (mac->opmode =3D=3D NL80211_IFTYPE_STATION) {
@@ -774,6 +780,11 @@ void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)(skb->data);
 	__le16 fc =3D hdr->frame_control;
=20
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
=20
 	if (firstseg)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192de/trx.c
index f9f3861..a0fbf28 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -587,6 +587,11 @@ void rtl92de_tx_fill_desc(struct ieee80211_hw *hw,
 	buf_len =3D skb->len;
 	mapping =3D pci_map_single(rtlpci->pdev, skb->data, skb->len,
 				 PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_92d));
 	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
 		firstseg =3D true;
@@ -740,6 +745,11 @@ void rtl92de_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)(skb->data);
 	__le16 fc =3D hdr->frame_control;
=20
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
 	if (firstseg)
 		SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192se/trx.c
index 0e9f6eb..206561d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -611,6 +611,11 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 		    PCI_DMA_TODEVICE);
 	u8 bw_40 =3D 0;
=20
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	if (mac->opmode =3D=3D NL80211_IFTYPE_STATION) {
 		bw_40 =3D mac->bw_40;
 	} else if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
@@ -763,6 +768,7 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 void rtl92se_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 	bool firstseg, bool lastseg, struct sk_buff *skb)
 {
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
 	struct rtl_tcb_desc *tcb_desc =3D (struct rtl_tcb_desc *)(skb->cb);
@@ -770,7 +776,12 @@ void rtl92se_tx_fill_cmddesc(struct ieee80211_hw *hw, =
u8 *pdesc,
 	dma_addr_t mapping =3D pci_map_single(rtlpci->pdev, skb->data, skb->len,
 			PCI_DMA_TODEVICE);
=20
-    /* Clear all status	*/
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
+	/* Clear all status	*/
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_CMDDESC_SIZE_RTL8192S);
=20
 	/* This bit indicate this packet is used for FW download. */
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8723ae/trx.c
index 87331d8..a313be8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -387,6 +387,11 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 					    PCI_DMA_TODEVICE);
 	u8 bw_40 =3D 0;
=20
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	if (mac->opmode =3D=3D NL80211_IFTYPE_STATION) {
 		bw_40 =3D mac->bw_40;
 	} else if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
@@ -542,6 +547,11 @@ void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
 					    PCI_DMA_TODEVICE);
 	__le16 fc =3D hdr->frame_control;
=20
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
=20
 	if (firstseg)
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index 29f0969..f2ecdeb 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -210,17 +210,16 @@ static void _usb_writeN_sync(struct rtl_priv *rtlpriv=
, u32 addr, void *data,
 	u16 index =3D REALTEK_USB_VENQT_CMD_IDX;
 	int pipe =3D usb_sndctrlpipe(udev, 0); /* write_out */
 	u8 *buffer;
-	dma_addr_t dma_addr;
=20
-	wvalue =3D (u16)(addr&0x0000ffff);
-	buffer =3D usb_alloc_coherent(udev, (size_t)len, GFP_ATOMIC, &dma_addr);
+	wvalue =3D (u16)(addr & 0x0000ffff);
+	buffer =3D kmalloc(len, GFP_ATOMIC);
 	if (!buffer)
 		return;
 	memcpy(buffer, data, len);
 	usb_control_msg(udev, pipe, request, reqtype, wvalue,
 			index, buffer, len, 50);
=20
-	usb_free_coherent(udev, (size_t)len, buffer, dma_addr);
+	kfree(buffer);
 }
=20
 static void _rtl_usb_io_handler_init(struct device *dev,
@@ -640,6 +639,7 @@ static int _rtl_usb_receive(struct ieee80211_hw *hw)
 			RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
 				 "Failed to prep_rx_urb!!\n");
 			err =3D PTR_ERR(skb);
+			usb_free_urb(urb);
 			goto err_out;
 		}
=20
diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index ff3c8a2..5d6f2ec 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -162,8 +162,7 @@ config SSB_DRIVER_GIGE
=20
 config SSB_DRIVER_GPIO
 	bool "SSB GPIO driver"
-	depends on SSB
-	select GPIOLIB
+	depends on SSB && GPIOLIB
 	help
 	  Driver to provide access to the GPIO pins on the bus.
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--BOKacYhQ+x31HxR3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ50FWAAoJEJctW/TcYTgGENsP/A7a06JySH6WFTmxbWh1c8si
rAMSXhwB1CfS3f4Q780LMtwK0CnhBEwWxpimd4ZoEg+prZK1jmxJNztveUIgnK23
9vanOMwKOGUAPu0ddeHdeqKyuGlaHjitH5vfu/J3arDTZ4dpQxXyp53tUqr75H/5
N3/hm5xUxdDpmfH4AzVWyN88lsqgobGodPoFC8RhvKxzrVQBQiVwaGae6enJLlWN
WNGxN40YXPR1o8rP1YzxDt6pJ5+NiGwSF71yyapQqueYQyQ9EDqI8JP/CgPpEWol
UfIQJsNVXs3T2xjScmOjABBXA06RaVeFdiLP5kR2NE8fiNF13JF77pERnRRtzSk0
OkDoO4k0kyrbom/IPmU7nfHxaZrBY0sMWuoFIZheVjNyRsAfIC/Ric8zY3m0ViW+
SlR5p1eWP986M32hJoDckjMO/JcGIqPnhKjgjQZ02pbzBYL7qPeSmuKutM/8ndlg
2OqMOhYMs20pYMYQ75aC9eHSq6Z4V1qsCH5h3atye02f2E0LcUcyypbwdGVusy86
idZUw7HjQP06lpUtgSCaTskqwgqynLgS+hppgvmYLPi9LETSfOPWAtFydHdNsink
jmFoKOngWaAZ3qHBVHXcSBWmpLhQvCdJZm3z4viPhZEZ4L8CtHpPyiT53oXS+1cV
uY+L68/1cvmUSH354Inf
=yYgS
-----END PGP SIGNATURE-----

--BOKacYhQ+x31HxR3--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
