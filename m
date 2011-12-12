From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2011-12-12
Date: Mon, 12 Dec 2011 14:35:21 -0500
Message-ID: <20111212193521.GB9508@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit f2abba4921b945a6f8aca36fcba634c22797ba78

Dave,

This is the latest round of wireless updates intended for 3.3.
This includes big refactoring activities in bluetooth and wl12xx.
Beyond that, there is with the usual level of activity around ath9k
and iwlwifi as well as a variety of other patches here and there.  One
highlight is the introduction of HT operations for IBSS in mac80211.

Please let me know if there are problems!

John

---

The following changes since commit dfd56b8b38fff3586f36232db58e1e9f7885a605:

  net: use IS_ENABLED(CONFIG_IPV6) (2011-12-11 18:25:16 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Alexander Simon (2):
      nl80211: Parse channel type attribute in an ibss join request
      mac80211: Add HT operation modes for IBSS

Andre Guedes (4):
      Bluetooth: Rename mgmt_inquiry_failed()
      Bluetooth: mgmt_stop_discovery_failed()
      Bluetooth: Add dev_flags to struct hci_dev
      Bluetooth: LE Set Scan Parameter Command

Andrei Emeltchenko (10):
      Bluetooth: Move scope of kernel parameter enable_hs
      Bluetooth: Do not set HCI_RAW when HS enabled
      Bluetooth: Allow to set AMP type for virtual HCI
      Bluetooth: making enable_hs independent from L2CAP
      Bluetooth: Use queue in the device list
      Bluetooth: Add HCI Read Flow Control Mode function
      Bluetooth: remove old code
      Bluetooth: Correct version check in hci_setup
      Bluetooth: Remove magic bluetooth version numbers
      Bluetooth: trivial: correct check for LMP version

Arik Nemtsov (5):
      wl12xx: keep beacon-filtering enabled during STA operation
      wl12xx: configure probe-resp template according to notification
      wl12xx: indicate probe-resp offloading support
      wl12xx: avoid bail out when probe-resp is not set by mac80211
      wl12xx: leave IV calculation to HW for CCMP

Ben Greear (1):
      mac80211: Remove WARN_ON in apply-ht-override logic.

Bing Zhao (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8797

Brian Gix (9):
      Bluetooth: Add HCI defines for User Passkey entry
      Bluetooth: Add MGMT opcodes for Passkey Entry
      Bluetooth: Add MGMT event for Passkey Entry
      Bluetooth: User Pairing Response restructuring
      Bluetooth: Differentiate LE User Pairing Responses
      Bluetooth: Add User Passkey Response handling
      Bluetooth: Add HCI User Passkey Req Evt handling
      Bluetooth: Cleanup blkcipher on SMP termination
      Bluetooth: Centralize SMP pairing failure handling

Cong Wang (1):
      btusb: fix a memory leak in btusb_send_frame()

David Herrmann (2):
      Bluetooth: cmtp: Fix module reference
      Bluetooth: bnep: Fix module reference

Don Fry (4):
      iwlwifi: rename iwl-agn-ucode as iwl-ucode
      iwlwifi: replace iwl_priv reference with iwl_trans for ucode.
      iwlwifi: move ucode_type from iwl_priv to iwl_shared
      iwlwifi: move ucode notification from iwl_priv to iwl_shared

Eliad Peller (69):
      wl12xx: replace wl->mac_addr with vif->addr
      wl12xx: start reworking the init sequence
      wl12xx: define wl12xx_vif
      wl12xx: move rate_set into wlvif
      wl12xx: move basic_rate into wlvif
      wl12xx: replace wl->bssid with vif->bss_conf.bssid
      wl12xx: move bss_type into wlvif
      wl12xx: remove set_bss_type field
      wl12xx: move p2p into wlvif
      wl12xx: move ssid and ssid_len into wlvif
      wl12xx: move probereq into wlvif
      wl12xx: move aid into wlvif
      wl12xx: move role_id into wlvif
      wl12xx: move dev_role_id into wlvif
      wl12xx: move sta_hlid into wlvif
      wl12xx: move ap_global_hlid and ap_bcast_hlid into wlvif
      wl12xx: move session_counter into wlvif
      wl12xx: move some logic into wl12xx_init_vif_data
      wl12xx: move dev_hlid into wlvif
      wl12xx: move beacon_int into wlvif
      wl12xx: move default_key into wlvif
      wl12xx: move pspoll_work into wlvif
      wl12xx: move ps_compl into wlvif
      wl12xx: move ps_poll_failures and psm_entry_retry into wlvif
      wl12xx: move rssi_thold and last_rssi_event into wlvif
      wl12xx: move ba fields into wlvif
      wl12xx: move ap_hlid_map into wlvif.ap
      wl12xx: move recorded_ap_keys into wlvif
      wl12xx: refactor fw init into a new function
      wl12xx: move last_tx_hlid into wlvif
      wl12xx: unify STA and AP tx_queue mechanism
      wl12xx: move some functions from remove_interface() to stop()
      wl12xx: move bitrate_masks into wlvif
      wl12xx: add vifs list
      wl12xx: support multiple vifs in the tx path
      wl12xx: configure sleep_policy according to active roles
      wl12xx: make event handling support multirole
      wl12xx: move tx_security_seq into wlvif
      wl12xx: rearm rx streaming per vif
      wl12xx: make WL1271_FLAG_STA_ASSOCIATED flag per-vif
      wl12xx: make WL1271_FLAG_IBSS_JOINED flag per-vif
      wl12xx: make WL1271_FLAG_AP_STARTED flag per-vif
      wl12xx: make WL1271_FLAG_PSM flag per-vif
      wl12xx: make WL1271_FLAG_STA_STATE_SENT flag per-vif
      wl12xx: make WL1271_FLAG_RX_STREAMING_STARTED flag per-vif
      wl12xx: make WL1271_FLAG_IF_INITIALIZED per-vif
      wl12xx: make WL1271_FLAG_PSPOLL_FAILURE flag per-vif
      wl12xx: make WL1271_FLAG_CS_PROGRESS flag per-vif
      wl12xx: add band field to wlvif
      wl12xx: add channel field to wlvif
      wl12xx: add power_level field to wlvif
      wl12xx: make op_config configure all vifs
      wl12xx: replace all remaining wl->vif references
      wl12xx: call stop() on recovery
      wl12xx: use dynamic rate policies
      wl12xx: add elp wakeup/sleep calls to add_interface
      wl12xx: use round-robin policy for tx
      wl12xx: handle injected packets
      wl12xx: couple role_start_dev with roc
      wl12xx: reconfigure rate policies on set_bitrate_mask
      wl12xx: add vifs_state debugfs key
      wl12xx: clear wl->vif on remove_interface
      wl12xx: use p2p rate index when the skb has the NO_CCK flag
      wl12xx: handle idle changes per-interface
      wl12xx: init CMD_TEMPL_KLV to sizeof(ieee80211_qos_hdr)
      wl12xx: don't explicitly check for unjoined ibss
      wl12xx: fix testmode test/interrogate commands
      wl12xx: remove redundant commands from plt init
      wl12xx: send testmode reply in wl1271_tm_cmd_interrogate

Eyal Shapira (2):
      wl12xx: fix SDIO suspend/resume
      wl12xx: minor fix in sched_scan_ssid_list

Felipe Balbi (8):
      wl12xx: add an sdio glue struct to keep wl and device side-by-side
      wl12xx: add an spi glue struct to keep wl and device side-by-side
      wl12xx: add a platform device to the sdio module
      wl12xx: add a platform device to the spi module
      wl12xx: add platform driver to the core module
      wl12xx: move common init code from bus modules to main
      wl12xx: mark some symbols static
      wl12xx: drop unneeded plat_dev

Felix Fietkau (4):
      ath9k: always issue a full hw reset after waking up from full-sleep m=
ode
      ath9k: rework power state handling
      ath9k: only drop packets in drv_flush when asked to
      ath9k: cancel all workqueue activity when going idle

Gustavo F. Padovan (5):
      Bluetooth: Rename l2cap_check_security()
      Bluetooth: Allow L2CAP to increase the security level
      Bluetooth: Only set ack_timer if we didn't send and ack
      Bluetooth: Add user readable debug for state changes
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth

Guy Eilam (1):
      wl12xx: set scan probe requests rate according to the no_cck flag

Hsu, Kenny (3):
      iwlwifi: add tm commands for sram reading by dumpit
      iwlwifi: add generic chunk size of tm dumpit packet
      iwlwifi: add WOWLAN uCode loading support by testmode

Johan Hedberg (10):
      Bluetooth: Add public/random LE address information to mgmt messages
      Bluetooth: Fix deadlock with mgmt_pair_device
      Bluetooth: Add proper response to mgmt_remove_keys command
      Bluetooth: Add status parameter to mgmt_disconnect response
      Bluetooth: Add address type to mgmt_pair_device
      Bluetooth: Fix mgmt_pair_device imediate error responses
      Bluetooth: Return success instead of EALREADY for mgmt commands
      Bluetooth: Create a unique mgmt error code hierarchy
      Bluetooth: Add missing cmd_complete for mgmt_load_link_keys
      Bluetooth: Pass all message parameters to mgmt_start_discovery

Johannes Berg (7):
      iwlagn: remove TX_REPLY_LIMIT debug
      iwlagn: remove HC_DUMP debug
      iwlagn: remove MACDUMP debug
      iwlagn: make debug levels more readable
      mac80211: fix retransmit
      mac80211: accept public action frames with mismatched BSSID
      wireless: disable wext sysfs by default

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-n=
ext
      wl12xx: silence tx_attr uninitialized warning in wl1271_tx_fill_hdr
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kenny Hsu (1):
      iwlwifi: add range checking in tm sram read command

Larry Finger (1):
      rtl8192c: Do not log firmware load message unless actually done

Luciano Coelho (10):
      wl12xx: remove sdio_test module
      wl12xx: move debugging definitions to a separate file
      wl12xx: sdio: use dev_dbg instead of wl1271_debug
      wl12xx: spi: use dev_err instead of wl1271_error
      wl12xx: use the same plat dev name for both SPI and SDIO
      wl12xx: change blocksize alignment quirk to negative
      wl12xx: use the same SDIO block size for all different chips
      wl12xx: increase firmware upload chunk size
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into wl12xx-next
      Merge branch 'wl12xx-next' into for-linville

Mohammed Shafi Shajakhan (2):
      ath9k_hw: sync to latest AR9462 INI
      ath9k: clarify max_streams for AR9462

Nikolay Martynov (5):
      ath9k: trivial: cosmetic fix in calibration debug log
      ath9k: change calibration debug log to output all calibration types
      ath9k: use config.enable_ani to check if ani should be performed
      ath9k: enable ANI for ar9100 chips
      iwlwifi regression in 20111205 merge

Pontus Fuchs (3):
      wl12xx: Validate FEM index from ini file and FW
      wl12xx: Check buffer bound when processing nvs data
      wl12xx: Print nvs/fw file name if loading fails.

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: pci: use fixed windows when possible

Shahar Lev (1):
      wl12xx: remove warning message during IBSS Tx

Simon Wunderlich (1):
      mac80211: handle protection mode, RIFS and ADDBA for HT IBSS

Szymon Janc (5):
      Bluetooth: Fix possible NULL pointer derefence in l2cap code
      Bluetooth: Simplify l2cap_add_to_srej_queue
      Bluetooth: Refactor loop in l2cap_retransmit_one_frame
      Bluetooth: Simplify __l2cap_global_chan_by_addr
      Bluetooth: Fix some checkpatch.pl errors and warnings

Thomas Meyer (2):
      rt2x00: Use kcalloc instead of kzalloc to allocate array
      iwlegacy: Use kcalloc instead of kzalloc to allocate array

Wey-Yi Guy (2):
      iwlwifi: declare static for iwl_sram_cleanup function
      iwlwifi: Rename file name from iwl-sv-open.c to iwl-testmode.c

 Documentation/feature-removal-schedule.txt         |    3 +-
 drivers/bcma/host_pci.c                            |   32 +-
 drivers/bluetooth/Kconfig                          |    6 +-
 drivers/bluetooth/btmrvl_sdio.c                    |   15 +-
 drivers/bluetooth/btusb.c                          |    3 +-
 drivers/bluetooth/hci_vhci.c                       |    8 +
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |    2 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |   42 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    5 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    6 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    1 -
 drivers/net/wireless/ath/ath9k/init.c              |    2 +
 drivers/net/wireless/ath/ath9k/main.c              |  204 +--
 drivers/net/wireless/ath/ath9k/pci.c               |   21 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    2 +-
 drivers/net/wireless/iwlegacy/common.c             |    5 +-
 drivers/net/wireless/iwlwifi/Makefile              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   51 -
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   20 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   15 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   62 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    7 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   41 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   15 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |   76 +
 .../iwlwifi/{iwl-sv-open.c =3D> iwl-testmode.c}      |  162 ++-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   34 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |   10 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    7 -
 .../iwlwifi/{iwl-agn-ucode.c =3D> iwl-ucode.c}       |  163 ++-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    2 +-
 drivers/net/wireless/wl12xx/Kconfig                |   10 -
 drivers/net/wireless/wl12xx/Makefile               |    3 -
 drivers/net/wireless/wl12xx/acx.c                  |  146 +-
 drivers/net/wireless/wl12xx/acx.h                  |   83 +-
 drivers/net/wireless/wl12xx/boot.c                 |   15 +
 drivers/net/wireless/wl12xx/cmd.c                  |  368 +++--
 drivers/net/wireless/wl12xx/cmd.h                  |   50 +-
 drivers/net/wireless/wl12xx/conf.h                 |    4 +
 drivers/net/wireless/wl12xx/debug.h                |  101 +
 drivers/net/wireless/wl12xx/debugfs.c              |  141 ++-
 drivers/net/wireless/wl12xx/event.c                |  214 ++-
 drivers/net/wireless/wl12xx/event.h                |    3 -
 drivers/net/wireless/wl12xx/init.c                 |  458 +++---
 drivers/net/wireless/wl12xx/init.h                 |    7 +-
 drivers/net/wireless/wl12xx/io.c                   |   12 +-
 drivers/net/wireless/wl12xx/io.h                   |   23 +-
 drivers/net/wireless/wl12xx/main.c                 | 1967 +++++++++++-----=
---
 drivers/net/wireless/wl12xx/ps.c                   |   56 +-
 drivers/net/wireless/wl12xx/ps.h                   |    9 +-
 drivers/net/wireless/wl12xx/reg.h                  |    2 +-
 drivers/net/wireless/wl12xx/rx.c                   |   34 +-
 drivers/net/wireless/wl12xx/scan.c                 |  102 +-
 drivers/net/wireless/wl12xx/scan.h                 |    8 +-
 drivers/net/wireless/wl12xx/sdio.c                 |  259 ++--
 drivers/net/wireless/wl12xx/sdio_test.c            |  543 ------
 drivers/net/wireless/wl12xx/spi.c                  |  214 +--
 drivers/net/wireless/wl12xx/testmode.c             |   76 +-
 drivers/net/wireless/wl12xx/tx.c                   |  373 +++--
 drivers/net/wireless/wl12xx/tx.h                   |   11 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |  377 ++--
 drivers/net/wireless/wl12xx/wl12xx_80211.h         |    5 -
 drivers/net/wireless/wl12xx/wl12xx_platform_data.c |    4 +-
 include/linux/ieee80211.h                          |   17 +
 include/linux/nl80211.h                            |    2 +
 include/linux/wl12xx.h                             |    5 +-
 include/net/bluetooth/bluetooth.h                  |    5 +
 include/net/bluetooth/hci.h                        |   38 +
 include/net/bluetooth/hci_core.h                   |   28 +-
 include/net/bluetooth/l2cap.h                      |    2 +-
 include/net/bluetooth/mgmt.h                       |   49 +-
 include/net/cfg80211.h                             |   11 +
 net/bluetooth/bnep/core.c                          |    8 +-
 net/bluetooth/cmtp/core.c                          |    5 +-
 net/bluetooth/hci_conn.c                           |    2 +-
 net/bluetooth/hci_core.c                           |   31 +-
 net/bluetooth/hci_event.c                          |  152 ++-
 net/bluetooth/l2cap_core.c                         |  101 +-
 net/bluetooth/l2cap_sock.c                         |   16 +-
 net/bluetooth/mgmt.c                               |  660 +++++--
 net/bluetooth/smp.c                                |   32 +-
 net/mac80211/agg-rx.c                              |    2 +
 net/mac80211/agg-tx.c                              |   26 +-
 net/mac80211/ht.c                                  |    6 +-
 net/mac80211/ibss.c                                |  101 +-
 net/mac80211/ieee80211_i.h                         |    1 +
 net/mac80211/main.c                                |    3 +-
 net/mac80211/rx.c                                  |   16 +-
 net/mac80211/tx.c                                  |    5 +-
 net/mac80211/util.c                                |    5 +
 net/wireless/Kconfig                               |    7 +-
 net/wireless/chan.c                                |   12 +-
 net/wireless/nl80211.c                             |   32 +-
 98 files changed, 4642 insertions(+), 3476 deletions(-)
 rename drivers/net/wireless/iwlwifi/{iwl-sv-open.c =3D> iwl-testmode.c} (8=
3%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-ucode.c =3D> iwl-ucode.c} (81=
%)
 create mode 100644 drivers/net/wireless/wl12xx/debug.h
 delete mode 100644 drivers/net/wireless/wl12xx/sdio_test.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO5ld5AAoJEJctW/TcYTgG6yUQAJLHRAvNG+AZFc/9l6yGrszI
o9cgN2qTsOdsxBtv4dJ7nlI5JSLh8/W9jLkA0V/msbvgFh1MobrtUkaJaWVOzDSe
HkZocr6t56qNj3PYY6MklLWWB/fSMVUGxDIic4BD62dNiODfvhXbH539ujiXm7xN
Qe1kd2PA6d2xgGW9EYmpMkZ2HVS9ZntcIIRSNhUwak1ttiMn1tjaZAnFMUfZ1V8R
ZVYwdcVJLfzzK6lj66pJ0lKR8JaT7jD/lTnDthrJmPC+z4Gg9JtDnMwB07j9HtO/
qAl52F3vUX/Tel0CX3uyCUSTO62Ar4FXOgF/IRg+4H+maPg/MYPy8fvduxlyCGsM
k2F1INmlOuT1InK7ZucDef382Nr+Bncx5mqj9rO3ae8xOxVOPB21ADJ9smyav3KM
S/n+bAsoz9SXLp/QBCebNRTq4abmc+iRUBkgNWpmxqftl7lyFCtrqIKVN816fWfh
WWELtbglZxXOEBjolmhPpLlsv+b7Uz428J9MxNXp5B1xsabdJ9zh33xz0Bkbtd/D
D35pwKjrXs7MjwWBkbRta0YvKvOychuysRNPtJiHoAfHD0NIwrhLvyKH5cxX2yBE
gO0Nu9ymk3EnLYBcAuFIFSnp6xXW2CT6Y6S3Y+BTlOhptWgT0csdH7vUk0bhCtmQ
fQiybdJ3Z7bQCFIpLLfs
=nL7W
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
