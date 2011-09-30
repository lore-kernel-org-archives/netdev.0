From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2011-09-30
Date: Fri, 30 Sep 2011 15:11:31 -0400
Message-ID: <20110930191131.GC2526@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41951 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046Ab1I3TPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 15:15:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is yet another big package of wireless updates for 3.2.  Highlight=
s
include a bluetooth pull, a wl12xx pull, and a pull of the wireless tre=
e
to fix some merge issues.  Also included is the usual big sets of
updates to ath9k, iwlagn, b43, and others.  Plus, the NFC subsystem gre=
w
NCI support.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 56fd49e399ce1d82200fad5b8924d4e35a58=
7809:

  bna: Driver Version changed to 3.0.2.2 (2011-09-29 19:36:36 -0400)

are available in the git repository at:
  git://git.infradead.org/users/linville/wireless-next.git for-davem

Alexander Simon (1):
      mac80211: fix indentation

Amit Beka (1):
      iwlagn: remove duplicate list init

Amitkumar Karwar (4):
      mwifiex: fix 5GHz association issue
      mwifiex: update bss band information
      mwifiex: pass correct band parameter to ieee80211_channel_to_freq=
uency()
      mwifiex: reset skb length before inserting to free queue

Anderson Briglia (1):
      Bluetooth: Fix wrong memcpy size on LE start encryption

Andre Guedes (2):
      Bluetooth: Reduce critical region.
      Bluetooth: Check 'dev_class' in mgmt_device_found()

Antti Julku (2):
      Bluetooth: Add mgmt command for fast connectable mode
      Bluetooth: Add mgmt events for blacklisting

Arik Nemtsov (12):
      wl12xx: don't queue a new dummy packet if one is already pending
      wl12xx: don't indicate up PS-filtered dummy packets
      wl12xx: AP mode - don't regulate FW blocks for non-active STAs
      wl12xx: support up to 8 stations in AP-mode
      wl12xx: don't regulate links when a single STA is connected
      wl12xx: AP mode - enable the BA constraint event from the FW
      wl12xx: AP mode - clean BA and queue state in tx_reset
      wl12xx: set mac80211 flags for A-MPDU aggregation support
      wl12xx: AP mode - support hidden SSID
      wl12xx: correct fw_status structure for 8 sta support in AP-mode
      wl12xx: report the stop_ba event to all STAs in AP-mode
      mac80211: treat the WME sta flag as a bit

Dan Carpenter (4):
      mwifiex: add a kfree() to an error path
      mwifiex: remove unneeded NULL check
      NFC: use after free on error
      wl3501_cs: min_t() cast truncates high bits

Daniel Drake (1):
      libertas: scan behaviour consistency improvements

David Herrmann (1):
      Bluetooth: hidp: Add support for NO_INIT_REPORTS quirk

Don Fry (1):
      iwlagn: replace beacon_time_fsf_bits variable with #define

Eliad Peller (20):
      wl12xx: print acx id
      wl12xx: print the seq_num of rx packet
      wl12xx: add module_param to trigger BUG() on recovery
      wl12xx: add beacon_filtering debugfs file
      wl12xx: don't disconnect on recovery
      wl12xx: don't use WL1271_SCAN_OPT_PRIORITY_HIGH flag
      wl12xx: check for ROC on scan_complete
      wl12xx: add config_hangover command
      wl12xx: use kstrtoul_from_user
      wl12xx: declare support for WIPHY_FLAG_AP_UAPSD
      wl12xx: support p2p interfaces
      cfg80211: add cfg80211_find_vendor_ie() function
      wl12xx: remove TIM ie from probe response
      wl12xx: remove P2P ie from probe response
      wl12xx: send all pending packets on channel change
      wl12xx: Use dev_hlid for auth and assoc req
      wl12xx: implement set_bitrate_mask callback
      mac80211: add ieee80211_vif param to tsf functions
      cfg80211/mac80211: add netdev param to set_txq_params()
      mac80211: save tx params per sdata

Emmanuel Grumbach (17):
      iwlagn: warn about buggy fw that doesn't set SEQ_RX_FRAME
      iwlagn: unmap cmd queue's tfds as BIDI
      iwlagn: free the Tx cmd when a non empty Tx queue is freed
      iwlagn: move iwl_stop / wake_queue to the upper layer
      iwlagn: use enum iwl_rxon_context_id instead of u8
      iwlagn: document the bus layer API
      iwlagn: add documentation to the transport layer
      iwlagn: provide data after WARN_ON
      iwlagn: remove the callback in host commands
      iwlagn: simplify the iwl_device_cmd layout
      iwlagn: remove uneeded declaration
      iwlagn: pending frames musn't be incremented if agg is on
      iwlagn: remove warning in iwl_rx_handle
      iwlagn: sparse warning priv->temperature is signed
      iwlagn: set the sequence control from the transport layer
      iwlagn: update rate scaling with BA notifications
      iwlagn: use kcalloc when possible for array allocation

=46elix Fietkau (7):
      ath9k: fix setting the IEEE80211_TX_CTL_CLEAR_PS_FILT flag
      ath9k: sync the dma buffer after changing the retry flag
      ath9k_hw: clean up hardware revision checks
      ath9k_hw: remove dead code in the eeprom ops
      ath9k_hw: fix setting the hardware diversity flag
      ath9k_hw: remove ar9100_hw_compute_pll_control
      ath9k: fix a regression in ath9k_ps_restore

=46ry, Donald H (2):
      iwlagn: fix modinfo display for 135 ucode.
      iwlagn: simplify chain_noise_num_beacons indirection

Ilan Elias (7):
      NFC: Add dev_up and dev_down control operations
      NFC: move nfc.h from include/net to include/net/nfc
      NFC: basic NCI protocol implementation
      NFC: driver for TI shared transport
      NFC: improve readability of an 'if' in nci core.c
      NFC: implicitly deactivate in nci_start_poll
      NFC: protect nci_data_exchange transactions

Joe Perches (1):
      iwlagn: Convert kzalloc to kcalloc

Johannes Berg (22):
      iwlagn: move PCI-E transport files
      iwlagn: generically provide iwl_trans_send_cmd_pdu
      iwlagn: Makefile whitespace cleanup
      iwlagn: clean up PM code
      iwlagn: rename iwl-pci.h to iwl-cfg.h
      iwlagn: remove unused function declarations
      iwlagn: move sysfs files to debugfs
      iwlagn: remove drvdata support from bus layer
      iwlagn: do not use interruptible waits
      cfg80211: validate IBSS BSSID
      mac80211: fix AP/VLAN PS buffer race
      iwlagn: move scan code to scan file
      iwlagn: remove common station priv
      iwlagn: split remain-on-channel
      iwlagn: fix dangling scan request
      iwlagn: fix dangling scan request
      iwlagn: fix slot programming
      iwlagn: remove Kelvin support
      iwlagn: make iwl_scan_cancel_timeout void
      iwlagn: refactor scan complete
      iwlagn: move iwl_process_scan_complete up
      iwlagn: fix scan complete processing

John W. Linville (7):
      Merge branch 'for-linville' of git://github.com/lucacoelho/wl12xx
      Revert "ath9k: do not insert padding into tx buffers on AR9380+"
      Merge branch 'master' of git://git.infradead.org/users/linville/w=
ireless
      Merge branch 'master' of git://github.com/padovan/bluetooth-next
      Merge branch 'for-linville' of git://github.com/lucacoelho/wl12xx
      Merge branch 'master' of git://git.infradead.org/users/linville/w=
ireless
      Merge branch 'master' of git://git.infradead.org/users/linville/w=
ireless-next into for-davem

Jouni Malinen (4):
      cfg80211/nl80211: Add PMKSA caching candidate event
      cfg80211: Fix validation of AKM suites
      cfg80211: Remove strict validation of AKM suites
      cfg80211: Validate cipher suite against supported ciphers

Larry Finger (5):
      rtlwifi: rtl8192ce: Change modinfo messages
      rtlwifi: rtl8192se: Change modinfo messages
      rtlwifi: rtl8192de: Change modinfo messages
      rtlwifi: Combine instances of RTL_HAL_IS_CCK_RATE macros.
      rtlwifi: rtl8192cu: Fix unitialized struct

Luciano Coelho (5):
      wl12xx: remove deprecated CONFIG_WL12XX_HT flag
      wl12xx: add support for sched_scan filters
      wl12xx: increase number of allowed SSIDs in sched_scan
      wl12xx: ignore sched scan match sets without SSID
      wl12xx: fix forced passive scans

Luiz Augusto von Dentz (2):
      Bluetooth: make use of connection number to optimize the schedule=
r
      Bluetooth: mark l2cap_create_iframe_pdu as static

Mohammed Shafi Shajakhan (3):
      rfkill: properly assign a boolean type
      ath9k: Fix a dma warning/memory leak
      ath9k: add Block ACK bitmap in sample debug

Peter Hurley (1):
      Bluetooth: Add LE link type for debugfs output

Rafa=C5=82 Mi=C5=82ecki (10):
      bcma: cc: export more control functions
      b43: LCN-PHY: tweaks for channel switching
      b43: LCN-PHY: set TX filters
      b43: LCN-PHY: implement SPUR avoidance mode
      b43: LCN-PHY: init TX power control
      b43: LCN-PHY: add more init tweaks
      b43: LCN-PHY: finish sense setup
      b43: add missing MMIO defines
      b43: update dummy transmission
      b43: LCN-PHY: minor clean ups

Rajkumar Manoharan (9):
      ath9k_hw: Fix magnitude/phase coeff correction
      ath9k: load noise floor from history after the full chip reset
      ath9k: Reset caldata on radio enable
      mac80211: Fix regression on queue stop during 2040 bss change
      wireless: Do not allow disabled channel in scan request
      ath9k: Store noise immunity values across scanning
      ath9k_hw: Fix Rx DMA stuck for AR9003 chips
      nl80211/cfg80211: Add support to disable CCK rate for management =
frame
      mac80211: Send the management frame at requested rate

Randy Dunlap (1):
      nfc: NFC_WILINK depends on NFC_NCI

Shahar Levi (2):
      wl12xx: fix sdio_test module functionality
      wl12xx: Include OFDM rates in IBSS mode

Stanislaw Gruszka (2):
      iwlegacy: fix command queue timeout
      iwlegacy: do not use interruptible waits

Thomas Pedersen (1):
      mac80211: notify peer when shutting down peer link

Vinicius Costa Gomes (15):
      Bluetooth: Reset the security timer when a command is queued
      Bluetooth: Add a flag to indicate that SMP is going on
      Bluetooth: Use the same timeouts for both ACL and LE links
      Bluetooth: Add support for pairing via mgmt over LE
      Bluetooth: Add support for running SMP without a socket
      Bluetooth: Add link_type information to the mgmt Connected event
      Bluetooth: Move SMP fields to a separate structure
      Bluetooth: Move SMP crypto functions to a workqueue
      Bluetooth: Require authentication if MITM protection is requested
      Bluetooth: Use the MEDIUM security level for pairings
      Bluetooth: Fix sending wrong authentication requirements
      Bluetooth: Use the LTK after receiving a LE Security Request
      Revert "Bluetooth: Add support for communicating keys with usersp=
ace"
      Bluetooth: Fix not setting a pending security level
      Bluetooth: Remove support for other SMP keys than the LTK

Wey-Yi Guy (8):
      iwlagn: New SKU for 6005 SFF
      iwlagn: merge eeprom access into single file
      iwlagn: add support for v2 of temperature offset calibration
      iwlagn: use iwl_eeprom_calib_hdr structure
      iwlagn: fix stack corruption for temperature offset v2
      iwlagn: signedness bug
      MAINTAINERS: update iwlwifi
      iwlagn: add debugging to show probe related info in scan notifica=
tion

 MAINTAINERS                                        |    4 +-
 drivers/bcma/driver_chipcommon_pmu.c               |   38 +-
 drivers/net/wireless/adm8211.c                     |    3 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    6 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   10 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    1 +
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   32 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |    1 +
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   14 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   24 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |    7 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |  108 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   12 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   46 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    9 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    5 -
 drivers/net/wireless/ath/ath9k/hw.h                |    1 -
 drivers/net/wireless/ath/ath9k/init.c              |    1 -
 drivers/net/wireless/ath/ath9k/mac.c               |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    4 -
 drivers/net/wireless/ath/ath9k/main.c              |   11 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   10 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    4 -
 drivers/net/wireless/ath/ath9k/xmit.c              |   60 +-
 drivers/net/wireless/ath/carl9170/main.c           |    3 +-
 drivers/net/wireless/b43/b43.h                     |   40 +-
 drivers/net/wireless/b43/main.c                    |   54 +-
 drivers/net/wireless/b43/phy_lcn.c                 |  428 ++++-
 drivers/net/wireless/b43/phy_lcn.h                 |    3 +
 drivers/net/wireless/b43/tables_phy_lcn.c          |   25 +-
 drivers/net/wireless/iwlegacy/iwl-core.c           |    7 +-
 drivers/net/wireless/iwlegacy/iwl-core.h           |    3 +-
 drivers/net/wireless/iwlegacy/iwl-hcmd.c           |    2 +-
 drivers/net/wireless/iwlegacy/iwl-tx.c             |    4 +-
 drivers/net/wireless/iwlegacy/iwl3945-base.c       |    8 +-
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |   10 +-
 drivers/net/wireless/iwlwifi/Makefile              |   23 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    5 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   21 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |  299 ---
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  441 +-----
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |   22 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   39 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |   63 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  162 +--
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   19 +-
 drivers/net/wireless/iwlwifi/iwl-bus.h             |   72 +-
 .../net/wireless/iwlwifi/{iwl-pci.h =3D> iwl-cfg.h}  |    5 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    8 +
 drivers/net/wireless/iwlwifi/iwl-core.c            |   59 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   87 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   19 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  244 +++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    1 -
 drivers/net/wireless/iwlwifi/iwl-pci.c             |   33 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   97 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |  696 ++++++-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |  146 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   37 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |    5 +-
 .../{iwl-trans-int-pcie.h =3D> iwl-trans-pcie-int.h} |   26 +-
 .../{iwl-trans-rx-pcie.c =3D> iwl-trans-pcie-rx.c}   |   36 +-
 .../{iwl-trans-tx-pcie.c =3D> iwl-trans-pcie-tx.c}   |   92 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      | 1989 ++++++++++++=
++++++++
 drivers/net/wireless/iwlwifi/iwl-trans.c           | 1926 +-----------=
--------
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   44 +-
 drivers/net/wireless/libertas/cfg.c                |   33 +-
 drivers/net/wireless/libertas/dev.h                |    1 -
 drivers/net/wireless/mwifiex/cfg80211.c            |    7 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    3 +
 drivers/net/wireless/mwifiex/main.h                |    2 +-
 drivers/net/wireless/mwifiex/scan.c                |   29 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   16 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |    5 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    3 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |    5 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |    6 -
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h       |    6 -
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.h       |    6 -
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |   14 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/usb.c                 |    1 +
 drivers/net/wireless/rtlwifi/wifi.h                |    6 +
 drivers/net/wireless/wl12xx/Kconfig                |   10 -
 drivers/net/wireless/wl12xx/Makefile               |    6 +-
 drivers/net/wireless/wl12xx/acx.c                  |   40 +
 drivers/net/wireless/wl12xx/acx.h                  |   18 +
 drivers/net/wireless/wl12xx/cmd.c                  |   60 +-
 drivers/net/wireless/wl12xx/cmd.h                  |    7 +
 drivers/net/wireless/wl12xx/conf.h                 |   29 +-
 drivers/net/wireless/wl12xx/debugfs.c              |   88 +-
 drivers/net/wireless/wl12xx/event.c                |   39 +-
 drivers/net/wireless/wl12xx/init.c                 |   22 +-
 drivers/net/wireless/wl12xx/main.c                 |  300 +++-
 drivers/net/wireless/wl12xx/ps.c                   |    8 +-
 drivers/net/wireless/wl12xx/rx.c                   |    9 +-
 drivers/net/wireless/wl12xx/scan.c                 |  166 ++-
 drivers/net/wireless/wl12xx/sdio_test.c            |   15 +-
 drivers/net/wireless/wl12xx/tx.c                   |   60 +-
 drivers/net/wireless/wl12xx/tx.h                   |    9 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |   13 +-
 drivers/net/wireless/wl3501_cs.c                   |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |    2 +-
 drivers/nfc/Kconfig                                |   11 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/nfcwilink.c                            |  342 ++++
 drivers/nfc/pn533.c                                |    4 +-
 drivers/staging/brcm80211/brcmsmac/mac80211_if.c   |   12 +-
 drivers/staging/winbond/wbusb.c                    |    2 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |    9 +
 include/linux/ieee80211.h                          |   10 +
 include/linux/nfc.h                                |    6 +
 include/linux/nl80211.h                            |   46 +
 include/net/bluetooth/hci.h                        |   10 +
 include/net/bluetooth/hci_core.h                   |   25 +-
 include/net/bluetooth/l2cap.h                      |    8 +-
 include/net/bluetooth/mgmt.h                       |   16 +
 include/net/bluetooth/smp.h                        |   17 +
 include/net/cfg80211.h                             |   36 +-
 include/net/mac80211.h                             |   13 +-
 include/net/nfc/nci.h                              |  313 +++
 include/net/nfc/nci_core.h                         |  184 ++
 include/net/{ =3D> nfc}/nfc.h                        |    4 +
 net/bluetooth/hci_conn.c                           |    2 +-
 net/bluetooth/hci_core.c                           |   57 +-
 net/bluetooth/hci_event.c                          |   16 +-
 net/bluetooth/hci_sock.c                           |   18 +-
 net/bluetooth/hci_sysfs.c                          |    2 +
 net/bluetooth/hidp/core.c                          |    3 +
 net/bluetooth/l2cap_core.c                         |   18 +-
 net/bluetooth/mgmt.c                               |  212 ++-
 net/bluetooth/smp.c                                |  421 +++--
 net/mac80211/cfg.c                                 |   12 +-
 net/mac80211/debugfs.c                             |   52 -
 net/mac80211/debugfs_netdev.c                      |   48 +-
 net/mac80211/driver-ops.h                          |   27 +-
 net/mac80211/driver-trace.h                        |   40 +-
 net/mac80211/ibss.c                                |    6 +-
 net/mac80211/ieee80211_i.h                         |    5 +-
 net/mac80211/iface.c                               |   10 +-
 net/mac80211/mesh_plink.c                          |    8 +
 net/mac80211/mlme.c                                |   49 +-
 net/mac80211/rate.c                                |   29 +-
 net/mac80211/scan.c                                |    3 +-
 net/mac80211/util.c                                |   23 +-
 net/mac80211/work.c                                |    2 +-
 net/nfc/Kconfig                                    |    2 +
 net/nfc/Makefile                                   |    1 +
 net/nfc/core.c                                     |   77 +
 net/nfc/nci/Kconfig                                |   10 +
 net/nfc/nci/Makefile                               |    7 +
 net/nfc/nci/core.c                                 |  797 ++++++++
 net/nfc/nci/data.c                                 |  247 +++
 net/nfc/nci/lib.c                                  |   94 +
 net/nfc/nci/ntf.c                                  |  258 +++
 net/nfc/nci/rsp.c                                  |  226 +++
 net/nfc/netlink.c                                  |   56 +
 net/nfc/nfc.h                                      |    6 +-
 net/rfkill/core.c                                  |    2 +-
 net/wireless/core.h                                |    4 +-
 net/wireless/mlme.c                                |   16 +-
 net/wireless/nl80211.c                             |  100 +-
 net/wireless/nl80211.h                             |    4 +
 net/wireless/scan.c                                |   27 +
 net/wireless/sme.c                                 |   19 +-
 net/wireless/util.c                                |   16 +-
 186 files changed, 8573 insertions(+), 4415 deletions(-)
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
 rename drivers/net/wireless/iwlwifi/{iwl-pci.h =3D> iwl-cfg.h} (97%)
 rename drivers/net/wireless/iwlwifi/{iwl-trans-int-pcie.h =3D> iwl-tra=
ns-pcie-int.h} (94%)
 rename drivers/net/wireless/iwlwifi/{iwl-trans-rx-pcie.c =3D> iwl-tran=
s-pcie-rx.c} (97%)
 rename drivers/net/wireless/iwlwifi/{iwl-trans-tx-pcie.c =3D> iwl-tran=
s-pcie-tx.c} (94%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
 create mode 100644 drivers/nfc/nfcwilink.c
 create mode 100644 include/net/nfc/nci.h
 create mode 100644 include/net/nfc/nci_core.h
 rename include/net/{ =3D> nfc}/nfc.h (97%)
 create mode 100644 net/nfc/nci/Kconfig
 create mode 100644 net/nfc/nci/Makefile
 create mode 100644 net/nfc/nci/core.c
 create mode 100644 net/nfc/nci/data.c
 create mode 100644 net/nfc/nci/lib.c
 create mode 100644 net/nfc/nci/ntf.c
 create mode 100644 net/nfc/nci/rsp.c

Omnibus patch is (or should be) available here:

	http://bombadil.infradead.org/users/linville/wireless-next-2011-09-30.=
patch.gz

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
