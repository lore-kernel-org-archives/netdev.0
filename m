From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-12-22
Date: Wed, 22 Dec 2010 15:23:23 -0500
Message-ID: <20101222202323.GF10046@tuxdriver.com>
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

Here is another monster round of udpates intended for 2.6.28...phew!
And the patches are still coming...

The biggest point of interest in this pull is the new rtlwifi family
of drivers for hardware from Realtek, along with the first member of
that family (rtl8192ce).  Also, the b43 N-phy support continues to
roll forward towards usability.  There are, of course, the usual driver
updates for ath9k, rt2x00, iwlwifi, wl1271, and several others.  There
are also the usual handful (or two) of mac80211 updates, including
some mesh fixes from Javier and support for a throughput-based LED
trigger from Johannes.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 503b1a529a6b62b31904bab4699752c523cf=
76b2:

  Merge branch '20101221_static_const' of git://repo.or.cz/linux-2.6/tr=
ivial-mods (2010-12-21 13:26:15 -0800)

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-ne=
xt-2.6.git for-davem

Anisse Astier (1):
      rtl8192ce: Fix typo in Kconfig description

Bing Zhao (1):
      ieee80211: add Parameter Set Count bitmask

Bruno Randolf (5):
      cfg80211: Add antenna availability information
      ath5k: Fix survey
      cfg80211: Separate available antennas for RX and TX
      nl80211: Export available antennas
      ath5k: Set available antenna information for cfg80211

Dan Carpenter (1):
      wl1251: wl12xx_get_platform_data() returns an ERR_PTR

Eliad Peller (4):
      wl1271: use debugfs_remove_recursive
      wl1271: move wl12xx debugfs directory to under wiphy's debugfs
      wl12xx: add auto-arp support
      wl12xx: allow runtime changing of debug_level

=46elix Fietkau (23):
      ath9k: fix sequence number assigment for non-AMPDU QoS data frame=
s
      ath9k_hw: only use the PCIe disable register write sequence for A=
R5416
      ath9k_hw: clean up duplicate and unnused eeprom related defines
      ath9k_hw: merge ath9k_hw_get_gain_boundaries_pdadcs between eepro=
m_def.c and eeprom_4k.c
      ath9k_hw: merge the ar9287 version of ath9k_hw_get_gain_boundarie=
s_pdadcs
      ath9k_hw: remove antenna configuration eeprom ops and variables
      ath9k_hw: clean up SREV version checks
      ath9k_hw: remove ah->beacon_interval
      ath9k_hw: remove ah->txpower_indexoffset
      ath9k_hw: initialize ah->slottime
      ath9k_hw: fix the slot time setting for long distance links
      ath9k: fix PA predistortion thermal measurement handling
      ath9k_hw: fix the PA predistortion rate mask
      ath9k_hw: fix PA predistortion training power selection
      ath9k_hw: update AR9003 initvals for improved radar detection
      ath9k_hw: update AR9003 initvals to improve carrier leak calibrat=
ion/correction
      ath9k: fix queue depth check for forming new aggregates
      ath9k_hw: remove baseband rfsilent support
      mac80211: fix initialization of skb->cb in ieee80211_subif_start_=
xmit
      mac80211: skip unnecessary pskb_expand_head calls
      mac80211: fix potentially redundant skb data copying
      ath9k_hw: fix PA predistortion HT40 mask
      ath9k: do not limit the chainmask to 1 for legacy mode

Gertjan van Wingerde (1):
      rt2x00: Ensure TX-ed frames are returned in the original state.

Guy Eilam (1):
      wl1271: fixed problem with WPS IEs in probe requests

Helmut Schaa (2):
      rt2x00: Implement get_survey callback for rt2800
      rt2x00: Don't frequently reset beacon interval in AdHoc mode

Ivo van Doorn (7):
      rt2x00: Introduce 3 queue commands in drivers (start, kick, stop)=
=2E
      rt2x00: Reorganize queue callback functions
      rt2x00: Protect queue control with mutex
      rt2x00: Add "flush" queue command
      rt2x00: Cleanup RX index counting
      rt2x00: Introduce extra queue entry sanity flag
      rt2x00: Fix WMM Queue naming

Javier Cardona (4):
      mac80211: Rename mesh_params to mesh_config to prepare for mesh_s=
etup
      mac80211: Let userspace enable and configure vendor specific path=
 selection.
      mac80211: Send mesh non-HWMP path selection frames to userspace
      mac80211: Remove unused third address from mesh address extension=
 header.

Johannes Berg (12):
      mac80211: clean up RX key checks
      cfg80211/nl80211: separate unicast/multicast default TX keys
      mac80211: support separate default keys
      mac80211: support IBSS RSN with SW crypto
      iwlagn: fix debug variable access
      iwlagn: rename enhanced txpower fields
      iwlagn: implement layout-agnostic EEPROM reading
      iwlagn: remove old EEPROM TX power reading
      nl80211: advertise maximum remain-on-channel duration
      mac80211: make LED trigger names available early
      mac80211: add throughput based LED blink trigger
      mac80211: selective throughput LED trigger active

Johannes Stezenbach (3):
      rt2x00: fix hang when unplugging USB device in use
      rt2x00: trivial: add missing \n on warnings
      rt2x00: remove stray semicolon

John W. Linville (7):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      rtlwifi: convert to __packed notation
      Merge branch 'wl12xx-next' of git://git.kernel.org/.../luca/wl12x=
x
      rtl8192ce: drop 'rtl8192c-' prefix from files
      rtlwifi: use alloc_workqueue
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (1):
      nl80211: Add notification for dropped Deauth/Disassoc

Juuso Oikarinen (4):
      wl12xx: Fix kernel crash related to hw recovery and interface shu=
tdown
      wl1271: Fix setting of the hardware connection monitoring probe-r=
eq template
      wl12xx: Remove 11j channels from the supported channels list.
      wl12xx: Change TX queue to be per AC

Larry Finger (6):
      rtl8192ce: Add new driver
      rtl8192ce: Fix build on powerpc
      rtl8192ce: Update MAINTAINERS
      rtlwifi: Switch locking from semaphores to mutexes
      MAINTAINERS: Fix typo in rtl8192ce entry
      rtlwifi: Fix use of mutex in interrupt code

Luciano Coelho (5):
      wl12xx: disable 11a channels when regulatory changes if 11a is no=
t supported
      wl12xx: fix illegal memset if debugfs is not enabled
      wl12xx: disable 11a channels when wl->enable_11a is known
      wl12xx_sdio_test: rename files to match current style
      mac80211: check for CONFIG_MAC80211_LEDS in the tpt_led_trigger d=
eclaration

Luis R. Rodriguez (4):
      ath9k: Fix power save count imbalance on ath_radio_enable()
      ath9k: fix assumptions for idle calls on suspend/resume
      cfg80211: fix null pointer dereference with a custom regulatory r=
equest
      ath: fix NULL pointer dereference on reg_notifier()

Mohammed Shafi Shajakhan (4):
      ath9k: clean up hardware code for beacon handling
      ath9k: Make PM-QOS value as user configurable
      ath9k: Add comments for making pm-qos as modparam
      ath9k: Properly initialize channel table for 2GHz

RA-Jay Hung (2):
      rt2x00: Add rt2800 EEPROM definition
      rt2x00: Add RF chip definition

Rafa=C5=82 Mi=C5=82ecki (4):
      b43: N-PHY: use correct bit for controlling MAC and PHY
      b43: N-PHY: one more fix for order of tables initialization
      b43: N-PHY: use designed function and macro for writing tables
      b43: rename TMS defines, drop useless condition from core reset

Rajkumar Manoharan (2):
      ath9k: Add change_interface callback
      ath: Missed to clear key4 of micentry

Roger Quadros (2):
      wl1271: Add wl1271_load_firmware() and export some functions
      wl1271_sdio_test: Add module for sdio RX/TX testing

Sedat Dilek (1):
      iwlwifi: Fix error: struct iwl_lq_sta has no member named dbg_fix=
ed_rate

Shan Wei (1):
      wireless:mac80211: kill unuse macro MESH_CFG_CMP_LEN in mesh.h

Shanyu Zhao (2):
      iwlwifi: clear dbg_fixed_rate during init
      iwlagn: check ready in iwlagn_bss_info_changed()

Sujith Manoharan (4):
      ath9k: Use power save wrappers for TSF get/set
      ath9k_htc: Add Ubiquiti wifistation ext to supported devices
      mac80211: Add timeout to BA session start API
      ath9k_htc: Remove PCI specific configuration

Sven Neumann (1):
      cfg80211: update information elements in cached BSS struct

Tim Harvey (1):
      mac80211 default tx_last_beacon false (congestion)

Vasanthakumar Thiagarajan (7):
      ath9k_hw: Remove delay during regwrite of analog shift registers
      ath9k_hw: Remove unnecessary Rx IQ cal register configuration in =
ar9003_hw_tx_iq_cal()
      ath9k_hw: Move get_streams() to hw.h
      ath9k_hw: Tx IQ cal changes for AR9003
      ath9k_hw: Add a helper to get paprd scale factor
      ath9k_hw: Disable PAPRD for rates with low Tx power
      ath9k_hw: Configure appropriate Tx power when PAPRD fails

Wey-Yi Guy (9):
      iwlagn: change led compensation for 6005 and 6030 devices
      iwlagn: rx antenna diversity
      iwlwifi: add new EEPROM debug log type
      iwlwifi: use IWL_DEBUG_EEPROM for EEPROM related info
      iwlagn: More detail tx power logging
      iwlwifi: do not reload fw if WiMAX own the RF
      iwlwifi: keep track of bt coex enable/disable stage
      iwlagn: code clean up to remove duplicate code
      iwlagn: fix witespace damage

Wolfgang Kufner (2):
      rt2x00: Pad beacon to multiple of 32 bits.
      rt2x00: Fix firmware loading regression on x86_64.

 MAINTAINERS                                        |   10 +
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    1 +
 drivers/net/wireless/ath/ath5k/base.c              |   39 +-
 drivers/net/wireless/ath/ath5k/base.h              |    2 +
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   13 -
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |   19 -
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    1 -
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  104 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  225 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  136 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   44 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   13 -
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    1 -
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |  125 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   28 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    8 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |    5 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |  215 ++-
 drivers/net/wireless/ath/ath9k/eeprom.h            |   57 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |  209 +--
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |  213 +--
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |  211 +--
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    4 -
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    5 -
 drivers/net/wireless/ath/ath9k/hw.c                |   57 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   18 +-
 drivers/net/wireless/ath/ath9k/init.c              |    5 +
 drivers/net/wireless/ath/ath9k/main.c              |  220 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    3 +
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |    1 -
 drivers/net/wireless/ath/ath9k/xmit.c              |   30 +-
 drivers/net/wireless/ath/key.c                     |    2 +
 drivers/net/wireless/ath/regd.c                    |    8 +
 drivers/net/wireless/b43/b43.h                     |    8 +-
 drivers/net/wireless/b43/main.c                    |    8 +-
 drivers/net/wireless/b43/phy_n.c                   |   35 +-
 drivers/net/wireless/b43/tables_nphy.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   71 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   88 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  338 +--
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     |    3 +
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |  304 +--
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    9 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   17 +
 drivers/net/wireless/iwlwifi/iwl-core.h            |    5 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    2 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    7 +
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   25 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   53 -
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    2 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c       |    3 +-
 drivers/net/wireless/libertas/cfg.c                |    3 +-
 drivers/net/wireless/rndis_wlan.c                  |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |  132 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |  132 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   78 +-
 drivers/net/wireless/rt2x00/rt2800.h               |  158 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  169 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |    2 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |  133 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   83 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   85 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    6 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    5 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   35 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |    9 -
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   40 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    7 +
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  239 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   41 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |    2 -
 drivers/net/wireless/rt2x00/rt2x00usb.c            |  282 ++-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   12 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  159 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |   62 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   87 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |   36 +-
 drivers/net/wireless/rtlwifi/Kconfig               |   15 +
 drivers/net/wireless/rtlwifi/Makefile              |   13 +
 drivers/net/wireless/rtlwifi/base.c                |  958 +++++++
 drivers/net/wireless/rtlwifi/base.h                |  120 +
 drivers/net/wireless/rtlwifi/cam.c                 |  291 +++
 drivers/net/wireless/rtlwifi/cam.h                 |   53 +
 drivers/net/wireless/rtlwifi/core.c                | 1029 ++++++++
 drivers/net/wireless/rtlwifi/core.h                |   42 +
 drivers/net/wireless/rtlwifi/debug.c               |   50 +
 drivers/net/wireless/rtlwifi/debug.h               |  212 ++
 drivers/net/wireless/rtlwifi/efuse.c               | 1189 +++++++++
 drivers/net/wireless/rtlwifi/efuse.h               |  124 +
 drivers/net/wireless/rtlwifi/pci.c                 | 1933 ++++++++++++=
++
 drivers/net/wireless/rtlwifi/pci.h                 |  302 +++
 drivers/net/wireless/rtlwifi/ps.c                  |  493 ++++
 drivers/net/wireless/rtlwifi/ps.h                  |   43 +
 drivers/net/wireless/rtlwifi/rc.c                  |  329 +++
 drivers/net/wireless/rtlwifi/rc.h                  |   40 +
 drivers/net/wireless/rtlwifi/regd.c                |  400 +++
 drivers/net/wireless/rtlwifi/regd.h                |   61 +
 drivers/net/wireless/rtlwifi/rtl8192ce/Makefile    |   12 +
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |  257 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        | 1473 +++++++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |  196 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/fw.c        |  804 ++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/fw.h        |   98 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        | 2173 ++++++++++++=
++++
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |   57 +
 drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |  144 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/led.h       |   41 +
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       | 2676 ++++++++++++=
++++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |  237 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       | 2065 ++++++++++++=
+++
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |  523 ++++
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h        |   44 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |  282 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.h        |   37 +
 drivers/net/wireless/rtlwifi/rtl8192ce/table.c     | 1224 +++++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/table.h     |   58 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       | 1031 ++++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |  714 ++++++
 drivers/net/wireless/rtlwifi/wifi.h                | 1532 +++++++++++
 drivers/net/wireless/wl1251/sdio.c                 |    2 +-
 drivers/net/wireless/wl12xx/Kconfig                |   10 +
 drivers/net/wireless/wl12xx/Makefile               |    3 +
 drivers/net/wireless/wl12xx/acx.c                  |    4 +-
 drivers/net/wireless/wl12xx/acx.h                  |    9 +-
 drivers/net/wireless/wl12xx/boot.c                 |   17 +-
 drivers/net/wireless/wl12xx/boot.h                 |    1 +
 drivers/net/wireless/wl12xx/cmd.c                  |   69 +
 drivers/net/wireless/wl12xx/cmd.h                  |    4 +
 drivers/net/wireless/wl12xx/debugfs.c              |  192 +--
 drivers/net/wireless/wl12xx/init.c                 |   13 +-
 drivers/net/wireless/wl12xx/io.c                   |    1 +
 drivers/net/wireless/wl12xx/main.c                 |  119 +-
 drivers/net/wireless/wl12xx/scan.c                 |    4 +
 drivers/net/wireless/wl12xx/sdio_test.c            |  520 ++++
 drivers/net/wireless/wl12xx/tx.c                   |   60 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |  129 +-
 drivers/net/wireless/wl12xx/wl12xx_80211.h         |   17 +-
 include/linux/ieee80211.h                          |   27 +-
 include/linux/nl80211.h                            |  113 +-
 include/net/cfg80211.h                             |   67 +-
 include/net/mac80211.h                             |   56 +-
 net/mac80211/agg-tx.c                              |    7 +-
 net/mac80211/cfg.c                                 |   53 +-
 net/mac80211/debugfs_key.c                         |   37 +-
 net/mac80211/debugfs_key.h                         |    8 +-
 net/mac80211/debugfs_sta.c                         |    2 +-
 net/mac80211/driver-ops.h                          |    2 +-
 net/mac80211/ieee80211_i.h                         |   25 +-
 net/mac80211/iface.c                               |   15 +
 net/mac80211/key.c                                 |   45 +-
 net/mac80211/key.h                                 |    3 +-
 net/mac80211/led.c                                 |  186 ++-
 net/mac80211/led.h                                 |   45 +-
 net/mac80211/main.c                                |   17 +-
 net/mac80211/mesh.c                                |   52 +-
 net/mac80211/mesh.h                                |   22 +-
 net/mac80211/mesh_plink.c                          |    3 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    2 +-
 net/mac80211/rx.c                                  |   53 +-
 net/mac80211/sta_info.h                            |    2 +
 net/mac80211/tx.c                                  |   25 +-
 net/mac80211/util.c                                |    3 +
 net/wireless/core.c                                |   22 +-
 net/wireless/core.h                                |    5 +-
 net/wireless/mesh.c                                |   24 +-
 net/wireless/mlme.c                                |   22 +
 net/wireless/nl80211.c                             |  276 ++-
 net/wireless/nl80211.h                             |    6 +
 net/wireless/reg.c                                 |    3 +-
 net/wireless/scan.c                                |   11 +
 net/wireless/util.c                                |    3 +-
 net/wireless/wext-compat.c                         |    8 +-
 181 files changed, 27766 insertions(+), 3073 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/Kconfig
 create mode 100644 drivers/net/wireless/rtlwifi/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/base.c
 create mode 100644 drivers/net/wireless/rtlwifi/base.h
 create mode 100644 drivers/net/wireless/rtlwifi/cam.c
 create mode 100644 drivers/net/wireless/rtlwifi/cam.h
 create mode 100644 drivers/net/wireless/rtlwifi/core.c
 create mode 100644 drivers/net/wireless/rtlwifi/core.h
 create mode 100644 drivers/net/wireless/rtlwifi/debug.c
 create mode 100644 drivers/net/wireless/rtlwifi/debug.h
 create mode 100644 drivers/net/wireless/rtlwifi/efuse.c
 create mode 100644 drivers/net/wireless/rtlwifi/efuse.h
 create mode 100644 drivers/net/wireless/rtlwifi/pci.c
 create mode 100644 drivers/net/wireless/rtlwifi/pci.h
 create mode 100644 drivers/net/wireless/rtlwifi/ps.c
 create mode 100644 drivers/net/wireless/rtlwifi/ps.h
 create mode 100644 drivers/net/wireless/rtlwifi/rc.c
 create mode 100644 drivers/net/wireless/rtlwifi/rc.h
 create mode 100644 drivers/net/wireless/rtlwifi/regd.c
 create mode 100644 drivers/net/wireless/rtlwifi/regd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
 create mode 100644 drivers/net/wireless/rtlwifi/wifi.h
 create mode 100644 drivers/net/wireless/wl12xx/sdio_test.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-12-22.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
