From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-05-16-v2
Date: Mon, 16 May 2011 20:08:09 -0400
Message-ID: <20110517000809.GA2119@tuxdriver.com>
References: <20110516211305.GG6551@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53263 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756794Ab1EQAQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 20:16:02 -0400
Content-Disposition: inline
In-Reply-To: <20110516211305.GG6551@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry, Dave!  In my defense, I am on the verge of sickness and got
very little sleep last night... :-(

I have corrected the problem and was sure to perform the correct build
test this time! :-)

John

---

Original pull request message follows:

Dave,

Still another big batch of wireless LAN stuff intended for 2.6.40 -- th=
e
wireless folks have really been eating their Wheaties this cycle!

Highlights of this batch include a new driver in the rtlwifi family,
some new AMBA-like bus infrastructure that is specific to Broadcom
devices, a Bluetooth pull from Gustavo and friends, a wl12xx pull from
Luca and friends, some mesh updates from the Cozybit folks, some more
fixups from the mwifiex team, a collection of mac80211 improvements fro=
m
Johannes, the usual flutter of patches around iwlwifi and ath9k, and a
spread of other updates.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1a8218e96271790a07dd7065a2ef173e0f67=
e328:

  net: ping: dont call udp_ioctl() (2011-05-16 11:49:39 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Amitkumar Karwar (4):
      mwifiex: fix simultaneous assoc and scan issue
      mwifiex: remove unnecessary struct mwifiex_opt_sleep_confirm_buff=
er
      mwifiex: remove redundant local structures
      mwifiex: remove mwifiex_recv_complete function

Andy Ross (1):
      Bluetooth: Device ids for ath3k on Pegatron Lucid tablets

Arik Nemtsov (13):
      wl12xx: implement the tx_frames_pending mac80211 callback
      wl12xx: discard corrupted packets in RX
      wl12xx: add BT-coexistance for AP
      wl12xx: use wiphy values for setting rts, frag thresholds on init
      wl12xx: AP-mode - disable beacon filtering on start up
      wl12xx: schedule recovery on command timeout
      wl12xx: print firmware program counter during recovery
      wl12xx: AP-mode - overhaul rate policy configuration
      wl12xx: AP-mode - reconfigure templates after basic rates change
      wl12xx: add debugfs entry for starting recovery
      wl12xx: fix race condition during recovery in AP mode
      wl12xx: export driver state to debugfs
      mac80211: set TID of internal mgmt packets to 7

Ben Greear (1):
      ath5k: Fix lockup due to un-init spinlock.

Bing Zhao (1):
      mwifiex: cleanup ioctl.h

Chaoming Li (13):
      rtlwifi: rtl8192se: Merge def.h
      rtlwifi: rtl8192se: Merge dynamic management routines
      rtlwifi: rtl8192se: Merge firmware routines
      rtlwifi: rtl8192se: Merge hardware routines
      rtlwifi: rtl8192se: Merge led routines
      rtlwifi: rtl8192se: Merge phy routines
      rtlwifi: rtl8192se: Merge register definitions
      rtlwifi: rtl8192se: Merge rf routines
      rtlwifi: rtl8192se: Merge main (sw) routines
      rtlwifi: rtl8192se: Merge table routines
      rtlwifi: rtl8192se: Merge TX and RX routines
      rtlwifi: rtl8192se: Modify Kconfig and Makefile routines for new =
driver
      rtlwifi: rtl8192se: Remove need to disable ASPM

Christian Lamparter (2):
      carl9170: fix -Wunused-but-set-variable warnings
      p54pci: fix -Wunused-but-set-variable warnings

Christoph Fritz (1):
      mwifiex: fix null derefs, mem leaks and trivia

Cindy H. Kao (1):
      iwlwifi: support the svtool messages interactions through nl80211=
 test mode

Daniel Drake (1):
      libertas: remove tx_timeout handler

Daniel Halperin (1):
      mac80211: fix contention time computation in minstrel, minstrel_h=
t

Eliad Peller (13):
      wl12xx: sleep instead of wakeup after tx work
      wl12xx: avoid premature elp entrance
      wl12xx: print actual rx packet size (without padding)
      wl12xx: avoid redundant join on interface reconfiguration
      wl12xx: configure rates when working in ibss mode
      wl12xx: add debugfs entries for dtim_interval and beacon_interval
      wl12xx: simplify wl1271_ssid_set()
      wl12xx_sdio: set interrupt as wake_up interrupt
      wl12xx: declare suspend/resume callbacks (for wowlan)
      wl12xx_sdio: set MMC_PM_KEEP_POWER flag on suspend
      wl12xx: prevent scheduling while suspending (WoW enabled)
      wl12xx_sdio: declare support for NL80211_WOW_TRIGGER_ANYTHING tri=
gger
      wl12xx: enter/exit psm on wowlan suspend/resume

=46abrice Deyber (1):
      mac80211: Only process mesh PREPs with equal seq number if metric=
 is better.

=46elix Fietkau (1):
      ath9k: fix a regression in PS frame filter handling

Gertjan van Wingerde (2):
      rt2x00: Initial support for RT5370 USB devices.
      rt2x00: Fix rmmod hang of rt2800pci

Gustavo F. Padovan (4):
      Bluetooth: Add l2cap_add_psm() and l2cap_add_scid()
      Bluetooth: Handle psm =3D=3D 0 case inside l2cap_add_psm()
      Bluetooth: Remove l2cap_sk_list
      Bluetooth: Remove leftover debug messages

Hauke Mehrtens (1):
      wl12xx: do not set queue_mapping directly

Ido Yariv (3):
      wl12xx: Modify memory configuration for 128x/AP
      wl12xx: Restart TX when TX descriptors are available
      wl12xx: Enable dynamic memory for 127x

Ivo van Doorn (1):
      rt2x00: Fix transfer speed regression for USB hardware

Javier Cardona (12):
      nl80211: Introduce NL80211_MESH_SETUP_USERSPACE_AMPE
      mac80211: Let userspace send action frames over mesh interfaces
      mac80211: Drop MESH_PLINK category and use new ANA-approved MESH_=
ACTION
      open80211s: Stop using zero for address 3 in mesh plink mgmt fram=
es
      cfg80211: Use capability info to detect mesh beacons.
      nl80211: Let userspace drive the peer link management states.
      mac80211: Check size of a new mesh path table for changes since a=
llocation.
      mac80211: Fix locking bug on mesh path table access
      mac80211: Move call to mpp_path_lookup inside RCU-read section
      mac80211: allow setting supported rates on mesh peers
      ath9k: fix beaconing for mesh interfaces
      nl80211: Move peer link state definition to nl80211

Joe Perches (3):
      rtlwifi: rtl8192cu: Fix memset/memcpy using sizeof(ptr) not sizeo=
f(*ptr)
      libertas: Convert lbs_pr_<level> to pr_<level>
      libertas: Use netdev_<level> or dev_<level> where possible

Johannes Berg (18):
      nl80211/cfg80211: WoWLAN support
      mac80211: add basic support for WoWLAN
      iwlagn: remove get_hcmd_size indirection
      iwlagn: remove frame pre-allocation
      iwlagn: remove unused variable
      iwlagn: dont update bytecount table for command queue
      iwlagn: remove bytecount indirection
      iwlagn: check DMA mapping errors
      iwlagn: fix iwl_is_any_associated
      cfg80211: restrict AP beacon intervals
      mac80211: remove pointless mesh path timer RCU code
      mac80211: make key locking clearer
      mac80211: fix another key non-race
      mac80211: fix a few RCU issues
      mac80211: mesh: move some code to make it static
      cfg80211: advertise possible interface combinations
      mac80211: fix TX a-MPDU locking
      mac80211: sparse RCU annotations

John W. Linville (6):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-next-2.6
      ssb: fix pcicore build breakage
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (2):
      nl80211: Fix set_key regression with some drivers
      cfg80211: Remove unused wiphy flag

Julia Lawall (1):
      net/rfkill/core.c: Avoid leaving freed data in a list

Larry Finger (2):
      mac80211: Fix build error when CONFIG_PM is not defined
      rtlwifi: Move 2 large arrays off stack

Luciano Coelho (15):
      wl12xx: strict_stroul introduced converted to kstrtoul
      Revert "wl12xx: support FW TX inactivity triggers"
      mac80211: don't drop frames where skb->len < 24 in ieee80211_scan=
_rx()
      mac80211: add a couple of trace event classes to reduce duplicate=
d code
      cfg80211/nl80211: add support for scheduled scans
      mac80211: add support for HW scheduled scan
      cfg80211/nl80211: add interval attribute for scheduled scans
      cfg80211/mac80211: avoid bounce back mac->cfg->mac on sched_scan_=
stopped
      wl12xx: add configuration values for scheduled scan
      wl12xx: listen to scheduled scan events
      wl12xx: add scheduled scan structures and commands
      wl12xx: implement scheduled scan driver operations and reporting
      wl12xx: export scheduled scan state in debugfs
      wl12xx: prevent sched_scan when not idle or not in station mode
      wl12xx: remove unused flag WL1271_FLAG_IDLE_REQUESTED

Luis R. Rodriguez (2):
      ath9k_hw: fix power for the HT40 duplicate frames
      ath9k_hw: fix dual band assumption for XB113

Mohammed Shafi Shajakhan (12):
      ath9k_hw: remove aggregation protection mode
      ath9k_hw: remove get_channel_noise function
      ath9k_hw: make antenna diversity modules chip specific
      ath9k_hw: enable Antenna diversity for AR9485
      ath9k_hw: define registers/macros to support Antenna diversity
      ath9k_hw: config diversity based on eeprom contents
      ath9k_hw: define modules to get/set Antenna diversity paramaters
      ath9k_hw: define antenna diversity group
      ath9k: Implement an API to swap main/ALT LNA's
      ath9k: configure fast_div_bias based on diversity group
      ath9k: make sure main_rssi is positive
      ath9k: make npending frames check as bool

Nicolas Cavallari (1):
      carl9170: fix allmulticast mode

Rafa=C5=82 Mi=C5=82ecki (13):
      b43: drop invalid IMCFGLO workaround
      b43legacy: drop invalid IMCFGLO workaround
      b43: drop ssb-duplicated workaround for dangling cores
      b43legacy: drop ssb-duplicated workaround for dangling cores
      b43: trivial: include ssb word in ssb specific functions
      bcma: add Broadcom specific AMBA bus driver
      ssb: update list of devices supporting multiple 80211 cores
      b43legacy: trivial: use TMSLOW def instead of magic value
      b43: move MAC PHY clock controling function
      bcma: add missing GPIO defines, use PULL register only when avail=
able
      ssb: move ssb_commit_settings and export it
      b43: implement timeouts workaround
      bcma: pci: trivial: correct amount of maximum retries

Rajkumar Manoharan (11):
      ath9k: Fix drain txq failure in flush
      mac80211: use wake_queue to restart trasmit
      mac80211: Postpond ps timer if tx is stopped by others
      ath9k_hw: do noise floor calibration only on required chains
      wireless: Fix warnings due to -Wunused-but-set-variable
      ath9k: avoid enabling interrupts while processing rx
      ath9k: process TSF out of range before RX
      ath9k_hw: Corrected xpabiaslevel register settings for AR9340
      ath9k_hw: Change DCU backoff thresh for AR9340
      ath9k: Fix rssi update in ad-hoc mode
      ath9k: Failed to set default beacon rssi in AP/IBSS mode

Sascha Silbe (1):
      libertas: Add libertas_disablemesh module parameter to disable me=
sh interface

Senthil Balasubramanian (1):
      ath9k_hw: Fix STA connection issues with AR9380 (XB113).

Shahar Levi (6):
      wl12xx: Set End-of-transaction Flag at Wl127x AP Mode
      wl12xx: Set correct REF CLK and TCXO CLK values to the FW
      wl12xx: FM WLAN coexistence
      wl12xx: Update Power Save Exit Retries Packets
      wl12xx: Don't filter beacons that include changed HT IEs
      wl12xx: add IEEE80211_HW_SPECTRUM_MGMT bit to the hw flags

Stephen Boyd (2):
      iwlegacy: Silence DEBUG_STRICT_USER_COPY_CHECKS=3Dy warning
      iwlwifi: Silence DEBUG_STRICT_USER_COPY_CHECKS=3Dy warning

Thomas Pedersen (3):
      nl80211: allow installing keys for a meshif
      nl80211: allow setting MFP flag for a meshif
      mac80211: Self-protected management frames are not robust

Vinicius Costa Gomes (2):
      Bluetooth: Add support for sending connection events for LE links
      Bluetooth: Add support for disconnecting LE links via mgmt

Waldemar Rymarkiewicz (1):
      Bluetooth: Double check sec req for pre 2.1 device

Wey-Yi Guy (1):
      iwlagn: led stay solid on when no traffic

Yogesh Ashok Powar (6):
      mwifiex: remove unnecessary variable initialization
      mwl8k: Fix broken WEP
      mwl8k: Do not ask mac80211 to generate IV for crypto keys
      mac80211: Fix mesh-related build breakage...
      cfg80211: make stripping of 802.11 header optional from AMSDU
      mwifiex: use ieee80211_amsdu_to_8023s routine

 Documentation/ABI/testing/sysfs-bus-bcma        |   31 +
 MAINTAINERS                                     |    7 +
 drivers/Kconfig                                 |    2 +
 drivers/Makefile                                |    1 +
 drivers/bcma/Kconfig                            |   33 +
 drivers/bcma/Makefile                           |    7 +
 drivers/bcma/README                             |   19 +
 drivers/bcma/TODO                               |    3 +
 drivers/bcma/bcma_private.h                     |   28 +
 drivers/bcma/core.c                             |   51 +
 drivers/bcma/driver_chipcommon.c                |   89 +
 drivers/bcma/driver_chipcommon_pmu.c            |  134 ++
 drivers/bcma/driver_pci.c                       |  163 ++
 drivers/bcma/host_pci.c                         |  196 ++
 drivers/bcma/main.c                             |  247 +++
 drivers/bcma/scan.c                             |  360 ++++
 drivers/bcma/scan.h                             |   56 +
 drivers/bluetooth/ath3k.c                       |    1 +
 drivers/bluetooth/btusb.c                       |    1 +
 drivers/net/wireless/ath/ath5k/base.c           |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c     |   10 -
 drivers/net/wireless/ath/ath9k/ar9002_phy.c     |   44 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c  |   78 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c     |   11 -
 drivers/net/wireless/ath/ath9k/ar9003_phy.c     |   46 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.h     |   22 +
 drivers/net/wireless/ath/ath9k/ath9k.h          |    3 +-
 drivers/net/wireless/ath/ath9k/beacon.c         |   15 +-
 drivers/net/wireless/ath/ath9k/calib.c          |   21 +-
 drivers/net/wireless/ath/ath9k/calib.h          |    1 -
 drivers/net/wireless/ath/ath9k/hw-ops.h         |   16 +-
 drivers/net/wireless/ath/ath9k/hw.c             |   16 +
 drivers/net/wireless/ath/ath9k/hw.h             |   15 +-
 drivers/net/wireless/ath/ath9k/mac.c            |    9 +-
 drivers/net/wireless/ath/ath9k/main.c           |   47 +-
 drivers/net/wireless/ath/ath9k/recv.c           |  215 ++-
 drivers/net/wireless/ath/ath9k/xmit.c           |   11 +-
 drivers/net/wireless/ath/carl9170/main.c        |    2 +-
 drivers/net/wireless/ath/carl9170/tx.c          |    9 -
 drivers/net/wireless/b43/main.c                 |   69 +-
 drivers/net/wireless/b43/main.h                 |    1 +
 drivers/net/wireless/b43/phy_n.c                |   13 +-
 drivers/net/wireless/b43legacy/main.c           |   52 +-
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c     |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig            |   10 +
 drivers/net/wireless/iwlwifi/Makefile           |    1 +
 drivers/net/wireless/iwlwifi/iwl-1000.c         |    2 -
 drivers/net/wireless/iwlwifi/iwl-2000.c         |    2 -
 drivers/net/wireless/iwlwifi/iwl-5000.c         |    4 -
 drivers/net/wireless/iwlwifi/iwl-6000.c         |    4 -
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c     |    7 -
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c       |  105 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c          |  143 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h          |   22 +-
 drivers/net/wireless/iwlwifi/iwl-core.h         |    6 -
 drivers/net/wireless/iwlwifi/iwl-dev.h          |   34 +-
 drivers/net/wireless/iwlwifi/iwl-led.c          |   20 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c      |  469 +++++
 drivers/net/wireless/iwlwifi/iwl-testmode.h     |  151 ++
 drivers/net/wireless/iwlwifi/iwl-tx.c           |   22 +-
 drivers/net/wireless/iwmc3200wifi/rx.c          |    3 +-
 drivers/net/wireless/libertas/cfg.c             |   16 +-
 drivers/net/wireless/libertas/cmd.c             |   40 +-
 drivers/net/wireless/libertas/cmdresp.c         |   27 +-
 drivers/net/wireless/libertas/debugfs.c         |    5 +-
 drivers/net/wireless/libertas/defs.h            |    7 -
 drivers/net/wireless/libertas/if_cs.c           |   57 +-
 drivers/net/wireless/libertas/if_sdio.c         |   37 +-
 drivers/net/wireless/libertas/if_spi.c          |   83 +-
 drivers/net/wireless/libertas/if_usb.c          |   44 +-
 drivers/net/wireless/libertas/main.c            |   72 +-
 drivers/net/wireless/libertas/mesh.c            |    8 +-
 drivers/net/wireless/libertas/rx.c              |    7 +-
 drivers/net/wireless/mwifiex/11n.c              |    7 +-
 drivers/net/wireless/mwifiex/11n_aggr.c         |  136 +--
 drivers/net/wireless/mwifiex/11n_rxreorder.c    |   15 +-
 drivers/net/wireless/mwifiex/cfg80211.c         |   48 +-
 drivers/net/wireless/mwifiex/cmdevt.c           |   51 +-
 drivers/net/wireless/mwifiex/debugfs.c          |   10 +-
 drivers/net/wireless/mwifiex/fw.h               |   21 +-
 drivers/net/wireless/mwifiex/init.c             |   59 +-
 drivers/net/wireless/mwifiex/ioctl.h            |   81 +-
 drivers/net/wireless/mwifiex/join.c             |    9 +-
 drivers/net/wireless/mwifiex/main.c             |   27 +-
 drivers/net/wireless/mwifiex/main.h             |    8 +-
 drivers/net/wireless/mwifiex/scan.c             |   30 +-
 drivers/net/wireless/mwifiex/sdio.c             |   35 +-
 drivers/net/wireless/mwifiex/sta_cmd.c          |    8 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c      |   28 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c        |   80 +-
 drivers/net/wireless/mwifiex/sta_rx.c           |   26 +-
 drivers/net/wireless/mwifiex/sta_tx.c           |    4 +-
 drivers/net/wireless/mwifiex/txrx.c             |   10 +-
 drivers/net/wireless/mwifiex/util.c             |   29 +-
 drivers/net/wireless/mwifiex/wmm.c              |    2 +-
 drivers/net/wireless/mwl8k.c                    |   18 +-
 drivers/net/wireless/p54/p54pci.c               |    3 +-
 drivers/net/wireless/rt2x00/Kconfig             |   11 +-
 drivers/net/wireless/rt2x00/rt2800.h            |    2 +
 drivers/net/wireless/rt2x00/rt2800lib.c         |    5 +-
 drivers/net/wireless/rt2x00/rt2800usb.c         |    8 +
 drivers/net/wireless/rt2x00/rt2x00dev.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c         |    6 +-
 drivers/net/wireless/rtlwifi/Kconfig            |   15 +-
 drivers/net/wireless/rtlwifi/Makefile           |    1 +
 drivers/net/wireless/rtlwifi/efuse.c            |   35 +-
 drivers/net/wireless/rtlwifi/pci.c              |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c    |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/Makefile |   15 +
 drivers/net/wireless/rtlwifi/rtl8192se/def.h    |  598 ++++++
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c     |  733 +++++++
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h     |  164 ++
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c     |  654 ++++++
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h     |  375 ++++
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c     | 2512 +++++++++++++++=
++++++++
 drivers/net/wireless/rtlwifi/rtl8192se/hw.h     |   79 +
 drivers/net/wireless/rtlwifi/rtl8192se/led.c    |  149 ++
 drivers/net/wireless/rtlwifi/rtl8192se/led.h    |   37 +
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c    | 1740 +++++++++++++++=
+
 drivers/net/wireless/rtlwifi/rtl8192se/phy.h    |  101 +
 drivers/net/wireless/rtlwifi/rtl8192se/reg.h    | 1188 +++++++++++
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c     |  546 +++++
 drivers/net/wireless/rtlwifi/rtl8192se/rf.h     |   43 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c     |  423 ++++
 drivers/net/wireless/rtlwifi/rtl8192se/sw.h     |   36 +
 drivers/net/wireless/rtlwifi/rtl8192se/table.c  |  634 ++++++
 drivers/net/wireless/rtlwifi/rtl8192se/table.h  |   49 +
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c    |  976 +++++++++
 drivers/net/wireless/rtlwifi/rtl8192se/trx.h    |   45 +
 drivers/net/wireless/wl12xx/acx.c               |  190 ++-
 drivers/net/wireless/wl12xx/acx.h               |  103 +-
 drivers/net/wireless/wl12xx/boot.c              |    6 +-
 drivers/net/wireless/wl12xx/cmd.c               |   18 +-
 drivers/net/wireless/wl12xx/conf.h              |  111 +-
 drivers/net/wireless/wl12xx/debugfs.c           |  240 +++
 drivers/net/wireless/wl12xx/event.c             |   70 +-
 drivers/net/wireless/wl12xx/event.h             |   12 +-
 drivers/net/wireless/wl12xx/init.c              |  110 +-
 drivers/net/wireless/wl12xx/init.h              |    2 +
 drivers/net/wireless/wl12xx/main.c              |  492 ++++-
 drivers/net/wireless/wl12xx/ps.c                |   30 +-
 drivers/net/wireless/wl12xx/ps.h                |    2 +
 drivers/net/wireless/wl12xx/rx.c                |   36 +-
 drivers/net/wireless/wl12xx/scan.c              |  243 +++
 drivers/net/wireless/wl12xx/scan.h              |  114 +
 drivers/net/wireless/wl12xx/sdio.c              |   64 +-
 drivers/net/wireless/wl12xx/tx.c                |   13 +-
 drivers/net/wireless/wl12xx/tx.h                |    2 +-
 drivers/net/wireless/wl12xx/wl12xx.h            |   14 +-
 drivers/ssb/driver_pcicore.c                    |   26 -
 drivers/ssb/main.c                              |   31 +
 drivers/ssb/scan.c                              |    5 +-
 include/linux/bcma/bcma.h                       |  224 ++
 include/linux/bcma/bcma_driver_chipcommon.h     |  302 +++
 include/linux/bcma/bcma_driver_pci.h            |   89 +
 include/linux/bcma/bcma_regs.h                  |   34 +
 include/linux/ieee80211.h                       |   11 +-
 include/linux/mod_devicetable.h                 |   17 +
 include/linux/nl80211.h                         |  302 +++-
 include/linux/ssb/ssb.h                         |    1 +
 include/net/bluetooth/hci_core.h                |    1 +
 include/net/bluetooth/l2cap.h                   |    9 +-
 include/net/cfg80211.h                          |  237 +++-
 include/net/mac80211.h                          |   66 +
 net/bluetooth/hci_conn.c                        |   17 +
 net/bluetooth/hci_event.c                       |    5 +-
 net/bluetooth/l2cap_core.c                      |  193 ++-
 net/bluetooth/l2cap_sock.c                      |   72 +-
 net/bluetooth/mgmt.c                            |    3 +
 net/bluetooth/rfcomm/core.c                     |    2 +-
 net/mac80211/agg-rx.c                           |    3 +-
 net/mac80211/agg-tx.c                           |   59 +-
 net/mac80211/cfg.c                              |  135 +-
 net/mac80211/debugfs.c                          |    2 +-
 net/mac80211/debugfs_key.c                      |   21 +-
 net/mac80211/driver-ops.h                       |   56 +-
 net/mac80211/driver-trace.h                     |  228 ++-
 net/mac80211/ht.c                               |   27 +-
 net/mac80211/ibss.c                             |   11 +-
 net/mac80211/ieee80211_i.h                      |   41 +-
 net/mac80211/iface.c                            |    3 +-
 net/mac80211/key.c                              |   30 +-
 net/mac80211/key.h                              |    4 +
 net/mac80211/main.c                             |   37 +-
 net/mac80211/mesh.c                             |   47 +-
 net/mac80211/mesh.h                             |    6 +-
 net/mac80211/mesh_hwmp.c                        |   38 +-
 net/mac80211/mesh_pathtbl.c                     |  123 +-
 net/mac80211/mesh_plink.c                       |   83 +-
 net/mac80211/mlme.c                             |   22 +-
 net/mac80211/pm.c                               |   13 +-
 net/mac80211/rc80211_minstrel.c                 |    4 +-
 net/mac80211/rc80211_minstrel_ht.c              |   27 +-
 net/mac80211/rx.c                               |   17 +-
 net/mac80211/scan.c                             |  122 ++-
 net/mac80211/sta_info.c                         |   19 +-
 net/mac80211/sta_info.h                         |   50 +-
 net/mac80211/tx.c                               |   10 +-
 net/mac80211/util.c                             |   19 +
 net/rfkill/core.c                               |    2 +-
 net/wireless/core.c                             |   89 +-
 net/wireless/core.h                             |   33 +
 net/wireless/lib80211_crypt_wep.c               |    3 +-
 net/wireless/mlme.c                             |   10 +
 net/wireless/nl80211.c                          |  670 ++++++-
 net/wireless/nl80211.h                          |    4 +
 net/wireless/reg.c                              |    2 -
 net/wireless/scan.c                             |   77 +-
 net/wireless/sysfs.c                            |    2 +-
 net/wireless/util.c                             |  126 ++-
 scripts/mod/file2alias.c                        |   22 +
 213 files changed, 19165 insertions(+), 2154 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-bus-bcma
 create mode 100644 drivers/bcma/Kconfig
 create mode 100644 drivers/bcma/Makefile
 create mode 100644 drivers/bcma/README
 create mode 100644 drivers/bcma/TODO
 create mode 100644 drivers/bcma/bcma_private.h
 create mode 100644 drivers/bcma/core.c
 create mode 100644 drivers/bcma/driver_chipcommon.c
 create mode 100644 drivers/bcma/driver_chipcommon_pmu.c
 create mode 100644 drivers/bcma/driver_pci.c
 create mode 100644 drivers/bcma/host_pci.c
 create mode 100644 drivers/bcma/main.c
 create mode 100644 drivers/bcma/scan.c
 create mode 100644 drivers/bcma/scan.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-sv-open.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-testmode.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192se/trx.h
 create mode 100644 include/linux/bcma/bcma.h
 create mode 100644 include/linux/bcma/bcma_driver_chipcommon.h
 create mode 100644 include/linux/bcma/bcma_driver_pci.h
 create mode 100644 include/linux/bcma/bcma_regs.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-05-16-v2.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
