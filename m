From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-08-01
Date: Thu, 1 Aug 2013 15:01:44 -0400
Message-ID: <20130801190144.GC13922@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CE+1k2dSO48ffgeK"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This pull request is intended for the 3.11 stream.  It is a bit
larger than usual, as it includes pulls from most of my feeder trees
as well...

For the Bluetooth bits, Gustavo says:

"A few fixes and devices ID additions for 3.11:

 * There are 4 new ath3k device ids
 * Fixed stack memory usage in ath3k.
 * Fixed the init process of BlueFRITZ! devices, they were failing to init
   due to an unsupported command we sent.
 * Fixed wrong use of PTR_ERR in btusb code that was preventing intel devic=
es
   to work properly.
 * Fixed race condition between hci_register_dev() and hci_dev_open() that
   could cause a NULL pointer dereference.
 * Fixed race condition that could call hci_req_cmd_complete() and make some
   devices to fail as showed in the log added to the commit message."

Regarding the NFC bits, Samuel says:

"We have:

1) A build failure fix for the NCI SPI transport layer due to a
   missing CRC_CCITT Kconfig dependency.

2) A netlink command rename: CMD_FW_UPLOAD was merged during the 3.11
   merge window but the typical terminology for loading a firmware to a
   target is firmware download rather than upload. In order to avoid any
   confusion in a file exported to userspace, we rename this command to
   CMD_FW_DOWNLOAD."

Samuel's item #2 isn't strictly a fix, but it seems safe and should
avoid confusion in the future.

As for the mac80211 bits, Johannes says:

"I only have three fixes this time, a fix for a suspend regression, a
patch correcting the initiator in regulatory code and one fix for mesh
station powersave."

With respect to the iwlwifi bits, Johannes says:

"We have a scan fix for passive channels, a new PCI device ID for an old
device, a NIC reset fix, an RF-Kill fix, a fix for powersave when GO
interfaces are present as well as an aggregation session fix (for a
corner case) and a workaround for a firmware design issue - it only
supports a single GTK in D3."

Bringing-up the rear with the Atheros trees, Kalle says:

"Geert Uytterhoeven fixed an ath10k build problem when NO_DMA=3Dy. I added
a missing MAINTAINERS entry for ath10k and updated ath6kl git tree
location."

Along with the above...

Arend van Spriel fixes a brcmfmac WARNING when unplugging the device.

Avinash Patil proves a couple of minor mwifiex fixes relating to P2P mode.

Luciano Coelho updates the MAINTAINERS entry for the wilink drivers.

Stanislaw Gruszka brings an rt2x00 fix for a queue start/stop problem.

Stone Piao fixes another mwifiex problem, a command timeout related to P2P =
mode.

Tomasz Mo=C5=84 corrects an endian problem in mwifiex.

I'll remind my feeder maintainers to slowdown the patchflow.
Beyond that, please let me know if there are problems!

Thanks,

John

---

The following changes since commit b00589af3b04736376f24625ab0b394642e89e29:

  bridge: disable snooping if there is no querier (2013-07-31 17:40:21 -070=
0)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 22e02a0272e5291a40ca28d2b7aea5231c832077:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-08-01 14:30:59 -0400)

----------------------------------------------------------------

AceLan Kao (2):
      Bluetooth: Add support for Atheros [0cf3:3121]
      Bluetooth: Add support for Atheros [0cf3:e003]

Adam Lee (1):
      Bluetooth: fix wrong use of PTR_ERR() in btusb

Arend van Spriel (1):
      brcmfmac: inform cfg80211 about disconnect when device is unplugged

Arik Nemtsov (1):
      regulatory: use correct regulatory initiator on wiphy register

Avinash Patil (2):
      mwifiex: check for bss_role instead of bss_mode for STA operations
      mwifiex: fix wrong data rates in P2P client

Chun-Yeow Yeoh (1):
      mac80211: prevent the buffering or frame transmission to non-assoc me=
sh STA

David Spinadel (1):
      iwlwifi: mvm: set SSID bits for passive channels

Emmanuel Grumbach (3):
      iwlwifi: add DELL SKU for 5150 HMC
      iwlwifi: pcie: reset the NIC before the bring up
      iwlwifi: pcie: clear RFKILL interrupt in AMPG

Frederic Danis (1):
      NFC: Fix NCI over SPI build

Geert Uytterhoeven (1):
      ath10k: ATH10K should depend on HAS_DMA

Gustavo Padovan (1):
      Bluetooth: Fix race between hci_register_dev() and hci_dev_open()

Ilan Peer (1):
      iwlwifi: mvm: Disable managed PS when GO is added

Jaganath Kanakkassery (1):
      Bluetooth: Fix invalid length check in l2cap_information_rsp()

Johan Hedberg (2):
      Bluetooth: Fix HCI init for BlueFRITZ! devices
      Bluetooth: Fix calling request callback more than once

Johannes Berg (2):
      iwlwifi: mvm: use only a single GTK in D3
      iwlwifi: mvm: fix flushing not started aggregation sessions

John W. Linville (6):
      Merge branch 'for-linville-current' of git://github.com/kvalo/ath
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge tag 'nfc-fixes-3.11-2' of git://git.kernel.org/.../sameo/nfc-fi=
xes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Kalle Valo (2):
      MAINTAINERS: add ath10k
      MAINTAINERS: update ath6kl git location

Luciano Coelho (1):
      MAINTAINERS: change email of TI WiLink drivers' maintainer

Samuel Ortiz (1):
      NFC: netlink: Rename CMD_FW_UPLOAD to CMD_FW_DOWNLOAD

Stanislaw Gruszka (3):
      mac80211: fix monitor interface suspend crash regression
      Bluetooth: ath3k: don't use stack memory for DMA
      rt2x00: fix stop queue

Stone Piao (1):
      mwifiex: fix command 0x2c timeout during p2p_find or p2p_connect

Sujith Manoharan (1):
      Bluetooth: ath3k: Add support for ID 0x13d3/0x3402

Thomas Loo (1):
      Bluetooth: ath3k: Add support for Fujitsu Lifebook UH5x2 [04c5:1330]

Tomasz Mo=C5=84 (1):
      mwifiex: Add missing endian conversion.

 MAINTAINERS                                        | 12 +++++-
 drivers/bluetooth/ath3k.c                          | 46 +++++++++++++++++-=
----
 drivers/bluetooth/btusb.c                          | 18 +++++----
 drivers/net/wireless/ath/ath10k/Kconfig            |  2 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  5 ++-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |  2 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              | 15 ++++---
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  1 -
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        | 42 ++++++++++--------=
--
 drivers/net/wireless/iwlwifi/mvm/scan.c            | 11 +-----
 drivers/net/wireless/iwlwifi/mvm/sta.c             | 11 ++++--
 drivers/net/wireless/iwlwifi/pcie/drv.c            |  1 +
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  8 ++++
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  5 +++
 drivers/net/wireless/mwifiex/cfg80211.c            |  4 +-
 drivers/net/wireless/mwifiex/cfp.c                 |  3 +-
 drivers/net/wireless/mwifiex/join.c                |  6 ++-
 drivers/net/wireless/mwifiex/sdio.c                |  4 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          | 18 +++++----
 include/net/nfc/hci.h                              |  2 +-
 include/net/nfc/nfc.h                              |  4 +-
 include/uapi/linux/nfc.h                           |  6 +--
 net/bluetooth/hci_core.c                           | 26 +++++++-----
 net/mac80211/mesh_ps.c                             |  4 ++
 net/mac80211/pm.c                                  |  7 +++-
 net/nfc/core.c                                     | 20 +++++-----
 net/nfc/hci/core.c                                 |  8 ++--
 net/nfc/nci/Kconfig                                |  1 +
 net/nfc/netlink.c                                  | 12 +++---
 net/nfc/nfc.h                                      |  6 +--
 net/wireless/reg.c                                 |  5 ++-
 32 files changed, 203 insertions(+), 116 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index a26b10e..77be3f4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1406,7 +1406,7 @@ ATHEROS ATH6KL WIRELESS DRIVER
 M:	Kalle Valo <kvalo@qca.qualcomm.com>
 L:	linux-wireless@vger.kernel.org
 W:	http://wireless.kernel.org/en/users/Drivers/ath6kl
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath6kl.git
+T:	git git://github.com/kvalo/ath.git
 S:	Supported
 F:	drivers/net/wireless/ath/ath6kl/
=20
@@ -6726,6 +6726,14 @@ T:	git git://linuxtv.org/anttip/media_tree.git
 S:	Maintained
 F:	drivers/media/tuners/qt1010*
=20
+QUALCOMM ATHEROS ATH10K WIRELESS DRIVER
+M:	Kalle Valo <kvalo@qca.qualcomm.com>
+L:	ath10k@lists.infradead.org
+W:	http://wireless.kernel.org/en/users/Drivers/ath10k
+T:	git git://github.com/kvalo/ath.git
+S:	Supported
+F:	drivers/net/wireless/ath/ath10k/
+
 QUALCOMM HEXAGON ARCHITECTURE
 M:	Richard Kuo <rkuo@codeaurora.org>
 L:	linux-hexagon@vger.kernel.org
@@ -8270,7 +8278,7 @@ S:	Maintained
 F:	sound/soc/codecs/twl4030*
=20
 TI WILINK WIRELESS DRIVERS
-M:	Luciano Coelho <coelho@ti.com>
+M:	Luciano Coelho <luca@coelho.fi>
 L:	linux-wireless@vger.kernel.org
 W:	http://wireless.kernel.org/en/users/Drivers/wl12xx
 W:	http://wireless.kernel.org/en/users/Drivers/wl1251
diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 11f467c..a12b923 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -91,6 +91,10 @@ static struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x0489, 0xe04e) },
 	{ USB_DEVICE(0x0489, 0xe056) },
 	{ USB_DEVICE(0x0489, 0xe04d) },
+	{ USB_DEVICE(0x04c5, 0x1330) },
+	{ USB_DEVICE(0x13d3, 0x3402) },
+	{ USB_DEVICE(0x0cf3, 0x3121) },
+	{ USB_DEVICE(0x0cf3, 0xe003) },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE02C) },
@@ -128,6 +132,10 @@ static struct usb_device_id ath3k_blist_tbl[] =3D {
 	{ USB_DEVICE(0x0489, 0xe04e), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe056), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe04d), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04c5, 0x1330), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x13d3, 0x3402), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0x3121), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0xe003), .driver_info =3D BTUSB_ATH3012 },
=20
 	/* Atheros AR5BBU22 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE03C), .driver_info =3D BTUSB_ATH3012 },
@@ -193,24 +201,44 @@ error:
=20
 static int ath3k_get_state(struct usb_device *udev, unsigned char *state)
 {
-	int pipe =3D 0;
+	int ret, pipe =3D 0;
+	char *buf;
+
+	buf =3D kmalloc(sizeof(*buf), GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
=20
 	pipe =3D usb_rcvctrlpipe(udev, 0);
-	return usb_control_msg(udev, pipe, ATH3K_GETSTATE,
-			USB_TYPE_VENDOR | USB_DIR_IN, 0, 0,
-			state, 0x01, USB_CTRL_SET_TIMEOUT);
+	ret =3D usb_control_msg(udev, pipe, ATH3K_GETSTATE,
+			      USB_TYPE_VENDOR | USB_DIR_IN, 0, 0,
+			      buf, sizeof(*buf), USB_CTRL_SET_TIMEOUT);
+
+	*state =3D *buf;
+	kfree(buf);
+
+	return ret;
 }
=20
 static int ath3k_get_version(struct usb_device *udev,
 			struct ath3k_version *version)
 {
-	int pipe =3D 0;
+	int ret, pipe =3D 0;
+	struct ath3k_version *buf;
+	const int size =3D sizeof(*buf);
+
+	buf =3D kmalloc(size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
=20
 	pipe =3D usb_rcvctrlpipe(udev, 0);
-	return usb_control_msg(udev, pipe, ATH3K_GETVERSION,
-			USB_TYPE_VENDOR | USB_DIR_IN, 0, 0, version,
-			sizeof(struct ath3k_version),
-			USB_CTRL_SET_TIMEOUT);
+	ret =3D usb_control_msg(udev, pipe, ATH3K_GETVERSION,
+			      USB_TYPE_VENDOR | USB_DIR_IN, 0, 0,
+			      buf, size, USB_CTRL_SET_TIMEOUT);
+
+	memcpy(version, buf, size);
+	kfree(buf);
+
+	return ret;
 }
=20
 static int ath3k_load_fwfile(struct usb_device *udev,
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index de4cf4d..8e16f0a 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -154,6 +154,10 @@ static struct usb_device_id blacklist_table[] =3D {
 	{ USB_DEVICE(0x0489, 0xe04e), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe056), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe04d), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04c5, 0x1330), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x13d3, 0x3402), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0x3121), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0xe003), .driver_info =3D BTUSB_ATH3012 },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xe02c), .driver_info =3D BTUSB_IGNORE },
@@ -1095,7 +1099,7 @@ static int btusb_setup_intel_patching(struct hci_dev =
*hdev,
 	if (IS_ERR(skb)) {
 		BT_ERR("%s sending Intel patch command (0x%4.4x) failed (%ld)",
 		       hdev->name, cmd->opcode, PTR_ERR(skb));
-		return -PTR_ERR(skb);
+		return PTR_ERR(skb);
 	}
=20
 	/* It ensures that the returned event matches the event data read from
@@ -1147,7 +1151,7 @@ static int btusb_setup_intel(struct hci_dev *hdev)
 	if (IS_ERR(skb)) {
 		BT_ERR("%s sending initial HCI reset command failed (%ld)",
 		       hdev->name, PTR_ERR(skb));
-		return -PTR_ERR(skb);
+		return PTR_ERR(skb);
 	}
 	kfree_skb(skb);
=20
@@ -1161,7 +1165,7 @@ static int btusb_setup_intel(struct hci_dev *hdev)
 	if (IS_ERR(skb)) {
 		BT_ERR("%s reading Intel fw version command failed (%ld)",
 		       hdev->name, PTR_ERR(skb));
-		return -PTR_ERR(skb);
+		return PTR_ERR(skb);
 	}
=20
 	if (skb->len !=3D sizeof(*ver)) {
@@ -1219,7 +1223,7 @@ static int btusb_setup_intel(struct hci_dev *hdev)
 		BT_ERR("%s entering Intel manufacturer mode failed (%ld)",
 		       hdev->name, PTR_ERR(skb));
 		release_firmware(fw);
-		return -PTR_ERR(skb);
+		return PTR_ERR(skb);
 	}
=20
 	if (skb->data[0]) {
@@ -1276,7 +1280,7 @@ static int btusb_setup_intel(struct hci_dev *hdev)
 	if (IS_ERR(skb)) {
 		BT_ERR("%s exiting Intel manufacturer mode failed (%ld)",
 		       hdev->name, PTR_ERR(skb));
-		return -PTR_ERR(skb);
+		return PTR_ERR(skb);
 	}
 	kfree_skb(skb);
=20
@@ -1292,7 +1296,7 @@ exit_mfg_disable:
 	if (IS_ERR(skb)) {
 		BT_ERR("%s exiting Intel manufacturer mode failed (%ld)",
 		       hdev->name, PTR_ERR(skb));
-		return -PTR_ERR(skb);
+		return PTR_ERR(skb);
 	}
 	kfree_skb(skb);
=20
@@ -1310,7 +1314,7 @@ exit_mfg_deactivate:
 	if (IS_ERR(skb)) {
 		BT_ERR("%s exiting Intel manufacturer mode failed (%ld)",
 		       hdev->name, PTR_ERR(skb));
-		return -PTR_ERR(skb);
+		return PTR_ERR(skb);
 	}
 	kfree_skb(skb);
=20
diff --git a/drivers/net/wireless/ath/ath10k/Kconfig b/drivers/net/wireless=
/ath/ath10k/Kconfig
index cde58fe..82e8088 100644
--- a/drivers/net/wireless/ath/ath10k/Kconfig
+++ b/drivers/net/wireless/ath/ath10k/Kconfig
@@ -1,6 +1,6 @@
 config ATH10K
         tristate "Atheros 802.11ac wireless cards support"
-        depends on MAC80211
+        depends on MAC80211 && HAS_DMA
 	select ATH_COMMON
         ---help---
           This module adds support for wireless adapters based on
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 277b37a..7fa71f7 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -1093,8 +1093,11 @@ static void brcmf_link_down(struct brcmf_cfg80211_vi=
f *vif)
 		brcmf_dbg(INFO, "Call WLC_DISASSOC to stop excess roaming\n ");
 		err =3D brcmf_fil_cmd_data_set(vif->ifp,
 					     BRCMF_C_DISASSOC, NULL, 0);
-		if (err)
+		if (err) {
 			brcmf_err("WLC_DISASSOC failed (%d)\n", err);
+			cfg80211_disconnected(vif->wdev.netdev, 0,
+					      NULL, 0, GFP_KERNEL);
+		}
 		clear_bit(BRCMF_VIF_STATUS_CONNECTED, &vif->sme_state);
 	}
 	clear_bit(BRCMF_VIF_STATUS_CONNECTING, &vif->sme_state);
diff --git a/drivers/net/wireless/iwlwifi/iwl-prph.h b/drivers/net/wireless=
/iwlwifi/iwl-prph.h
index ff8cc75..a70c7b9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-prph.h
+++ b/drivers/net/wireless/iwlwifi/iwl-prph.h
@@ -97,6 +97,8 @@
=20
 #define APMG_PCIDEV_STT_VAL_L1_ACT_DIS		(0x00000800)
=20
+#define APMG_RTC_INT_STT_RFKILL		(0x10000000)
+
 /* Device system time */
 #define DEVICE_SYSTEM_TIME_REG 0xA0206C
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/d3.c b/drivers/net/wireless/i=
wlwifi/mvm/d3.c
index 7e5e5c2..83da884 100644
--- a/drivers/net/wireless/iwlwifi/mvm/d3.c
+++ b/drivers/net/wireless/iwlwifi/mvm/d3.c
@@ -134,7 +134,7 @@ struct wowlan_key_data {
 	struct iwl_wowlan_rsc_tsc_params_cmd *rsc_tsc;
 	struct iwl_wowlan_tkip_params_cmd *tkip;
 	bool error, use_rsc_tsc, use_tkip;
-	int gtk_key_idx;
+	int wep_key_idx;
 };
=20
 static void iwl_mvm_wowlan_program_keys(struct ieee80211_hw *hw,
@@ -188,8 +188,8 @@ static void iwl_mvm_wowlan_program_keys(struct ieee8021=
1_hw *hw,
 			wkc.wep_key.key_offset =3D 0;
 		} else {
 			/* others start at 1 */
-			data->gtk_key_idx++;
-			wkc.wep_key.key_offset =3D data->gtk_key_idx;
+			data->wep_key_idx++;
+			wkc.wep_key.key_offset =3D data->wep_key_idx;
 		}
=20
 		ret =3D iwl_mvm_send_cmd_pdu(mvm, WEP_KEY, CMD_SYNC,
@@ -316,8 +316,13 @@ static void iwl_mvm_wowlan_program_keys(struct ieee802=
11_hw *hw,
 		mvm->ptk_ivlen =3D key->iv_len;
 		mvm->ptk_icvlen =3D key->icv_len;
 	} else {
-		data->gtk_key_idx++;
-		key->hw_key_idx =3D data->gtk_key_idx;
+		/*
+		 * firmware only supports TSC/RSC for a single key,
+		 * so if there are multiple keep overwriting them
+		 * with new ones -- this relies on mac80211 doing
+		 * list_add_tail().
+		 */
+		key->hw_key_idx =3D 1;
 		mvm->gtk_ivlen =3D key->iv_len;
 		mvm->gtk_icvlen =3D key->icv_len;
 	}
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h b/drivers/net/w=
ireless/iwlwifi/mvm/fw-api-scan.h
index b60d141..365095a 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
@@ -69,7 +69,6 @@
 /* Scan Commands, Responses, Notifications */
=20
 /* Masks for iwl_scan_channel.type flags */
-#define SCAN_CHANNEL_TYPE_PASSIVE	0
 #define SCAN_CHANNEL_TYPE_ACTIVE	BIT(0)
 #define SCAN_CHANNEL_NARROW_BAND	BIT(22)
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 1eedc42..f19baf0 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -512,6 +512,27 @@ static int iwl_mvm_mac_add_interface(struct ieee80211_=
hw *hw,
 		goto out_unlock;
=20
 	/*
+	 * TODO: remove this temporary code.
+	 * Currently MVM FW supports power management only on single MAC.
+	 * If new interface added, disable PM on existing interface.
+	 * P2P device is a special case, since it is handled by FW similary to
+	 * scan. If P2P deviced is added, PM remains enabled on existing
+	 * interface.
+	 * Note: the method below does not count the new interface being added
+	 * at this moment.
+	 */
+	if (vif->type !=3D NL80211_IFTYPE_P2P_DEVICE)
+		mvm->vif_count++;
+	if (mvm->vif_count > 1) {
+		IWL_DEBUG_MAC80211(mvm,
+				   "Disable power on existing interfaces\n");
+		ieee80211_iterate_active_interfaces_atomic(
+					    mvm->hw,
+					    IEEE80211_IFACE_ITER_NORMAL,
+					    iwl_mvm_pm_disable_iterator, mvm);
+	}
+
+	/*
 	 * The AP binding flow can be done only after the beacon
 	 * template is configured (which happens only in the mac80211
 	 * start_ap() flow), and adding the broadcast station can happen
@@ -534,27 +555,6 @@ static int iwl_mvm_mac_add_interface(struct ieee80211_=
hw *hw,
 		goto out_unlock;
 	}
=20
-	/*
-	 * TODO: remove this temporary code.
-	 * Currently MVM FW supports power management only on single MAC.
-	 * If new interface added, disable PM on existing interface.
-	 * P2P device is a special case, since it is handled by FW similary to
-	 * scan. If P2P deviced is added, PM remains enabled on existing
-	 * interface.
-	 * Note: the method below does not count the new interface being added
-	 * at this moment.
-	 */
-	if (vif->type !=3D NL80211_IFTYPE_P2P_DEVICE)
-		mvm->vif_count++;
-	if (mvm->vif_count > 1) {
-		IWL_DEBUG_MAC80211(mvm,
-				   "Disable power on existing interfaces\n");
-		ieee80211_iterate_active_interfaces_atomic(
-					    mvm->hw,
-					    IEEE80211_IFACE_ITER_NORMAL,
-					    iwl_mvm_pm_disable_iterator, mvm);
-	}
-
 	ret =3D iwl_mvm_mac_ctxt_add(mvm, vif);
 	if (ret)
 		goto out_release;
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index 268f027..acdff6b 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -178,19 +178,12 @@ static void iwl_mvm_scan_fill_channels(struct iwl_sca=
n_cmd *cmd,
 	struct iwl_scan_channel *chan =3D (struct iwl_scan_channel *)
 		(cmd->data + le16_to_cpu(cmd->tx_cmd.len));
 	int i;
-	__le32 chan_type_value;
-
-	if (req->n_ssids > 0)
-		chan_type_value =3D cpu_to_le32(BIT(req->n_ssids) - 1);
-	else
-		chan_type_value =3D SCAN_CHANNEL_TYPE_PASSIVE;
=20
 	for (i =3D 0; i < cmd->channel_count; i++) {
 		chan->channel =3D cpu_to_le16(req->channels[i]->hw_value);
+		chan->type =3D cpu_to_le32(BIT(req->n_ssids) - 1);
 		if (req->channels[i]->flags & IEEE80211_CHAN_PASSIVE_SCAN)
-			chan->type =3D SCAN_CHANNEL_TYPE_PASSIVE;
-		else
-			chan->type =3D chan_type_value;
+			chan->type &=3D cpu_to_le32(~SCAN_CHANNEL_TYPE_ACTIVE);
 		chan->active_dwell =3D cpu_to_le16(active_dwell);
 		chan->passive_dwell =3D cpu_to_le16(passive_dwell);
 		chan->iteration_count =3D cpu_to_le16(1);
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/=
iwlwifi/mvm/sta.c
index 85d4bbe..563f559 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -915,6 +915,7 @@ int iwl_mvm_sta_tx_agg_flush(struct iwl_mvm *mvm, struc=
t ieee80211_vif *vif,
 	struct iwl_mvm_sta *mvmsta =3D (void *)sta->drv_priv;
 	struct iwl_mvm_tid_data *tid_data =3D &mvmsta->tid_data[tid];
 	u16 txq_id;
+	enum iwl_mvm_agg_state old_state;
=20
 	/*
 	 * First set the agg state to OFF to avoid calling
@@ -924,13 +925,17 @@ int iwl_mvm_sta_tx_agg_flush(struct iwl_mvm *mvm, str=
uct ieee80211_vif *vif,
 	txq_id =3D tid_data->txq_id;
 	IWL_DEBUG_TX_QUEUES(mvm, "Flush AGG: sta %d tid %d q %d state %d\n",
 			    mvmsta->sta_id, tid, txq_id, tid_data->state);
+	old_state =3D tid_data->state;
 	tid_data->state =3D IWL_AGG_OFF;
 	spin_unlock_bh(&mvmsta->lock);
=20
-	if (iwl_mvm_flush_tx_path(mvm, BIT(txq_id), true))
-		IWL_ERR(mvm, "Couldn't flush the AGG queue\n");
+	if (old_state >=3D IWL_AGG_ON) {
+		if (iwl_mvm_flush_tx_path(mvm, BIT(txq_id), true))
+			IWL_ERR(mvm, "Couldn't flush the AGG queue\n");
+
+		iwl_trans_txq_disable(mvm->trans, tid_data->txq_id);
+	}
=20
-	iwl_trans_txq_disable(mvm->trans, tid_data->txq_id);
 	mvm->queue_to_mac80211[tid_data->txq_id] =3D
 				IWL_INVALID_MAC80211_QUEUE;
=20
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index 81f3ea5..ff13458 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -130,6 +130,7 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 	{IWL_PCI_DEVICE(0x423C, 0x1306, iwl5150_abg_cfg)}, /* Half Mini Card */
 	{IWL_PCI_DEVICE(0x423C, 0x1221, iwl5150_agn_cfg)}, /* Mini Card */
 	{IWL_PCI_DEVICE(0x423C, 0x1321, iwl5150_agn_cfg)}, /* Half Mini Card */
+	{IWL_PCI_DEVICE(0x423C, 0x1326, iwl5150_abg_cfg)}, /* Half Mini Card */
=20
 	{IWL_PCI_DEVICE(0x423D, 0x1211, iwl5150_agn_cfg)}, /* Mini Card */
 	{IWL_PCI_DEVICE(0x423D, 0x1311, iwl5150_agn_cfg)}, /* Half Mini Card */
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/=
iwlwifi/pcie/rx.c
index fd848cd..f600e68 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -888,6 +888,14 @@ irqreturn_t iwl_pcie_irq_handler(int irq, void *dev_id)
=20
 		iwl_op_mode_hw_rf_kill(trans->op_mode, hw_rfkill);
 		if (hw_rfkill) {
+			/*
+			 * Clear the interrupt in APMG if the NIC is going down.
+			 * Note that when the NIC exits RFkill (else branch), we
+			 * can't access prph and the NIC will be reset in
+			 * start_hw anyway.
+			 */
+			iwl_write_prph(trans, APMG_RTC_INT_STT_REG,
+				       APMG_RTC_INT_STT_RFKILL);
 			set_bit(STATUS_RFKILL, &trans_pcie->status);
 			if (test_and_clear_bit(STATUS_HCMD_ACTIVE,
 					       &trans_pcie->status))
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 826c156..96cfcdd 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -670,6 +670,11 @@ static int iwl_trans_pcie_start_hw(struct iwl_trans *t=
rans)
 		return err;
 	}
=20
+	/* Reset the entire device */
+	iwl_set_bit(trans, CSR_RESET, CSR_RESET_REG_FLAG_SW_RESET);
+
+	usleep_range(10, 15);
+
 	iwl_pcie_apm_init(trans);
=20
 	/* From now on, the op_mode will be kept updated about RF kill state */
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index ef5fa89..89459db 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1716,9 +1716,9 @@ mwifiex_cfg80211_connect(struct wiphy *wiphy, struct =
net_device *dev,
 	struct mwifiex_private *priv =3D mwifiex_netdev_get_priv(dev);
 	int ret;
=20
-	if (priv->bss_mode !=3D NL80211_IFTYPE_STATION) {
+	if (GET_BSS_ROLE(priv) !=3D MWIFIEX_BSS_ROLE_STA) {
 		wiphy_err(wiphy,
-			  "%s: reject infra assoc request in non-STA mode\n",
+			  "%s: reject infra assoc request in non-STA role\n",
 			  dev->name);
 		return -EINVAL;
 	}
diff --git a/drivers/net/wireless/mwifiex/cfp.c b/drivers/net/wireless/mwif=
iex/cfp.c
index 988552d..5178c46 100644
--- a/drivers/net/wireless/mwifiex/cfp.c
+++ b/drivers/net/wireless/mwifiex/cfp.c
@@ -415,7 +415,8 @@ u32 mwifiex_get_supported_rates(struct mwifiex_private =
*priv, u8 *rates)
 	u32 k =3D 0;
 	struct mwifiex_adapter *adapter =3D priv->adapter;
=20
-	if (priv->bss_mode =3D=3D NL80211_IFTYPE_STATION) {
+	if (priv->bss_mode =3D=3D NL80211_IFTYPE_STATION ||
+	    priv->bss_mode =3D=3D NL80211_IFTYPE_P2P_CLIENT) {
 		switch (adapter->config_bands) {
 		case BAND_B:
 			dev_dbg(adapter->dev, "info: infra band=3D%d "
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwi=
fiex/join.c
index 1c8a771..12e7781 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -1291,8 +1291,10 @@ int mwifiex_associate(struct mwifiex_private *priv,
 {
 	u8 current_bssid[ETH_ALEN];
=20
-	/* Return error if the adapter or table entry is not marked as infra */
-	if ((priv->bss_mode !=3D NL80211_IFTYPE_STATION) ||
+	/* Return error if the adapter is not STA role or table entry
+	 * is not marked as infra.
+	 */
+	if ((GET_BSS_ROLE(priv) !=3D MWIFIEX_BSS_ROLE_STA) ||
 	    (bss_desc->bss_mode !=3D NL80211_IFTYPE_STATION))
 		return -1;
=20
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwi=
fiex/sdio.c
index 5ef49f2..09185c9 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -1639,8 +1639,8 @@ static int mwifiex_sdio_host_to_card(struct mwifiex_a=
dapter *adapter,
 	/* Allocate buffer and copy payload */
 	blk_size =3D MWIFIEX_SDIO_BLOCK_SIZE;
 	buf_block_len =3D (pkt_len + blk_size - 1) / blk_size;
-	*(u16 *) &payload[0] =3D (u16) pkt_len;
-	*(u16 *) &payload[2] =3D type;
+	*(__le16 *)&payload[0] =3D cpu_to_le16((u16)pkt_len);
+	*(__le16 *)&payload[2] =3D cpu_to_le16(type);
=20
 	/*
 	 * This is SDIO specific header
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index 206c3e0..8af97ab 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -257,10 +257,10 @@ int mwifiex_bss_start(struct mwifiex_private *priv, s=
truct cfg80211_bss *bss,
 			goto done;
 	}
=20
-	if (priv->bss_mode =3D=3D NL80211_IFTYPE_STATION) {
+	if (priv->bss_mode =3D=3D NL80211_IFTYPE_STATION ||
+	    priv->bss_mode =3D=3D NL80211_IFTYPE_P2P_CLIENT) {
 		u8 config_bands;
=20
-		/* Infra mode */
 		ret =3D mwifiex_deauthenticate(priv, NULL);
 		if (ret)
 			goto done;
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wirele=
ss/rt2x00/rt2x00queue.c
index 6c0a91f..aa95c6c 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -936,13 +936,8 @@ void rt2x00queue_index_inc(struct queue_entry *entry, =
enum queue_index index)
 	spin_unlock_irqrestore(&queue->index_lock, irqflags);
 }
=20
-void rt2x00queue_pause_queue(struct data_queue *queue)
+void rt2x00queue_pause_queue_nocheck(struct data_queue *queue)
 {
-	if (!test_bit(DEVICE_STATE_PRESENT, &queue->rt2x00dev->flags) ||
-	    !test_bit(QUEUE_STARTED, &queue->flags) ||
-	    test_and_set_bit(QUEUE_PAUSED, &queue->flags))
-		return;
-
 	switch (queue->qid) {
 	case QID_AC_VO:
 	case QID_AC_VI:
@@ -958,6 +953,15 @@ void rt2x00queue_pause_queue(struct data_queue *queue)
 		break;
 	}
 }
+void rt2x00queue_pause_queue(struct data_queue *queue)
+{
+	if (!test_bit(DEVICE_STATE_PRESENT, &queue->rt2x00dev->flags) ||
+	    !test_bit(QUEUE_STARTED, &queue->flags) ||
+	    test_and_set_bit(QUEUE_PAUSED, &queue->flags))
+		return;
+
+	rt2x00queue_pause_queue_nocheck(queue);
+}
 EXPORT_SYMBOL_GPL(rt2x00queue_pause_queue);
=20
 void rt2x00queue_unpause_queue(struct data_queue *queue)
@@ -1019,7 +1023,7 @@ void rt2x00queue_stop_queue(struct data_queue *queue)
 		return;
 	}
=20
-	rt2x00queue_pause_queue(queue);
+	rt2x00queue_pause_queue_nocheck(queue);
=20
 	queue->rt2x00dev->ops->lib->stop_queue(queue);
=20
diff --git a/include/net/nfc/hci.h b/include/net/nfc/hci.h
index 0af851c..b64b7bc 100644
--- a/include/net/nfc/hci.h
+++ b/include/net/nfc/hci.h
@@ -59,7 +59,7 @@ struct nfc_hci_ops {
 			      struct nfc_target *target);
 	int (*event_received)(struct nfc_hci_dev *hdev, u8 gate, u8 event,
 			      struct sk_buff *skb);
-	int (*fw_upload)(struct nfc_hci_dev *hdev, const char *firmware_name);
+	int (*fw_download)(struct nfc_hci_dev *hdev, const char *firmware_name);
 	int (*discover_se)(struct nfc_hci_dev *dev);
 	int (*enable_se)(struct nfc_hci_dev *dev, u32 se_idx);
 	int (*disable_se)(struct nfc_hci_dev *dev, u32 se_idx);
diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index 0e353f1..5f286b7 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -68,7 +68,7 @@ struct nfc_ops {
 			     void *cb_context);
 	int (*tm_send)(struct nfc_dev *dev, struct sk_buff *skb);
 	int (*check_presence)(struct nfc_dev *dev, struct nfc_target *target);
-	int (*fw_upload)(struct nfc_dev *dev, const char *firmware_name);
+	int (*fw_download)(struct nfc_dev *dev, const char *firmware_name);
=20
 	/* Secure Element API */
 	int (*discover_se)(struct nfc_dev *dev);
@@ -127,7 +127,7 @@ struct nfc_dev {
 	int targets_generation;
 	struct device dev;
 	bool dev_up;
-	bool fw_upload_in_progress;
+	bool fw_download_in_progress;
 	u8 rf_mode;
 	bool polling;
 	struct nfc_target *active_target;
diff --git a/include/uapi/linux/nfc.h b/include/uapi/linux/nfc.h
index caed0f3..8137dd8 100644
--- a/include/uapi/linux/nfc.h
+++ b/include/uapi/linux/nfc.h
@@ -69,8 +69,8 @@
  *	starting a poll from a device which has a secure element enabled means
  *	we want to do SE based card emulation.
  * @NFC_CMD_DISABLE_SE: Disable the physical link to a specific secure ele=
ment.
- * @NFC_CMD_FW_UPLOAD: Request to Load/flash firmware, or event to inform =
that
- *	some firmware was loaded
+ * @NFC_CMD_FW_DOWNLOAD: Request to Load/flash firmware, or event to inform
+ *	that some firmware was loaded
  */
 enum nfc_commands {
 	NFC_CMD_UNSPEC,
@@ -94,7 +94,7 @@ enum nfc_commands {
 	NFC_CMD_DISABLE_SE,
 	NFC_CMD_LLC_SDREQ,
 	NFC_EVENT_LLC_SDRES,
-	NFC_CMD_FW_UPLOAD,
+	NFC_CMD_FW_DOWNLOAD,
 	NFC_EVENT_SE_ADDED,
 	NFC_EVENT_SE_REMOVED,
 /* private: internal use only */
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index e3a3499..cc27297 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -513,7 +513,10 @@ static void hci_init2_req(struct hci_request *req, uns=
igned long opt)
=20
 	hci_setup_event_mask(req);
=20
-	if (hdev->hci_ver > BLUETOOTH_VER_1_1)
+	/* AVM Berlin (31), aka "BlueFRITZ!", doesn't support the read
+	 * local supported commands HCI command.
+	 */
+	if (hdev->manufacturer !=3D 31 && hdev->hci_ver > BLUETOOTH_VER_1_1)
 		hci_req_add(req, HCI_OP_READ_LOCAL_COMMANDS, 0, NULL);
=20
 	if (lmp_ssp_capable(hdev)) {
@@ -2165,10 +2168,6 @@ int hci_register_dev(struct hci_dev *hdev)
=20
 	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
=20
-	write_lock(&hci_dev_list_lock);
-	list_add(&hdev->list, &hci_dev_list);
-	write_unlock(&hci_dev_list_lock);
-
 	hdev->workqueue =3D alloc_workqueue("%s", WQ_HIGHPRI | WQ_UNBOUND |
 					  WQ_MEM_RECLAIM, 1, hdev->name);
 	if (!hdev->workqueue) {
@@ -2203,6 +2202,10 @@ int hci_register_dev(struct hci_dev *hdev)
 	if (hdev->dev_type !=3D HCI_AMP)
 		set_bit(HCI_AUTO_OFF, &hdev->dev_flags);
=20
+	write_lock(&hci_dev_list_lock);
+	list_add(&hdev->list, &hci_dev_list);
+	write_unlock(&hci_dev_list_lock);
+
 	hci_notify(hdev, HCI_DEV_REG);
 	hci_dev_hold(hdev);
=20
@@ -2215,9 +2218,6 @@ err_wqueue:
 	destroy_workqueue(hdev->req_workqueue);
 err:
 	ida_simple_remove(&hci_index_ida, hdev->id);
-	write_lock(&hci_dev_list_lock);
-	list_del(&hdev->list);
-	write_unlock(&hci_dev_list_lock);
=20
 	return error;
 }
@@ -3399,8 +3399,16 @@ void hci_req_cmd_complete(struct hci_dev *hdev, u16 =
opcode, u8 status)
 	 */
 	if (hdev->sent_cmd) {
 		req_complete =3D bt_cb(hdev->sent_cmd)->req.complete;
-		if (req_complete)
+
+		if (req_complete) {
+			/* We must set the complete callback to NULL to
+			 * avoid calling the callback more than once if
+			 * this function gets called again.
+			 */
+			bt_cb(hdev->sent_cmd)->req.complete =3D NULL;
+
 			goto call_complete;
+		}
 	}
=20
 	/* Remove all pending commands belonging to this request */
diff --git a/net/mac80211/mesh_ps.c b/net/mac80211/mesh_ps.c
index 3b7bfc0..22290a9 100644
--- a/net/mac80211/mesh_ps.c
+++ b/net/mac80211/mesh_ps.c
@@ -229,6 +229,10 @@ void ieee80211_mps_sta_status_update(struct sta_info *=
sta)
 	enum nl80211_mesh_power_mode pm;
 	bool do_buffer;
=20
+	/* For non-assoc STA, prevent buffering or frame transmission */
+	if (sta->sta_state < IEEE80211_STA_ASSOC)
+		return;
+
 	/*
 	 * use peer-specific power mode if peering is established and the
 	 * peer's power mode is known
diff --git a/net/mac80211/pm.c b/net/mac80211/pm.c
index 7fc5d0d..3401262 100644
--- a/net/mac80211/pm.c
+++ b/net/mac80211/pm.c
@@ -99,10 +99,13 @@ int __ieee80211_suspend(struct ieee80211_hw *hw, struct=
 cfg80211_wowlan *wowlan)
 	}
 	mutex_unlock(&local->sta_mtx);
=20
-	/* remove all interfaces */
+	/* remove all interfaces that were created in the driver */
 	list_for_each_entry(sdata, &local->interfaces, list) {
-		if (!ieee80211_sdata_running(sdata))
+		if (!ieee80211_sdata_running(sdata) ||
+		    sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN ||
+		    sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR)
 			continue;
+
 		drv_remove_interface(local, sdata);
 	}
=20
diff --git a/net/nfc/core.c b/net/nfc/core.c
index dc96a83..1d074dd 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -44,7 +44,7 @@ DEFINE_MUTEX(nfc_devlist_mutex);
 /* NFC device ID bitmap */
 static DEFINE_IDA(nfc_index_ida);
=20
-int nfc_fw_upload(struct nfc_dev *dev, const char *firmware_name)
+int nfc_fw_download(struct nfc_dev *dev, const char *firmware_name)
 {
 	int rc =3D 0;
=20
@@ -62,28 +62,28 @@ int nfc_fw_upload(struct nfc_dev *dev, const char *firm=
ware_name)
 		goto error;
 	}
=20
-	if (!dev->ops->fw_upload) {
+	if (!dev->ops->fw_download) {
 		rc =3D -EOPNOTSUPP;
 		goto error;
 	}
=20
-	dev->fw_upload_in_progress =3D true;
-	rc =3D dev->ops->fw_upload(dev, firmware_name);
+	dev->fw_download_in_progress =3D true;
+	rc =3D dev->ops->fw_download(dev, firmware_name);
 	if (rc)
-		dev->fw_upload_in_progress =3D false;
+		dev->fw_download_in_progress =3D false;
=20
 error:
 	device_unlock(&dev->dev);
 	return rc;
 }
=20
-int nfc_fw_upload_done(struct nfc_dev *dev, const char *firmware_name)
+int nfc_fw_download_done(struct nfc_dev *dev, const char *firmware_name)
 {
-	dev->fw_upload_in_progress =3D false;
+	dev->fw_download_in_progress =3D false;
=20
-	return nfc_genl_fw_upload_done(dev, firmware_name);
+	return nfc_genl_fw_download_done(dev, firmware_name);
 }
-EXPORT_SYMBOL(nfc_fw_upload_done);
+EXPORT_SYMBOL(nfc_fw_download_done);
=20
 /**
  * nfc_dev_up - turn on the NFC device
@@ -110,7 +110,7 @@ int nfc_dev_up(struct nfc_dev *dev)
 		goto error;
 	}
=20
-	if (dev->fw_upload_in_progress) {
+	if (dev->fw_download_in_progress) {
 		rc =3D -EBUSY;
 		goto error;
 	}
diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index 7b1c186..fe66908 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -809,14 +809,14 @@ static void nfc_hci_recv_from_llc(struct nfc_hci_dev =
*hdev, struct sk_buff *skb)
 	}
 }
=20
-static int hci_fw_upload(struct nfc_dev *nfc_dev, const char *firmware_nam=
e)
+static int hci_fw_download(struct nfc_dev *nfc_dev, const char *firmware_n=
ame)
 {
 	struct nfc_hci_dev *hdev =3D nfc_get_drvdata(nfc_dev);
=20
-	if (!hdev->ops->fw_upload)
+	if (!hdev->ops->fw_download)
 		return -ENOTSUPP;
=20
-	return hdev->ops->fw_upload(hdev, firmware_name);
+	return hdev->ops->fw_download(hdev, firmware_name);
 }
=20
 static struct nfc_ops hci_nfc_ops =3D {
@@ -831,7 +831,7 @@ static struct nfc_ops hci_nfc_ops =3D {
 	.im_transceive =3D hci_transceive,
 	.tm_send =3D hci_tm_send,
 	.check_presence =3D hci_check_presence,
-	.fw_upload =3D hci_fw_upload,
+	.fw_download =3D hci_fw_download,
 	.discover_se =3D hci_discover_se,
 	.enable_se =3D hci_enable_se,
 	.disable_se =3D hci_disable_se,
diff --git a/net/nfc/nci/Kconfig b/net/nfc/nci/Kconfig
index 2a24160..a4f1e42 100644
--- a/net/nfc/nci/Kconfig
+++ b/net/nfc/nci/Kconfig
@@ -11,6 +11,7 @@ config NFC_NCI
=20
 config NFC_NCI_SPI
 	depends on NFC_NCI && SPI
+	select CRC_CCITT
 	bool "NCI over SPI protocol support"
 	default n
 	help
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index b05ad90..f16fd59 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1089,7 +1089,7 @@ exit:
 	return rc;
 }
=20
-static int nfc_genl_fw_upload(struct sk_buff *skb, struct genl_info *info)
+static int nfc_genl_fw_download(struct sk_buff *skb, struct genl_info *inf=
o)
 {
 	struct nfc_dev *dev;
 	int rc;
@@ -1108,13 +1108,13 @@ static int nfc_genl_fw_upload(struct sk_buff *skb, =
struct genl_info *info)
 	nla_strlcpy(firmware_name, info->attrs[NFC_ATTR_FIRMWARE_NAME],
 		    sizeof(firmware_name));
=20
-	rc =3D nfc_fw_upload(dev, firmware_name);
+	rc =3D nfc_fw_download(dev, firmware_name);
=20
 	nfc_put_device(dev);
 	return rc;
 }
=20
-int nfc_genl_fw_upload_done(struct nfc_dev *dev, const char *firmware_name)
+int nfc_genl_fw_download_done(struct nfc_dev *dev, const char *firmware_na=
me)
 {
 	struct sk_buff *msg;
 	void *hdr;
@@ -1124,7 +1124,7 @@ int nfc_genl_fw_upload_done(struct nfc_dev *dev, cons=
t char *firmware_name)
 		return -ENOMEM;
=20
 	hdr =3D genlmsg_put(msg, 0, 0, &nfc_genl_family, 0,
-			  NFC_CMD_FW_UPLOAD);
+			  NFC_CMD_FW_DOWNLOAD);
 	if (!hdr)
 		goto free_msg;
=20
@@ -1251,8 +1251,8 @@ static struct genl_ops nfc_genl_ops[] =3D {
 		.policy =3D nfc_genl_policy,
 	},
 	{
-		.cmd =3D NFC_CMD_FW_UPLOAD,
-		.doit =3D nfc_genl_fw_upload,
+		.cmd =3D NFC_CMD_FW_DOWNLOAD,
+		.doit =3D nfc_genl_fw_download,
 		.policy =3D nfc_genl_policy,
 	},
 	{
diff --git a/net/nfc/nfc.h b/net/nfc/nfc.h
index ee85a1f..820a785 100644
--- a/net/nfc/nfc.h
+++ b/net/nfc/nfc.h
@@ -123,10 +123,10 @@ static inline void nfc_device_iter_exit(struct class_=
dev_iter *iter)
 	class_dev_iter_exit(iter);
 }
=20
-int nfc_fw_upload(struct nfc_dev *dev, const char *firmware_name);
-int nfc_genl_fw_upload_done(struct nfc_dev *dev, const char *firmware_name=
);
+int nfc_fw_download(struct nfc_dev *dev, const char *firmware_name);
+int nfc_genl_fw_download_done(struct nfc_dev *dev, const char *firmware_na=
me);
=20
-int nfc_fw_upload_done(struct nfc_dev *dev, const char *firmware_name);
+int nfc_fw_download_done(struct nfc_dev *dev, const char *firmware_name);
=20
 int nfc_dev_up(struct nfc_dev *dev);
=20
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 5a950f3..de06d5d 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2247,10 +2247,13 @@ int reg_device_uevent(struct device *dev, struct ko=
bj_uevent_env *env)
=20
 void wiphy_regulatory_register(struct wiphy *wiphy)
 {
+	struct regulatory_request *lr;
+
 	if (!reg_dev_ignore_cell_hint(wiphy))
 		reg_num_devs_support_basehint++;
=20
-	wiphy_update_regulatory(wiphy, NL80211_REGDOM_SET_BY_CORE);
+	lr =3D get_last_request();
+	wiphy_update_regulatory(wiphy, lr->initiator);
 }
=20
 void wiphy_regulatory_deregister(struct wiphy *wiphy)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--CE+1k2dSO48ffgeK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJR+rCXAAoJEJctW/TcYTgG2eIP/2e3iV4IDDJcvjqjj6H6LMoG
yKMj6p57FRv0Y8PtYAK9g28/YtR8/okueJD1N89Znli6/aTr9WhG6j1XSQdjILvU
zyK6/WszhoSAKPwEiYuveZVCPPS2DEFRiFvIPSRKoDUzVXDoPMrzMyptGgCMwFw5
uR2g3l9Bau555hPPIBoh5iXLONVmujzPfWXV/oEB6OOVt4RiEP+sIsu/nsiJL+py
2uBp3cAZlfrTmL6G/lXBJ9+nh3VGBlHHEc3vhj3cF+eDkT4jjBhbThTipdvTY+ka
11w1DpiWH8rvsqj0NVGCn979jVU4dAuNV9jJNomTzEbxr8K3GqMhGJ/1AZ4HZ4Im
AYe4njSXbPaFwSWTDtG/Bynl9UQCSFXAH4tlQFlghxW7iyDOlygUp4K6LCWMkZ0G
/gHYprVi4NmPTJG/yhIUx8nLYVfulTxmcZp0wKzmykq+AqcQUHhfktsp5KXvM185
9Mb2987l064oikm4nhgIe/b3urMufwMirNsIFN7BIF2ubK/vxLdyYq6NtCYepekA
t1DVbG9Qnssh2KL0tSq8IlwKKOS5njaEc7GojwrwJaqdFKLVZ34CocLjinMKiEei
6fM0ru1bUfKJ/9U0bs/umq5NzeXk6qlLEYVB9/tdpR8F84oZmWETuFXo9SICCUIr
BI0S8R2ilqaq4fTUeOj6
=Mh5f
-----END PGP SIGNATURE-----

--CE+1k2dSO48ffgeK--
