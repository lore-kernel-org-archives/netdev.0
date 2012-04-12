From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-04-12
Date: Thu, 12 Apr 2012 15:55:20 -0400
Message-ID: <20120412195520.GC21495@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ftEhullJWpWg/VHq"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53621 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866Ab2DLUC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 16:02:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ftEhullJWpWg/VHq
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 7eab0f64a9eba5405222fdef0ede2468bf495efd

Dave,

Welcome to the first wireless pull request for the 3.5 era! :-)

Highlights of this batch include some mac80211 refactoring and
enhancements, a number of iwlwifi updates, some ath9k updates
(including a DFS pattern detector), and various other updates to
rtlwifi, mwifiex, and various other drivers.  Overall, nothing too
unusual...

Please let me know if there are problems!

Thanks,

John

P.S.  This also includes a pull from the wireless tree, to provide
a prerequisite fix for the NFC updates.

---

The following changes since commit cade455596504fae8e134a27189713ddf7c6d04d:

  team: add missed "statics" (2012-04-11 10:03:52 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

AceLan Kao (1):
      Bluetooth: Add support for Atheros [04ca:3005]

Amitkumar Karwar (5):
      mwifiex: update signal strength in mBm units
      mwifiex: add cfg80211 dump_station handler
      mwifiex: remove redundant signal handling code
      mwifiex: support STATION_INFO_SIGNAL_AVG
      mwifiex: add set_cqm_rssi_config handler support

Andrei Emeltchenko (3):
      Bluetooth: Fix memory leaks due to chan refcnt
      Bluetooth: mgmt: Add missing endian conversion
      Bluetooth: mgmt: Fix timeout type

Antonio Quartulli (1):
      b43: claim support for IBSS RSN

Ashok Nagarajan (4):
      mac80211: Use mandatory rates as basic rates when starting mesh
      mac80211: Indicate basic rates when adding rate IEs
      mac80211: Modify sta_get_rates to give basic rates
      mac80211: Check basic rates when peering

Ben Greear (3):
      mac80211: Add iface name when calling WARN-ON.
      ath9k: Add tx-failed counter.
      ath9k: Add more recv stats.

Brian Gix (1):
      Bluetooth: mgmt: Fix corruption of device_connected pkt

Chen, Chien-Chia (1):
      rt2x00: Fix rfkill_polling register function.

Cho, Yu-Chen (1):
      Bluetooth: Add Atheros maryann PIDVID support

Christian Lamparter (1):
      p54: only unregister ieee80211_hw when it has been registered

Chun-Yeow Yeoh (2):
      mac80211: fix the sparse warnings on endian handling in RANN propagat=
ion
      mac80211: fix the RANN propagation issues

David Spinadel (1):
      iwlwifi: phy_db structure

Don Fry (2):
      iwlwifi: move FW_ERROR to priv
      iwlwifi: split POWER_PMI status bit

Don Zickus (1):
      Bluetooth: btusb: typo in Broadcom SoftSailing id

Felix Fietkau (3):
      cfg80211: use compare_ether_addr on MAC addresses instead of memcmp
      mac80211: reduce code duplication in debugfs code
      mac80211: optimize aggregation session timeout handling

Gustavo Padovan (1):
      Bluetooth: Fix userspace compatibility issue with mgmt interface

Hemant Gupta (1):
      Bluetooth: Use correct flags for checking HCI_SSP_ENABLED bit

Jakub Kicinski (1):
      rt2x00: increase led's name buffer length

Javier Cardona (4):
      mac80211_hwsim: Fill timestamp beacon at the time it is transmitted
      mac80211: Allow tsf increments via debugfs
      mac80211: Implement mesh synchronization framework
      {nl,cfg}80211: Support for mesh synchronization

Joe Perches (6):
      rtlwifi: Use is_zero_ether_addr, remove line continuation
      rtlwifi: Simplify rtl_get/set inline functions
      ath: Add and use pr_fmt, convert printks to pr_<level>
      ath5k: Introduce _ath5k_printk to reduce code/text
      iwlwifi: Add pr_fmt
      wireless: Remove unnecessary ; from while (0) macros

Johan Hedberg (2):
      Bluetooth: Don't increment twice in eir_has_data_type()
      Bluetooth: Check for minimum data length in eir_has_data_type()

Johan Hovold (2):
      Bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
      Bluetooth: hci_core: fix NULL-pointer dereference at unregister

Johannes Berg (37):
      mac80211: fix association beacon wait timeout
      nl80211: ensure interface is up in various APIs
      wireless: rename ht_info to ht_operation
      iwlwifi: process multiple frames per RXB
      iwlwifi: extend notification wait
      iwlwifi: simplify calibration collection
      iwlwifi: add trailing newline to various messages
      iwlwifi: clarify config struct comments
      iwlwifi: remove support_wimax_coexist
      iwlwifi: remove iq_invert config param
      iwlwifi: remove scan_rx_antennas
      iwlwifi: use scan while idle
      iwlwifi: move queue mapping out of transport
      iwlwifi: move valid_contexts to priv
      mac80211: don't always advertise remain-on-channel
      mwifiex: don't use IEEE80211_MAX_QUEUES
      mac80211: fix mesh TX coding style
      mac80211: clean up uAPSD TX code
      mac80211: make ieee80211_downgrade_queue static
      mac80211: inline ieee80211_add_pending_skbs
      mac80211: use AC constants
      mac80211: set HT channel before association
      mac80211: remove channel type argument from rate_update
      mac80211: remove queue stop on rate control update
      mac80211: notify driver of rate control updates
      mac80211: remove antenna_sel_tx TX info field
      cfg80211/nl80211: clarify TX queue API
      mac80211: refuse TX queue configuration on non-QoS HW
      mac80211: decouple # of netdev queues from HW queues
      mac80211: debounce queue stop/wake
      mac80211: lazily stop queues in add_pending
      mac80211: use IEEE80211_NUM_ACS
      mac80211: manage AP netdev carrier state
      mac80211: add explicit monitor interface if needed
      mac80211: add improved HW queue control
      mac80211: clean up an ieee80211_do_open error path
      cfg80211/mac80211: enable proper device_set_wakeup_enable handling

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' into for-davem

Jo=E3o Paulo Rechi Vita (1):
      Bluetooth: btusb: Add USB device ID "0a5c 21e8"

Julia Lawall (1):
      net/wireless/wext-core.c: add missing kfree

Larry Finger (8):
      rtlwifi: rtl8192de: Fix firmware initialization
      mac80211: Convert WARN_ON to WARN_ON_ONCE
      rtlwifi: Fix oops on rate-control failure
      p54usb: Load firmware asynchronously
      rtlwifi: Preallocate USB read buffers and eliminate kalloc in read ro=
utine
      rtlwifi: Add missing DMA buffer unmapping for PCI drivers
      rtlwifi: Preallocate USB read buffers and eliminate kalloc in read ro=
utine
      rtlwifi: Add missing DMA buffer unmapping for PCI drivers

Luis R. Rodriguez (1):
      cfg80211: warn if db.txt is empty with CONFIG_CFG80211_INTERNAL_REGDB

Marcel Holtmann (1):
      MAINTAINERS: update Bluetooth tree locations

Marco Porsch (1):
      mac80211: end service period only after sending last buffered frame

Meenakshi Venkataraman (11):
      iwlwifi: use iwlagn_fw_error instead of iwl_nic_error
      iwlwifi: make iwl_nic_error static
      iwlwifi: move ucode error log reporting to op_mode
      iwlwifi: move ucode_type from shared to op_mode
      iwlwifi: move iwl_init_geos to iwl-agn.c
      iwlwifi: Move iwl_send_rxon_timing and make it static
      iwlwifi: move iwl_set_rxon_hwcrypto and mark it static
      iwlwifi: move iwl_check_rxon_cmd and mark it static
      iwlwifi: move iwl_full_rxon_required and mark it static
      iwlwifi: move iwl_get_single_channel_number and mark it static
      iwlwifi: remove firmware info from iwl_shared

Oliver Hartkopp (1):
      iwlwifi: fix unused variable warning

Paul Gortmaker (1):
      bcma: fix build error on MIPS; implicit pcibios_enable_device

Qasim Javed (1):
      ath5k: Remove extraneous statements from ath5k_hw_proc_4word_tx_statu=
s and ath5k_hw_proc_2word_status.

Rajkumar Manoharan (5):
      ath9k_hw: improve ANI processing and rx desensitizing parameters
      ath9k: recover ar9380 chips from rare stuck state
      mac80211: do not send pspoll when powersave is disabled
      mac80211: flush to get the tx status of nullfunc frame immediately
      ath9k_hw: Update rx gain initval to improve rx sensitivity

Ronald Wahl (1):
      mac80211: when receiving DTIM disable power-save mode only if it was =
enabled

Samuel Ortiz (1):
      NFC: Fix the LLCP Tx fragmentation loop

Santosh Nayak (1):
      Bluetooth: Fix Endian Bug.

Stanislav Yakovlev (2):
      net/wireless: ipw2x00: remove unused libipw_measurement_report struct
      net/wireless: ipw2x00: remove ssid_context struct

Stanislaw Gruszka (3):
      mac80211: sanity check for null SSID
      rt2x00: configure different txdesc parameters for non HT channel
      rt2x00: do not generate seqno in h/w if QOS is disabled

Sujith Manoharan (1):
      Revert "ath9k: fix going to full-sleep on PS idle"

Thomas Pedersen (1):
      cfg80211: add channel switch notify event

Wey-Yi Guy (1):
      iwlwifi: remove un-needed parameter

Zefir Kurtisi (3):
      ath9k: add DFS pattern detector
      ath9k: add DFS pattern detector instance to ath_softc
      ath9k: update to DFS pattern detector interface

 Documentation/DocBook/80211.tmpl                   |    2 +-
 .../networking/mac80211-auth-assoc-deauth.txt      |   10 +-
 MAINTAINERS                                        |    8 +-
 drivers/bcma/Kconfig                               |    2 +-
 drivers/bcma/driver_pci_host.c                     |    1 +
 drivers/bluetooth/ath3k.c                          |    4 +
 drivers/bluetooth/btusb.c                          |    5 +-
 drivers/bluetooth/hci_ldisc.c                      |    2 +-
 drivers/net/wireless/ath/ath5k/ani.c               |   44 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   29 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    2 +
 drivers/net/wireless/ath/ath5k/base.c              |   22 +
 drivers/net/wireless/ath/ath5k/debug.c             |   17 +-
 drivers/net/wireless/ath/ath5k/desc.c              |    6 +-
 drivers/net/wireless/ath/ath5k/dma.c               |    2 +
 drivers/net/wireless/ath/ath5k/eeprom.c            |    2 +
 drivers/net/wireless/ath/ath5k/initvals.c          |    5 +-
 drivers/net/wireless/ath/ath5k/led.c               |    2 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    2 +
 drivers/net/wireless/ath/ath5k/pci.c               |    4 +-
 drivers/net/wireless/ath/ath5k/phy.c               |    2 +
 drivers/net/wireless/ath/ath5k/qcu.c               |    2 +
 drivers/net/wireless/ath/ath5k/reset.c             |    2 +
 drivers/net/wireless/ath/ath5k/sysfs.c             |    2 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    2 +
 drivers/net/wireless/ath/ath6kl/init.c             |    2 +
 drivers/net/wireless/ath/ath6kl/main.c             |    2 +
 drivers/net/wireless/ath/ath6kl/txrx.c             |    2 +
 drivers/net/wireless/ath/ath9k/Makefile            |    5 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   49 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    6 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   38 -
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   49 --
 drivers/net/wireless/ath/ath9k/ath9k.h             |    5 +
 drivers/net/wireless/ath/ath9k/debug.c             |   24 +-
 drivers/net/wireless/ath/ath9k/debug.h             |   21 +
 drivers/net/wireless/ath/ath9k/dfs.c               |   80 +--
 drivers/net/wireless/ath/ath9k/dfs.h               |    8 +-
 .../net/wireless/ath/ath9k/dfs_pattern_detector.c  |  300 ++++++++
 .../net/wireless/ath/ath9k/dfs_pattern_detector.h  |  104 +++
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c  |  390 ++++++++++
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.h  |   52 ++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   11 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   73 ++
 drivers/net/wireless/ath/ath9k/init.c              |   19 +-
 drivers/net/wireless/ath/ath9k/main.c              |   57 ++-
 drivers/net/wireless/ath/ath9k/pci.c               |    9 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    7 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   39 +-
 drivers/net/wireless/ath/carl9170/cmd.h            |    6 +-
 drivers/net/wireless/ath/carl9170/fw.c             |    2 +
 drivers/net/wireless/ath/main.c                    |    4 +-
 drivers/net/wireless/ath/regd.c                    |    4 +-
 drivers/net/wireless/b43/main.c                    |   16 +
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/b43legacy/xmit.c              |   14 +-
 drivers/net/wireless/brcm80211/brcmsmac/d11.h      |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.h             |    9 -
 drivers/net/wireless/ipw2x00/libipw.h              |   55 --
 drivers/net/wireless/iwlegacy/4965-mac.c           |    4 +-
 drivers/net/wireless/iwlegacy/4965-rs.c            |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    8 +
 drivers/net/wireless/iwlwifi/Makefile              |    2 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    1 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   19 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    1 -
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    3 -
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |    3 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   24 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |  261 +++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |  144 +++-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  786 ++++++++++++++++=
+++-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   23 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  484 +------------
 drivers/net/wireless/iwlwifi/iwl-core.h            |   15 -
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   58 ++-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   24 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   14 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |   44 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.h      |   21 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   17 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c             |    3 +
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |  273 +++++++
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |  123 +++
 drivers/net/wireless/iwlwifi/iwl-power.c           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   53 ++-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |   32 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |  148 +----
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |  514 ++-----------
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |  218 +-----
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |  270 ++------
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   95 ++--
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |  133 ++--
 drivers/net/wireless/mac80211_hwsim.c              |   32 +-
 drivers/net/wireless/mwifiex/11n.c                 |   17 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   81 ++-
 drivers/net/wireless/mwifiex/fw.h                  |   23 +-
 drivers/net/wireless/mwifiex/ioctl.h               |   49 +-
 drivers/net/wireless/mwifiex/join.c                |   14 +-
 drivers/net/wireless/mwifiex/main.h                |   14 +-
 drivers/net/wireless/mwifiex/scan.c                |   17 +-
 drivers/net/wireless/mwifiex/sdio.h                |    8 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   98 +++
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   80 ++-
 drivers/net/wireless/mwifiex/sta_event.c           |   15 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   33 -
 drivers/net/wireless/p54/main.c                    |   11 +-
 drivers/net/wireless/p54/p54.h                     |    1 +
 drivers/net/wireless/p54/p54usb.c                  |  195 ++++--
 drivers/net/wireless/p54/p54usb.h                  |    3 +
 drivers/net/wireless/p54/txrx.c                    |    3 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    2 +
 drivers/net/wireless/rt2x00/rt2x00config.c         |    5 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    6 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c           |   16 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   10 +
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   41 +-
 drivers/net/wireless/rtlwifi/base.c                |    5 +-
 drivers/net/wireless/rtlwifi/cam.c                 |    5 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    7 +-
 drivers/net/wireless/rtlwifi/rc.c                  |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    6 -
 drivers/net/wireless/rtlwifi/rtl8192de/trx.h       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h        |    6 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   34 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   30 +-
 drivers/net/wireless/wl12xx/main.c                 |    5 +-
 include/linux/ieee80211.h                          |   32 +-
 include/linux/nl80211.h                            |   41 +-
 include/net/bluetooth/hci.h                        |    3 +-
 include/net/bluetooth/hci_core.h                   |   12 +-
 include/net/bluetooth/mgmt.h                       |    2 +-
 include/net/cfg80211.h                             |   33 +-
 include/net/mac80211.h                             |  144 +++-
 net/bluetooth/hci_core.c                           |    7 +
 net/bluetooth/l2cap_core.c                         |    3 +
 net/bluetooth/l2cap_sock.c                         |    5 +-
 net/bluetooth/mgmt.c                               |   13 +-
 net/mac80211/Kconfig                               |   11 +
 net/mac80211/Makefile                              |    3 +-
 net/mac80211/agg-rx.c                              |   18 +-
 net/mac80211/agg-tx.c                              |   57 +-
 net/mac80211/cfg.c                                 |   60 ++-
 net/mac80211/chan.c                                |   26 -
 net/mac80211/debugfs_netdev.c                      |   83 +--
 net/mac80211/debugfs_sta.c                         |    5 +-
 net/mac80211/driver-ops.h                          |   41 +-
 net/mac80211/driver-trace.h                        |   55 ++-
 net/mac80211/ht.c                                  |    9 -
 net/mac80211/ibss.c                                |   22 +-
 net/mac80211/ieee80211_i.h                         |   66 ++-
 net/mac80211/iface.c                               |  150 ++++-
 net/mac80211/main.c                                |   12 +-
 net/mac80211/mesh.c                                |   53 +-
 net/mac80211/mesh.h                                |   25 +-
 net/mac80211/mesh_hwmp.c                           |   28 +-
 net/mac80211/mesh_plink.c                          |   17 +-
 net/mac80211/mesh_sync.c                           |  296 ++++++++
 net/mac80211/mlme.c                                |  306 ++++----
 net/mac80211/pm.c                                  |    4 +
 net/mac80211/rate.h                                |    7 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   15 +-
 net/mac80211/rx.c                                  |   10 +-
 net/mac80211/sta_info.c                            |   16 +-
 net/mac80211/sta_info.h                            |   11 +
 net/mac80211/tx.c                                  |   79 ++-
 net/mac80211/util.c                                |  193 ++++--
 net/mac80211/wme.c                                 |   46 +-
 net/mac80211/wme.h                                 |    3 -
 net/nfc/llcp/commands.c                            |    4 +-
 net/wireless/core.c                                |    5 +-
 net/wireless/mesh.c                                |    3 +
 net/wireless/mlme.c                                |   59 ++-
 net/wireless/nl80211.c                             |   92 ++-
 net/wireless/nl80211.h                             |    4 +
 net/wireless/reg.c                                 |   10 +
 net/wireless/scan.c                                |    2 +-
 net/wireless/wext-core.c                           |    6 +-
 185 files changed, 5524 insertions(+), 3085 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs_pattern_detector.c
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs_pattern_detector.h
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs_pri_detector.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.h
 create mode 100644 net/mac80211/mesh_sync.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ftEhullJWpWg/VHq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPhzMnAAoJEJctW/TcYTgGY2sP/06WkTNEYDkPW4q8c5Nc1UPJ
oTEN/hMk5etPq/Wj0+BPM7S9L7iWHIXU20nDfaoZpijHs0yCdVsVW+rUDrofYnEi
1QjWQ0jfdDeX8aP2uqHFfuEZmq8YdSHWIeVwO3VjAMKmoqJXK+3TYenbz4AULxtj
ls8aENCvQYaGRV4sULeMSymjrGIK/lnGpy8qM6NR3lrW4n3VmcPiZf9D0my3PXZ2
T+Pxcx7OznUIRqDMp9kdzu+vxx/1N4WSK6WiT5u5Hr9UCGGrGOG/loES3hXMBqQy
U35jGf8jFA9Gijrj82FIEft72GnzwBC51lTmiDfULLHQoeubvLFBtpniu0hXv0dL
vToMyjSRzc0A++K6/7dK8MF01BR3WY1HCj2pskR7K1Vyv07vcV0kcRNUp6MWJHFt
uxpV1Uvll+5e/M+I18GSzmSPOBeEtwboGQ3S2771de4atrhC2Z0lHDHf1c4ewHy+
JhnFbt+H86QWa3uQU/rieYsoZ6mNU3z0yvtqCoZ7zpDGGIAUqFFBhzlJEus2Wgo4
XI08CKQ8m/eFS4mXy938mJpHBv0OkduA3BIFdLkny204MvCedUdaEc3Rh7W8GzQR
ZQoqmrY1uyBERv72GGJ82QIozwec3zQ6bT2hRQn4wqN2RxWKh7XdmwdFfyC8CLTB
ZWrdGERtPUxks5rEqJ0U
=mbIX
-----END PGP SIGNATURE-----

--ftEhullJWpWg/VHq--
