From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-03-04
Date: Fri, 4 Mar 2011 14:40:18 -0500
Message-ID: <20110304194018.GD9866@tuxdriver.com>
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

Yet another batch of new wireless bits intended for 2.6.39... :-)

Highlights in this round include AP-mode support for wl12xx, some
rtlwifi fixes (many build-related), some more b43 N-phy support
advancement, a big batch of ath9k_htc updates, and the refactoring of
iwlwifi to separate iwl3945 and iwl4965 support out into a new iwlegacy
driver.  Mixed-in, of course, is the usual batch of various driver and
mac80211 updates and fixes.

Please let me know if there are problems!

John

---

The following changes since commit 29546a6404e3a4b5d13f0a9586eb5cf1c3b2=
5167:

  ipv6: Use ERR_CAST in addrconf_dst_alloc. (2011-03-03 12:10:37 -0800)

are available in the git repository at:
  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-ne=
xt-2.6.git for-davem

Alessio Igor Bogani (2):
      rtlwifi: Add the missing rcu_read_lock/unlock
      rtlwifi: fix places where uninitialized data is used

Arik Nemtsov (9):
      wl12xx: avoid blocking while holding rcu lock on bss info change
      wl12xx: fix potential race condition with TX queue watermark
      wl12xx: AP-mode - fix race condition on sta connection
      wl12xx: AP-mode - TX queue per link in AC
      wl12xx: report invalid TX rate when returning non-TX-ed skbs
      wl12xx: AP-mode - support HW based link PS monitoring
      wl12xx: AP mode - fix bug in cleanup of wl1271_op_sta_add()
      wl12xx: AP-mode - count free FW TX blocks per link
      wl12xx: AP-mode - management of links in PS-mode

Chaoming Li (1):
      rtlwifi: Fix error registering rate-control

Christian Lamparter (1):
      p54: implement set_coverage_class

Dan Carpenter (2):
      wl12xx: change type from u8 to int
      iwlwifi: remove duplicate initialization

Eliad Peller (4):
      wl12xx: fix identification of beacon packets (debug)
      wl12xx: declare support for IEEE80211_HW_REPORTS_TX_ACK_STATUS
      wl12xx: use standard ALIGN() macro
      wl12xx: always set mac_address when configuring ht caps

=46elix Fietkau (4):
      p54: fix a NULL pointer dereference bug
      ath9k: use generic mac80211 LED blinking code
      cfg80211: add a field for the bitrate of the last rx data packet =
from a station
      mac80211: add support for showing the last rx bitrate

Gery Kahn (1):
      wl12xx: update PLT initialization for new firmware

Gustavo F. Padovan (1):
      Bluetooth: Fix BT_L2CAP and BT_SCO in Kconfig

Joe Gunn (1):
      orinoco: Drop scan results with unknown channels

Johannes Berg (8):
      mac80211: rename RX_FLAG_TSFT
      rtl8192c: fix compilation errors
      mac80211: make tx() operation return void
      mac80211: remove IBSS merge delay
      mac80211: copy peer MCS TX parameters
      iwlagn: fix iwlagn_check_needed_chains
      mac80211: support direct offchannel TX offload
      mac80211: make rate control Kconfig warning depend on mac80211

John W. Linville (6):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      iwlegacy: change some symbols duplicated from iwlwifi directory
      at76c50x-usb: fix warning caused by at76_mac80211_tx now returnin=
g void
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Larry Finger (1):
      rtlwifi: rtl8192ce: rtl8192cu: Fix multiple def errors for allyes=
config build

Luciano Coelho (1):
      wl12xx: fix MODULE_AUTHOR email address

Nishant Sarmukadam (3):
      mwl8k: fix rf_antenna rx argument for AP
      mwl8k: Tell mac80211 we have rate adaptation in FW
      mwl8k: Invert tx queues for set_hw_spec and set_edca_params

Rafa=C5=82 Mi=C5=82ecki (5):
      b43: N-PHY: fix 0x2055 radio workaround condition
      b43: N-PHY: rev1: enable some gain ctl workarounds
      b43: N-PHY: rev1: restore PHY state after RSSI operations
      b43: fill PHY ctl word1 in TX header for N-PHY
      b43: N-PHY: rev3+: add static tables

Senthil Balasubramanian (1):
      ath9k: Fix incorrect GPIO LED pin for AR9485

Stanislaw Gruszka (7):
      iwlegacy: do not set tx power when channel is changing
      mac80211: better fix for conn_mon_timer running after disassociat=
e
      iwlwifi: fix dma mappings and skbs leak
      iwlegacy: fix dma mappings and skbs leak
      iwlwifi: add {ack,plpc}_check module parameters
      iwlwifi: move check health code into iwl-rx.c
      iwlwifi: move remaining iwl-agn-rx.c code into iwl-rx.c

Sujith Manoharan (22):
      ath9k_htc: Handle storage devices
      ath9k_htc: Allow upto two simultaneous interfaces
      ath9k_htc: Unify target capability updating
      ath9k_htc: Fix error handling in add_interface
      ath9k_htc: Remove OP_PREAMBLE_SHORT
      ath9k_htc: Remove OP_PROTECT_ENABLE
      ath9k_htc: Remove OP_ASSOCIATED variable
      ath9k_htc: Set the BSSID mask for multiple interfaces
      ath9k_htc: Make sequence number calculation per-VIF
      ath9k_htc: Use VIF from the packet's control data
      ath9k_htc: Protect ampdu_action with a mutex
      ath9k_htc: Maintain individual counters for interfaces
      ath9k_htc: Allow AP interface to be created
      ath9k_htc: Calculate and set the HW opmode
      ath9k_htc: Add ANI for AP mode
      ath9k_htc: Configure beacon timers in AP mode
      ath9k_htc: Fix TBTT calculation for IBSS mode
      ath9k_htc: Fix host RX initialization
      ath9k_htc: Fix RX filters
      ath9k_htc: Add debug code to print endpoint mapping
      ath9k_htc: Fix error path in URB allocation
      ath9k_htc: Handle BSSID/AID for multiple interfaces

Vivek Natarajan (4):
      mac80211: Fix a race on enabling power save.
      ath9k_hw: Fix pcie_serdes setting for AR9485 1.1 version.
      ath9k: Cancel pll_work while disabling radio.
      ath9k: Fix compilation warning.

Wey-Yi Guy (11):
      iwlwifi: Limit number of firmware reload
      iwlwifi: Loading correct uCode again when fail to load
      iwlwifi: enable 2-wire bt coex support for non-combo device
      iwlwifi: split the drivers for agn and legacy devices 3945/4965
      Revert "iwlwifi: split the drivers for agn and legacy devices 394=
5/4965"
      iwlwifi: split the drivers for agn and legacy devices 3945/4965
      iwlagn: name change for BT config command
      iwlagn: add bt config structure support for 2000 series
      iwlagn: add BT Session Activity 2 UART message (BT -> WiFi)
      iwlagn: split BT page and inquiry UART msg
      iwlagn: enable BT session 2 type UART for 2000 series

Willy Tarreau (4):
      rtlwifi: Fix build when RTL8192CU is selected, but RTL8192CE is n=
ot
      rtl8192cu: fix build error (vmalloc/vfree undefined)
      rtlwifi: Let rtlwifi build when PCI is not enabled
      rtlwifi: Eliminate udelay calls with too large values

 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    5 +-
 drivers/net/wireless/adm8211.c                     |    4 +-
 drivers/net/wireless/at76c50x-usb.c                |   10 +-
 drivers/net/wireless/ath/ar9170/ar9170.h           |    2 +-
 drivers/net/wireless/ath/ar9170/main.c             |    5 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |    4 +-
 drivers/net/wireless/ath/ath5k/base.c              |    7 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    8 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   43 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |  166 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   78 +-
 drivers/net/wireless/ath/ath9k/htc.h               |   77 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |  170 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   19 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  452 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   84 +-
 drivers/net/wireless/ath/ath9k/init.c              |   22 +
 drivers/net/wireless/ath/ath9k/main.c              |   15 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    1 +
 drivers/net/wireless/ath/ath9k/wmi.c               |    4 -
 drivers/net/wireless/ath/carl9170/carl9170.h       |    2 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    5 +-
 drivers/net/wireless/b43/main.c                    |    6 +-
 drivers/net/wireless/b43/phy_n.c                   |   28 +-
 drivers/net/wireless/b43/tables_nphy.c             | 1106 ++++++-
 drivers/net/wireless/b43/tables_nphy.h             |   27 +
 drivers/net/wireless/b43/xmit.c                    |   75 +-
 drivers/net/wireless/b43/xmit.h                    |    6 +
 drivers/net/wireless/b43legacy/main.c              |    5 +-
 drivers/net/wireless/b43legacy/xmit.c              |    2 +-
 drivers/net/wireless/iwlegacy/Kconfig              |  116 +
 drivers/net/wireless/iwlegacy/Makefile             |   25 +
 .../{iwlwifi =3D> iwlegacy}/iwl-3945-debugfs.c       |   11 +-
 .../{iwlwifi =3D> iwlegacy}/iwl-3945-debugfs.h       |    4 +-
 .../wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-fh.h   |    5 +-
 .../wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-hw.h   |    9 +-
 .../wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-led.c  |    4 +-
 .../wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-led.h  |    2 +-
 .../wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-rs.c   |   41 +-
 .../net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945.c  |  253 +-
 .../net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945.h  |   12 +-
 drivers/net/wireless/iwlegacy/iwl-4965-calib.c     |  967 ++++++
 .../iwl-legacy.h =3D> iwlegacy/iwl-4965-calib.h}     |   30 +-
 drivers/net/wireless/iwlegacy/iwl-4965-debugfs.c   |  774 +++++
 .../iwl-4965-debugfs.h}                            |   35 +-
 .../iwl-legacy.h =3D> iwlegacy/iwl-4965-eeprom.c}    |  107 +-
 .../wireless/{iwlwifi =3D> iwlegacy}/iwl-4965-hw.h   |   26 +-
 .../iwl-3945-led.c =3D> iwlegacy/iwl-4965-led.c}     |   30 +-
 .../rtl8192cu/fw.c =3D> iwlegacy/iwl-4965-led.h}     |   17 +-
 drivers/net/wireless/iwlegacy/iwl-4965-lib.c       | 1260 +++++++
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c        | 2870 ++++++++++++=
++++
 .../iwl-agn-rx.c =3D> iwlegacy/iwl-4965-rx.c}        |  172 +-
 drivers/net/wireless/iwlegacy/iwl-4965-sta.c       |  721 ++++
 drivers/net/wireless/iwlegacy/iwl-4965-tx.c        | 1369 ++++++++
 drivers/net/wireless/iwlegacy/iwl-4965-ucode.c     |  166 +
 .../net/wireless/{iwlwifi =3D> iwlegacy}/iwl-4965.c  |  806 +----
 drivers/net/wireless/iwlegacy/iwl-4965.h           |  282 ++
 drivers/net/wireless/iwlegacy/iwl-commands.h       | 3405 ++++++++++++=
++++++
 drivers/net/wireless/iwlegacy/iwl-core.c           | 2674 ++++++++++++=
++
 drivers/net/wireless/iwlegacy/iwl-core.h           |  646 ++++
 drivers/net/wireless/iwlegacy/iwl-csr.h            |  422 +++
 drivers/net/wireless/iwlegacy/iwl-debug.h          |  198 ++
 drivers/net/wireless/iwlegacy/iwl-debugfs.c        | 1467 ++++++++
 drivers/net/wireless/iwlegacy/iwl-dev.h            | 1426 ++++++++
 .../iwl-3945-led.h =3D> iwlegacy/iwl-devtrace.c}     |   23 +-
 drivers/net/wireless/iwlegacy/iwl-devtrace.h       |  270 ++
 drivers/net/wireless/iwlegacy/iwl-eeprom.c         |  561 +++
 drivers/net/wireless/iwlegacy/iwl-eeprom.h         |  344 ++
 drivers/net/wireless/iwlegacy/iwl-fh.h             |  513 +++
 drivers/net/wireless/iwlegacy/iwl-hcmd.c           |  271 ++
 drivers/net/wireless/iwlegacy/iwl-helpers.h        |  181 +
 drivers/net/wireless/iwlegacy/iwl-io.h             |  545 +++
 drivers/net/wireless/iwlegacy/iwl-led.c            |  188 +
 .../{iwlwifi/iwl-3945-led.h =3D> iwlegacy/iwl-led.h} |   34 +-
 drivers/net/wireless/iwlegacy/iwl-legacy-rs.h      |  456 +++
 drivers/net/wireless/iwlegacy/iwl-power.c          |  165 +
 .../iwl-3945-led.c =3D> iwlegacy/iwl-power.h}        |   61 +-
 drivers/net/wireless/iwlegacy/iwl-prph.h           |  523 +++
 drivers/net/wireless/iwlegacy/iwl-rx.c             |  302 ++
 drivers/net/wireless/iwlegacy/iwl-scan.c           |  625 ++++
 drivers/net/wireless/iwlegacy/iwl-spectrum.h       |   92 +
 drivers/net/wireless/iwlegacy/iwl-sta.c            |  816 +++++
 drivers/net/wireless/iwlegacy/iwl-sta.h            |  148 +
 drivers/net/wireless/iwlegacy/iwl-tx.c             |  660 ++++
 .../wireless/{iwlwifi =3D> iwlegacy}/iwl3945-base.c  |  543 ++--
 drivers/net/wireless/iwlegacy/iwl4965-base.c       | 3632 ++++++++++++=
++++++++
 drivers/net/wireless/iwlwifi/Kconfig               |  124 +-
 drivers/net/wireless/iwlwifi/Makefile              |   41 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    2 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    4 -
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    4 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   81 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   58 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  110 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |  108 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   76 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    2 -
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   13 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    8 -
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    5 -
 drivers/net/wireless/iwlwifi/iwl-led.c             |    2 -
 drivers/net/wireless/iwlwifi/iwl-legacy.c          |  657 ----
 drivers/net/wireless/iwlwifi/iwl-power.c           |    3 -
 drivers/net/wireless/iwlwifi/iwl-rx.c              |  392 ++-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   10 -
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   11 -
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   78 +-
 drivers/net/wireless/libertas_tf/main.c            |    3 +-
 drivers/net/wireless/mac80211_hwsim.c              |    5 +-
 drivers/net/wireless/mwl8k.c                       |   54 +-
 drivers/net/wireless/orinoco/scan.c                |    5 +
 drivers/net/wireless/p54/eeprom.c                  |    7 +-
 drivers/net/wireless/p54/fwio.c                    |    9 +-
 drivers/net/wireless/p54/lmac.h                    |    2 +-
 drivers/net/wireless/p54/main.c                    |   14 +-
 drivers/net/wireless/p54/p54.h                     |    1 +
 drivers/net/wireless/p54/txrx.c                    |   13 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    5 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   10 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |    8 +-
 drivers/net/wireless/rtlwifi/Kconfig               |    7 +
 drivers/net/wireless/rtlwifi/Makefile              |    8 +-
 drivers/net/wireless/rtlwifi/base.c                |   15 +-
 drivers/net/wireless/rtlwifi/core.c                |    9 +-
 drivers/net/wireless/rtlwifi/efuse.c               |   18 -
 drivers/net/wireless/rtlwifi/efuse.h               |    3 -
 drivers/net/wireless/rtlwifi/rtl8192c/Makefile     |    9 +
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h  |  204 ++
 .../{rtl8192ce/fw.c =3D> rtl8192c/fw_common.c}       |   13 +-
 .../{rtl8192ce/fw.h =3D> rtl8192c/fw_common.h}       |    0
 .../rtlwifi/{rtl8192cu/fw.h =3D> rtl8192c/main.c}    |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  137 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |  246 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |   11 +
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |   31 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |   28 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h        |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   15 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.h        |   12 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   13 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |    9 +
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |   38 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.h       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h        |   19 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   17 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h        |   18 +
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    7 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   12 +
 drivers/net/wireless/wl1251/main.c                 |    4 +-
 drivers/net/wireless/wl1251/rx.c                   |    2 +-
 drivers/net/wireless/wl12xx/acx.c                  |   28 +-
 drivers/net/wireless/wl12xx/acx.h                  |    9 +
 drivers/net/wireless/wl12xx/init.c                 |    2 +-
 drivers/net/wireless/wl12xx/main.c                 |  151 +-
 drivers/net/wireless/wl12xx/ps.c                   |   78 +
 drivers/net/wireless/wl12xx/ps.h                   |    2 +
 drivers/net/wireless/wl12xx/rx.c                   |    6 +-
 drivers/net/wireless/wl12xx/rx.h                   |    4 -
 drivers/net/wireless/wl12xx/tx.c                   |  237 ++-
 drivers/net/wireless/wl12xx/tx.h                   |    5 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |   37 +
 drivers/net/wireless/zd1211rw/zd_mac.c             |    5 +-
 drivers/staging/brcm80211/sys/wl_mac80211.c        |   28 +-
 drivers/staging/brcm80211/sys/wlc_mac80211.c       |    5 +-
 drivers/staging/winbond/wbusb.c                    |    7 +-
 include/linux/nl80211.h                            |    3 +
 include/net/cfg80211.h                             |    5 +-
 include/net/mac80211.h                             |   21 +-
 net/bluetooth/Kconfig                              |    6 +-
 net/mac80211/Kconfig                               |    2 +-
 net/mac80211/cfg.c                                 |   68 +-
 net/mac80211/driver-ops.h                          |   35 +-
 net/mac80211/driver-trace.h                        |   33 +
 net/mac80211/ht.c                                  |    5 +-
 net/mac80211/ibss.c                                |    7 +-
 net/mac80211/ieee80211_i.h                         |    1 +
 net/mac80211/mlme.c                                |   23 +-
 net/mac80211/rx.c                                  |   15 +-
 net/mac80211/sta_info.h                            |    4 +
 net/mac80211/status.c                              |    6 +-
 net/mac80211/tx.c                                  |  164 +-
 net/wireless/nl80211.c                             |   56 +-
 201 files changed, 34374 insertions(+), 3387 deletions(-)
 create mode 100644 drivers/net/wireless/iwlegacy/Kconfig
 create mode 100644 drivers/net/wireless/iwlegacy/Makefile
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-debugfs.c=
 (99%)
 copy drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-debugfs.h (=
95%)
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-fh.h (98%=
)
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-hw.h (96%=
)
 copy drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-led.c (94%)
 copy drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-led.h (95%)
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945-rs.c (96%=
)
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945.c (92%)
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-3945.h (97%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-calib.c
 copy drivers/net/wireless/{iwlwifi/iwl-legacy.h =3D> iwlegacy/iwl-4965=
-calib.h} (80%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-debugfs.c
 rename drivers/net/wireless/{iwlwifi/iwl-3945-debugfs.h =3D> iwlegacy/=
iwl-4965-debugfs.h} (61%)
 rename drivers/net/wireless/{iwlwifi/iwl-legacy.h =3D> iwlegacy/iwl-49=
65-eeprom.c} (53%)
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-4965-hw.h (97%=
)
 copy drivers/net/wireless/{iwlwifi/iwl-3945-led.c =3D> iwlegacy/iwl-49=
65-led.c} (73%)
 rename drivers/net/wireless/{rtlwifi/rtl8192cu/fw.c =3D> iwlegacy/iwl-=
4965-led.h} (71%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-lib.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-rs.c
 rename drivers/net/wireless/{iwlwifi/iwl-agn-rx.c =3D> iwlegacy/iwl-49=
65-rx.c} (60%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-sta.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-tx.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-ucode.c
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl-4965.c (71%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-4965.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-commands.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-core.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-core.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-csr.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-debug.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-debugfs.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-dev.h
 copy drivers/net/wireless/{iwlwifi/iwl-3945-led.h =3D> iwlegacy/iwl-de=
vtrace.c} (59%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-devtrace.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-eeprom.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-eeprom.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-fh.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-hcmd.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-helpers.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-io.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-led.c
 rename drivers/net/wireless/{iwlwifi/iwl-3945-led.h =3D> iwlegacy/iwl-=
led.h} (59%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-legacy-rs.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-power.c
 rename drivers/net/wireless/{iwlwifi/iwl-3945-led.c =3D> iwlegacy/iwl-=
power.h} (56%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-prph.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-rx.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-scan.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-spectrum.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-sta.c
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-sta.h
 create mode 100644 drivers/net/wireless/iwlegacy/iwl-tx.c
 rename drivers/net/wireless/{iwlwifi =3D> iwlegacy}/iwl3945-base.c (90=
%)
 create mode 100644 drivers/net/wireless/iwlegacy/iwl4965-base.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-legacy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192c/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
 rename drivers/net/wireless/rtlwifi/{rtl8192ce/fw.c =3D> rtl8192c/fw_c=
ommon.c} (98%)
 rename drivers/net/wireless/rtlwifi/{rtl8192ce/fw.h =3D> rtl8192c/fw_c=
ommon.h} (100%)
 rename drivers/net/wireless/rtlwifi/{rtl8192cu/fw.h =3D> rtl8192c/main=
=2Ec} (75%)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-03-04.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
