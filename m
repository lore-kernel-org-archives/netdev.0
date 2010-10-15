From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-10-15
Date: Fri, 15 Oct 2010 16:40:50 -0400
Message-ID: <20101015204048.GC2438@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the latest batch of updates intended for 2.6.37.  As usual,
it is primarily a bunch of driver updates and fixes to code already
in -next.  This also includes a batch of Bluetooth updates courtesy
of Gustavo Padovan.  There is also the movement of the wl1251 driver
out of the wl12xx directory.  This is a prelude to the expansion of
the wl1271 code to cover some new hardware, all of which is actually
largely unrelated to wl1251.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 7662ff46b7b3678162ce125903115e4ab060=
7a2d:

  ixgbe: DCB: remove DCB check config (2010-10-15 09:27:38 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Andrei Emeltchenko (4):
      Bluetooth: remove extra newline from debug output
      Bluetooth: check L2CAP length in first ACL fragment
      Bluetooth: check for l2cap header in start fragment
      Bluetooth: clean up rfcomm code

Ben Greear (9):
      mac80211: Improve mlme probe response log messages.
      wireless: Set some stats used by /proc/net/wireless (wext)
      ath5k: Print out opmode in debugfs.
      ath5k: Adjust opmode when interfaces are removed.
      wireless: Print wiphy name in sysfs.
      ath5k: Move debugfs under ieee80211/[wiphy-name]
      ath9k: Fix potential use-after-free.
      ath9k: Remove bf_dmacontext.
      ath9k: Null out references to stale pointers.

Bj=C3=B6rn Smedman (3):
      mac80211: minstrel_ht A-MPDU fix
      ath9k: A-MPDU rate control info fix
      ath9k: built-in rate control A-MPDU fix

Christian Lamparter (5):
      mac80211: fix possible null-pointer de-reference
      mac80211: temporarily disable reorder release timer
      carl9170: common error path for bad frames
      carl9170: remove stale rx error path
      carl9170: A-MPDU frame type filter

David Vrabel (2):
      Bluetooth: HCI devices are either BR/EDR or AMP radios
      Bluetooth: Support SDIO devices that are AMP controllers

=46elix Fietkau (14):
      ath9k_hw: store the clock rate in common data on channel changes
      ath5k: store the clock rate in common data on channel changes
      ath9k_hw: move the cycle counter tracking to ath
      ath5k: use the common cycle counter / listen time implementation
      cfg80211: add channel utilization stats to the survey command
      ath9k: add compile time checking for the size of the channel list
      ath9k: implement channel utilization stats for survey
      ath9k: do not track cycle counter updates in powersave mode
      ath9k_hw: fix division by zero in the ANI monitor code
      ath9k_hw: fix PHY counter overflow handling in ANI v1
      ath9k: add missing locking around ath9k_hw_proc_mib_event
      ath9k: make rate control debugfs stats per station
      ath9k: remove sc->cur_rate_table and sc->cur_rate_mode
      ath9k_hw: remove enum wireless_mode and its users

Gerrit Renker (1):
      wext: fix alignment problem in serializing 'struct iw_point'

Gustavo F. Padovan (4):
      Bluetooth: remove unused variable from cmtp
      Bluetooth: make batostr() print in the right order
      Bluetooth: Use the proper error value from bt_skb_send_alloc()
      Bluetooth: update MAINTAINERS for Bluetooth subsys

Haijun Liu (1):
      Bluetooth: Update conf_state before send config_req out

Helmut Schaa (6):
      rt2x00: Shortcut link state updates when not operating as STA
      rt2x00: Optimize unmapping of skbs
      rt2x00: Use proper type for rxwi_w2 in rt2800_agc_to_rssi
      rt2x00: Use unlikely for error case in rt2x00queue_write_tx_frame
      rt2x00: Remove superfluous initialization of qidx
      rt2x00: Fix tx status handling in rt2800pci

Ivo van Doorn (7):
      rt2x00: Simplify Queue function arguments
      rt2x00: Move watchdog work to kernel work_queue
      rt2x00: Validate MCS on RX path
      rt2x00: Fix dead queue when skb allocation failed
      rt2x00: Make queue_entry flags access atomic
      rt2x00: Don't perform watchdog checks on empty queue
      rt2x00: Fix URB error handling

Jiri Slaby (1):
      WIRELESS: at76c50x, remove unneeded NULL check

Joe Perches (1):
      ath5k: fix build break from "ath5k: Print out opmode in debugfs"

Johan Hedberg (1):
      Bluetooth: Don't clear the blacklist when closing the HCI device

Johannes Berg (32):
      iwlagn: rename iwl_commit_rxon
      iwlwifi: introduce post_scan hook
      iwl3945: use iwl3945_commit_rxon
      iwlwifi: move chain settings to agn
      iwlwifi: rename iwl_mac_beacon_update
      iwlwifi: remove verify_signature eeprom operation
      iwlwifi: move agn specific station code there
      iwlwifi: move tx fail code to agn
      iwlwifi: remove spurious exports
      iwlwifi: remove agn rates info there
      iwlwifi: move iwl_toggle_rx_ant to agn
      iwlwifi: move iwl_dump_csr to agn
      iwlwifi: move iwl_dump_fh to agn
      iwlwifi: remove set_ct_kill operation
      iwlwifi: remove set_pwr_src operation
      iwlwifi: remove apm_ops.stop
      iwlwifi: clean up declarations
      iwlwifi: remove iwl_check_bits
      iwlwifi: fix dual-mode scanning
      Revert "wireless: Use first phyX name available when registering =
phy devices."
      mac80211: don't kmalloc 16 bytes
      iwl3945: fix queue allocation
      cfg80211: notify drivers about frame registrations
      mac80211: add probe request filter flag
      mac80211: fix SMPS request
      iwlwifi: allow probe-after-rx on 2.4 GHz
      iwlwifi: rename ibss_beacon variable
      iwlwifi: clean up some beacon handling
      iwlwifi: rewrite RXON checks
      iwlwifi: blink LED in IBSS mode
      iwlagn: check beacon frame size
      radiotap: fix vendor namespace parsing

John W. Linville (4):
      Merge branch 'wireless-next' of git://git.kernel.org/.../luca/wl1=
2xx
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-next-2.6 into for-davem
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (1):
      ath9k: Set RX filter for Probe Request based on filter flag

Julia Lawall (1):
      drivers/net/wireless/p54/eeprom.c: Return -ENOMEM on memory alloc=
ation failure

Kalle Valo (3):
      wl1251: create a copy of wl12xx_80211.h for wl1251
      wl1251: move to it's own directory
      wl1251: update the new location to the maintainers file

Karl Beldan (1):
      Bluetooth: hci_uart: Fix typo in stats for sco tx

Luis R. Rodriguez (1):
      ath9k_hw: remove AR9003 2.0 support

Mat Martineau (4):
      Bluetooth: Validate PSM values in calls to connect() and bind()
      Bluetooth: Add common code for stream-oriented recvmsg()
      Bluetooth: Use common SOCK_STREAM receive code in RFCOMM
      Bluetooth: Use a stream-oriented recvmsg with SOCK_STREAM L2CAP s=
ockets.

Mohammed Shafi Shajakhan (1):
      ath9k: Fix documentation in rate control

Nobuhiro Iwamatsu (2):
      Bluetooth: Add support Bluetooth controller of MacbookPro 6,2
      Bluetooth: Add support Bluetooth controller of MacbookPro 7,1

Ohad Ben-Cohen (2):
      wl1271: sdio: enable runtime PM
      wl1271: sdio: add suspend/resume support

Paul Fox (1):
      libertas: Communicate USB transfer errors

Rafa=C5=82 Mi=C5=82ecki (8):
      b43: N-PHY: grab more info about new channel
      b43: N-PHY: store info about current channel's type
      b43: N-PHY: fix logic in band switching
      b43: N-PHY: prepare for rev3+ channel tables
      b43: N-PHY: replace N-specific radio_chanspec with common code
      b43: N-PHY: fix typo: read table when caching IQ LO calibration (=
do not write)
      b43: N-PHY: put radio-specific code in separated file
      b43: N-PHY: put 2056-radio's specific code in separated file

Rajkumar Manoharan (1):
      ath9k_htc: set probe request rx filter

Shanyu Zhao (2):
      iwlagn: fix default calibration table size
      iwlagn: add temperature offset calib for 6000g2

Steve deRosier (1):
      mac80211: Update mesh constants to approved IEEE ANA values

Wey-Yi Guy (6):
      iwlagn: no version check for experimental uCode
      iiwlagn: always download priority table
      iwlagn: prio_tbl need to download before calibration
      iwlgn: need longer tx queue stuck timer for coex devices
      iwlagn: 6050 ops should be used;
      iwlwifi: move agn only eeprom functions to separate file

Yuri Kululin (1):
      Bluetooth: Fix RFCOMM RPN negotiation

 MAINTAINERS                                        |    8 +-
 drivers/bluetooth/btmrvl_main.c                    |    4 +-
 drivers/bluetooth/btsdio.c                         |    8 +
 drivers/bluetooth/btusb.c                          |    6 +
 drivers/bluetooth/hci_ldisc.c                      |    2 +-
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    1 +
 drivers/net/wireless/at76c50x-usb.c                |    3 +-
 drivers/net/wireless/ath/ath.h                     |   16 +
 drivers/net/wireless/ath/ath5k/ani.c               |   41 +-
 drivers/net/wireless/ath/ath5k/ani.h               |    5 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |    2 +-
 drivers/net/wireless/ath/ath5k/base.c              |   71 +-
 drivers/net/wireless/ath/ath5k/debug.c             |   49 +-
 drivers/net/wireless/ath/ath5k/debug.h             |   12 -
 drivers/net/wireless/ath/ath5k/pcu.c               |   13 +-
 drivers/net/wireless/ath/ath5k/phy.c               |    1 +
 drivers/net/wireless/ath/ath9k/ani.c               |  101 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    8 -
 .../net/wireless/ath/ath9k/ar9003_2p0_initvals.h   | 1784 ------------=
--------
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  162 +--
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    7 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    7 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   21 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   93 -
 drivers/net/wireless/ath/ath9k/debug.h             |   21 -
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   12 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    3 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   66 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   21 +-
 drivers/net/wireless/ath/ath9k/init.c              |   16 +-
 drivers/net/wireless/ath/ath9k/main.c              |  179 ++-
 drivers/net/wireless/ath/ath9k/rc.c                |  184 ++-
 drivers/net/wireless/ath/ath9k/rc.h                |   26 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   10 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   14 -
 drivers/net/wireless/ath/ath9k/xmit.c              |   38 +-
 drivers/net/wireless/ath/carl9170/rx.c             |   89 +-
 drivers/net/wireless/ath/carl9170/wlan.h           |   14 +-
 drivers/net/wireless/ath/debug.c                   |   29 +
 drivers/net/wireless/ath/debug.h                   |   10 +
 drivers/net/wireless/ath/hw.c                      |   59 +
 drivers/net/wireless/ath/reg.h                     |   11 +
 drivers/net/wireless/b43/Makefile                  |    2 +
 drivers/net/wireless/b43/phy_common.h              |    5 +-
 drivers/net/wireless/b43/phy_n.c                   |  128 +-
 drivers/net/wireless/b43/phy_n.h                   |  218 +---
 drivers/net/wireless/b43/radio_2055.c              | 1332 ++++++++++++=
+++
 drivers/net/wireless/b43/radio_2055.h              |  254 +++
 drivers/net/wireless/b43/radio_2056.c              |   43 +
 drivers/net/wireless/b43/radio_2056.h              |   42 +
 drivers/net/wireless/b43/tables_nphy.c             | 1311 +-----------=
---
 drivers/net/wireless/b43/tables_nphy.h             |   59 +-
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   76 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   27 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   62 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |    2 +-
 .../iwlwifi/{iwl-calib.h =3D> iwl-agn-calib.h}       |    4 +
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |  454 +++++
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  372 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   69 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |   10 -
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |  716 ++++++++
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |    5 -
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   40 +
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |   28 +
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  106 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   71 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   13 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  531 +-----
 drivers/net/wireless/iwlwifi/iwl-core.h            |   49 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    1 -
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   16 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  381 +----
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    8 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |    5 -
 drivers/net/wireless/iwlwifi/iwl-rx.c              |    1 -
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |  725 +--------
 drivers/net/wireless/iwlwifi/iwl-sta.h             |   35 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   38 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   97 +-
 drivers/net/wireless/libertas/if_usb.c             |    4 +-
 drivers/net/wireless/p54/eeprom.c                  |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   18 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   87 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   11 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |   12 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   56 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   54 +-
 drivers/net/wireless/wl1251/Kconfig                |   33 +
 drivers/net/wireless/wl1251/Makefile               |    6 +
 .../wireless/{wl12xx/wl1251_acx.c =3D> wl1251/acx.c} |    8 +-
 .../wireless/{wl12xx/wl1251_acx.h =3D> wl1251/acx.h} |    2 +-
 .../{wl12xx/wl1251_boot.c =3D> wl1251/boot.c}        |   12 +-
 .../{wl12xx/wl1251_boot.h =3D> wl1251/boot.h}        |    0
 .../wireless/{wl12xx/wl1251_cmd.c =3D> wl1251/cmd.c} |   10 +-
 .../wireless/{wl12xx/wl1251_cmd.h =3D> wl1251/cmd.h} |    0
 .../{wl12xx/wl1251_debugfs.c =3D> wl1251/debugfs.c}  |    6 +-
 .../{wl12xx/wl1251_debugfs.h =3D> wl1251/debugfs.h}  |    0
 .../{wl12xx/wl1251_event.c =3D> wl1251/event.c}      |    8 +-
 .../{wl12xx/wl1251_event.h =3D> wl1251/event.h}      |    0
 .../{wl12xx/wl1251_init.c =3D> wl1251/init.c}        |    8 +-
 .../{wl12xx/wl1251_init.h =3D> wl1251/init.h}        |    0
 .../wireless/{wl12xx/wl1251_io.c =3D> wl1251/io.c}   |    4 +-
 .../wireless/{wl12xx/wl1251_io.h =3D> wl1251/io.h}   |    0
 .../{wl12xx/wl1251_main.c =3D> wl1251/main.c}        |   20 +-
 .../wireless/{wl12xx/wl1251_ps.c =3D> wl1251/ps.c}   |    8 +-
 .../wireless/{wl12xx/wl1251_ps.h =3D> wl1251/ps.h}   |    2 +-
 .../wireless/{wl12xx/wl1251_reg.h =3D> wl1251/reg.h} |    0
 .../wireless/{wl12xx/wl1251_rx.c =3D> wl1251/rx.c}   |   10 +-
 .../wireless/{wl12xx/wl1251_rx.h =3D> wl1251/rx.h}   |    0
 .../{wl12xx/wl1251_sdio.c =3D> wl1251/sdio.c}        |    0
 .../wireless/{wl12xx/wl1251_spi.c =3D> wl1251/spi.c} |    4 +-
 .../wireless/{wl12xx/wl1251_spi.h =3D> wl1251/spi.h} |    6 +-
 .../wireless/{wl12xx/wl1251_tx.c =3D> wl1251/tx.c}   |    8 +-
 .../wireless/{wl12xx/wl1251_tx.h =3D> wl1251/tx.h}   |    2 +-
 drivers/net/wireless/{wl12xx =3D> wl1251}/wl1251.h   |    0
 drivers/net/wireless/wl1251/wl12xx_80211.h         |  156 ++
 drivers/net/wireless/wl12xx/Kconfig                |   34 -
 drivers/net/wireless/wl12xx/Makefile               |    9 -
 drivers/net/wireless/wl12xx/wl1271_sdio.c          |   43 +-
 include/linux/ieee80211.h                          |   71 +-
 include/linux/mmc/sdio_ids.h                       |    1 +
 include/linux/nl80211.h                            |   15 +
 include/linux/wireless.h                           |    2 +-
 include/net/bluetooth/bluetooth.h                  |    2 +
 include/net/bluetooth/hci.h                        |    2 +-
 include/net/bluetooth/rfcomm.h                     |    5 -
 include/net/cfg80211.h                             |   31 +
 include/net/mac80211.h                             |    9 +-
 net/bluetooth/af_bluetooth.c                       |  109 ++
 net/bluetooth/cmtp/core.c                          |    6 +-
 net/bluetooth/hci_core.c                           |    1 -
 net/bluetooth/hci_sysfs.c                          |   21 +-
 net/bluetooth/hidp/core.c                          |    8 +-
 net/bluetooth/l2cap.c                              |   56 +-
 net/bluetooth/lib.c                                |    4 +-
 net/bluetooth/rfcomm/core.c                        |   39 +-
 net/bluetooth/rfcomm/sock.c                        |  104 +--
 net/bluetooth/rfcomm/tty.c                         |    4 +-
 net/mac80211/cfg.c                                 |   22 +-
 net/mac80211/ht.c                                  |    2 +
 net/mac80211/ieee80211_i.h                         |    4 +-
 net/mac80211/iface.c                               |    9 +-
 net/mac80211/main.c                                |    3 +
 net/mac80211/mesh_plink.c                          |   17 +-
 net/mac80211/mlme.c                                |   18 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    7 +-
 net/mac80211/rx.c                                  |   24 +
 net/mac80211/wep.c                                 |    8 +-
 net/wireless/core.c                                |   54 +-
 net/wireless/mlme.c                                |   23 +-
 net/wireless/nl80211.c                             |   15 +
 net/wireless/radiotap.c                            |   58 +-
 net/wireless/sysfs.c                               |    9 +
 net/wireless/wext-compat.c                         |    4 +
 169 files changed, 5491 insertions(+), 6553 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/ath9k/ar9003_2p0_initvals.=
h
 create mode 100644 drivers/net/wireless/b43/radio_2055.c
 create mode 100644 drivers/net/wireless/b43/radio_2055.h
 create mode 100644 drivers/net/wireless/b43/radio_2056.c
 create mode 100644 drivers/net/wireless/b43/radio_2056.h
 rename drivers/net/wireless/iwlwifi/{iwl-calib.h =3D> iwl-agn-calib.h}=
 (95%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-sta.c
 create mode 100644 drivers/net/wireless/wl1251/Kconfig
 create mode 100644 drivers/net/wireless/wl1251/Makefile
 rename drivers/net/wireless/{wl12xx/wl1251_acx.c =3D> wl1251/acx.c} (9=
9%)
 rename drivers/net/wireless/{wl12xx/wl1251_acx.h =3D> wl1251/acx.h} (9=
9%)
 rename drivers/net/wireless/{wl12xx/wl1251_boot.c =3D> wl1251/boot.c} =
(99%)
 rename drivers/net/wireless/{wl12xx/wl1251_boot.h =3D> wl1251/boot.h} =
(100%)
 rename drivers/net/wireless/{wl12xx/wl1251_cmd.c =3D> wl1251/cmd.c} (9=
8%)
 rename drivers/net/wireless/{wl12xx/wl1251_cmd.h =3D> wl1251/cmd.h} (1=
00%)
 rename drivers/net/wireless/{wl12xx/wl1251_debugfs.c =3D> wl1251/debug=
fs.c} (99%)
 rename drivers/net/wireless/{wl12xx/wl1251_debugfs.h =3D> wl1251/debug=
fs.h} (100%)
 rename drivers/net/wireless/{wl12xx/wl1251_event.c =3D> wl1251/event.c=
} (97%)
 rename drivers/net/wireless/{wl12xx/wl1251_event.h =3D> wl1251/event.h=
} (100%)
 rename drivers/net/wireless/{wl12xx/wl1251_init.c =3D> wl1251/init.c} =
(98%)
 rename drivers/net/wireless/{wl12xx/wl1251_init.h =3D> wl1251/init.h} =
(100%)
 rename drivers/net/wireless/{wl12xx/wl1251_io.c =3D> wl1251/io.c} (99%=
)
 rename drivers/net/wireless/{wl12xx/wl1251_io.h =3D> wl1251/io.h} (100=
%)
 rename drivers/net/wireless/{wl12xx/wl1251_main.c =3D> wl1251/main.c} =
(99%)
 rename drivers/net/wireless/{wl12xx/wl1251_ps.c =3D> wl1251/ps.c} (97%=
)
 rename drivers/net/wireless/{wl12xx/wl1251_ps.h =3D> wl1251/ps.h} (97%=
)
 rename drivers/net/wireless/{wl12xx/wl1251_reg.h =3D> wl1251/reg.h} (1=
00%)
 rename drivers/net/wireless/{wl12xx/wl1251_rx.c =3D> wl1251/rx.c} (97%=
)
 rename drivers/net/wireless/{wl12xx/wl1251_rx.h =3D> wl1251/rx.h} (100=
%)
 rename drivers/net/wireless/{wl12xx/wl1251_sdio.c =3D> wl1251/sdio.c} =
(100%)
 rename drivers/net/wireless/{wl12xx/wl1251_spi.c =3D> wl1251/spi.c} (9=
9%)
 rename drivers/net/wireless/{wl12xx/wl1251_spi.h =3D> wl1251/spi.h} (9=
6%)
 rename drivers/net/wireless/{wl12xx/wl1251_tx.c =3D> wl1251/tx.c} (99%=
)
 rename drivers/net/wireless/{wl12xx/wl1251_tx.h =3D> wl1251/tx.h} (99%=
)
 rename drivers/net/wireless/{wl12xx =3D> wl1251}/wl1251.h (100%)
 create mode 100644 drivers/net/wireless/wl1251/wl12xx_80211.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-10-15.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
