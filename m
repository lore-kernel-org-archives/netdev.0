From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-04-12
Date: Tue, 12 Apr 2011 17:14:34 -0400
Message-ID: <20110412211429.GE24309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58388 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730Ab1DLXA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:00:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here is the first big wireless pull request for the 2.6.40 cycle...

There is the usual contingent of patches from the iwlwifi team, the
ath9k team, the rt2x00 team, the mwl8k guys and now the Bluetooth guys
as well.  Also of note are the addition of the mwifiex driver from
Marvell and the removal of the ar9170usb driver which has been
obsoleted by carl9170.  There are a number of other smaller
contributions too, of course.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 6ba1037c3d871ab70e342631516dbf841c35=
b086:

  vxge: update driver version (2011-04-12 11:22:34 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Alexey Dobriyan (1):
      Bluetooth: convert net/bluetooth/ to kstrtox

Amitkumar Karwar (1):
      mwifiex: return success in set_default_key for WPA/WPA2

Andrei Emeltchenko (2):
      Bluetooth: check L2CAP info_rsp ident and state
      Bluetooth: delete hanging L2CAP channel

Ben Greear (1):
      wifi: Add hwflags to debugfs.

Bing Zhao (6):
      wireless: mwifiex: initial commit for Marvell mwifiex driver
      mwifiex: remove macro SHORT_SLOT_TIME_DISABLED
      mwifiex: remove MWIFIEX_BSS_MODE_ macros
      ieee80211: add HT extended capabilities masks
      mwifiex: remove struct mwifiex_802_11_fixed_ies
      mwifiex: remove unused macros in decl.h and main.h

Brian Cavagnolo (4):
      mwl8k: refactor in preparation for APIv2 update
      mwl8k: update to ap firmware API version 2
      mwl8k: differentiate between WMM queues and AMPDU queues
      mwl8k: add internal API for managing AMPDU streams

Christian Lamparter (1):
      ar9170usb: purge obsolete driver

Dan Carpenter (1):
      iwlwifi: remove duplicate initialization in __iwl_down()

Daniel Halperin (4):
      iwlwifi: limit number of attempts for highest HT rate
      iwlwifi: cleanup and bugfix tx aggregation code
      iwlwifi: add RATE_MCS_RATE_MSK
      iwlwifi: set default aggregation frame limit to 63

=46elix Fietkau (24):
      ath9k: remove unnecessary debugfs return code checks
      ath9k: add an interface for overriding the value of specific GPIO=
 pins
      ath9k: add support for overriding the MAC address through platfor=
m data
      ath9k: add support for overriding LED pin and GPIO settings from =
platform data
      ath9k_hw: enable a BlockAck related fixup specific to AR9100
      ath9k_hw: force rx chainmask to 7 on AR9100
      ath9k: remove the pending frames ath_txq_schedule workaround
      ath9k: fix beacon timer handling issues
      ath9k: trigger nfcal only after multiple missed beacons in AP mod=
e
      ath9k: fix stuck beacon detection
      ath9k_hw: embed the ath_ops callbacks in the ath_hw struct
      ath9k_hw: add a new register op for read-mask-write
      ath9k_hw: replace REG_READ+REG_WRITE with REG_RMW
      ath9k_hw: turn a few big macros into functions
      ath9k_hw: remove pCap->total_queues
      ath9k_hw: remove ah->config.ht_enable
      ath9k_hw: remove pCap->reg_cap
      ath9k_hw: remove pCap->keycache_size
      ath9k_hw: remove ATH9K_HW_CAP_ENHANCEDPM
      ath9k_hw: remove pCap->tx_triglevel_max
      mac80211: fix suppressing probe responses in ad-hoc mode
      mac80211: remove the dependency on crypto_blkcipher
      ath9k: fix beacon slot processing in ad-hoc mode
      ath9k: use the hw opmode to select the beacon timer mode

Gustavo F. Padovan (10):
      Bluetooth: remove unnecessary function declaration
      Bluetooth: Remove unused struct item
      Bluetooth: Improve error message on wrong link type
      Bluetooth: Remove unused struct l2cap_conn item
      Bluetooth: Move bt_accept_enqueue() to outside __l2cap_chan_add
      Bluetooth: Fix HCI_RESET command synchronization
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-2.6
      Bluetooth: Remove gfp_mask param from hci_reassembly()
      Bluetooth: Don't use spin_lock_bh in user context
      Bluetooth: Use GFP_KERNEL in user context

Helmut Schaa (13):
      mac80211: Minor optimization in tx status handling
      rt2x00: Limit rt2x00pci rxdone processing to 16 entries at once
      rt2x00: Limit rt2800pci txdone processing to 16 entries at once
      rt2x00: Calculate tx status fifo size instead of hardcoding it
      rt2x00: Remove DRIVER_SUPPORT_WATCHDOG flag
      rt2x00: Restructure bw_comp calculation
      rt2x00: Don't recalculate HT40 compensation for each rate
      rt2x00: Indention cleanup in rt2800lib
      rt2x00: Remove obsolete rt2x00queue_align_payload
      rt2x00: Implement tx power temperature compensation
      rt2x00: Fix STBC transmissions to STAs with Rx STBC > 1
      rt2x00: Fix tx aggregation problems with some clients
      rt2x00: Add an error message when trying to send on a full queue

Ivo van Doorn (1):
      rt2x00: Add support for the ZyXEL NWD-211AN USB

Jarkko Nikula (2):
      wl1251: Prepare for idle mode support
      wl1251: Add support for idle mode

Johan Hedberg (7):
      Bluetooth: Add define for the maximum name length on HCI level
      Bluetooth: mgmt: Add local name information to read_info reply
      Bluetooth: mgmt: Add support for setting the local name
      Bluetooth: Add local Extended Inquiry Response (EIR) support
      Bluetooth: Fix missing hci_dev_lock_bh in user_confirm_reply
      Bluetooth: Add mgmt_device_found event
      Bluetooth: Add mgmt_remote_name event

Johannes Berg (25):
      iwlagn: clean up TX aggregation code
      iwlagn: fix aggregation queue scheduler setup
      mac80211: add comment about reordering
      mac80211: clean up station cleanup timer
      iwlagn: remove unused variable
      iwlagn: clean up some 3945/4965 remnants
      iwlagn: make mac80211 handlers static
      iwlagn: clean up ucode loading
      iwlagn: remove pointless return variables
      iwlagn: simplify ucode check code
      iwlagn: verify specific ucode
      iwlagn: remove bootstrap code
      iwlagn: centralize and fix ucode restart
      iwlagn: remove ucode_data_backup
      iwlagn: add feature flags
      iwlagn: fix ucode verify message
      iwlagn: clean up alive handling
      iwlagn: init cmd_queue earlier
      iwlagn: remove BSM clock setting
      iwlagn: remove hw_wa_rev
      iwlagn: remove hw_rev
      iwlagn: remove rev_id
      iwlagn: remove rxb page bookkeeping
      iwlagn: remove ISR ops
      iwlagn: move IO functions out of line

John W. Linville (4):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (2):
      ath9k: Support RSN IBSS
      cfg80211: Add nl80211 event for deletion of a station entry

Jussi Kivilinna (1):
      zd1211rw: rename CR* macros to ZD_CR*

Larry Finger (2):
      rtlwifi: rtl8192c{e,u}: Remove some extraneous casts on memcpy co=
mmands
      rtlwifi: Remove unused/unneeded variables

Luis R. Rodriguez (3):
      ath9k_hw: remove AR9485 1.0 support
      cfg80211: fix regulatory restore upon user hints
      cfg80211: add a timer for invalid user reg hints

Marc Yang (6):
      mwifiex: remove unnecessary _set_auth functions
      mwifiex: use IEEE80211_HT_CAP_ macros for 11n cap_info
      mwifiex: remove MWIFIEX_AUTH_MODE_ macros
      mwifiex: remove unused radio_on variable and macros
      mwifiex: remove unused macros in fw.h
      mwifiex: cleanup power save related struct and macros

Marc-Antoine Perennou (1):
      Bluetooth: add support for Apple MacBook Pro 8,2

Michal Marek (1):
      rt2x00: Drop __TIME__ usage

Mohammed Shafi Shajakhan (4):
      ath9k: cleanup few redundant macros
      ath9k: remove set11n_virtualmorefrag
      ath9k_hw: remove ath9k_get_channel_edges
      mac80211: remove few obsolete flags

Nishant Sarmukadam (6):
      mwl8k: add support for block ack commands
      mwl8k: Initiate BA sessions
      mwl8k: Handle the watchdog event from the firmware
      mwl8k: Check outgoing rate for a station to decide if ampdu can b=
e created
      mwl8k: Queue ADDBA requests in respective data queues
      mwl8k: Do not configure tx power unconditionally

Paul Stewart (1):
      nl80211: Add BSS parameters to station

Rafa=C5=82 Mi=C5=82ecki (5):
      ssb: trivial: use u8 for chip_rev (it's mask is 0xF)
      ssb: pci: trivial: drop useless pointer
      ssb: pci: fix mdio writes on newer cores (rev 10+)
      ssb: pci: implement mdio reading
      ssb: pci: implement serdes workaround

Rajkumar Manoharan (8):
      ath9k_htc: Fix LED pin for AR9287 HTC device
      ath9k_hw: Fix throughput drops in HT40 mode for AR9287 chips
      ath: Speedup key set/reset ops for HTC driver
      ath9k_hw: Speedup register ops for HTC driver
      ath9k: deny new interface addtion on IBSS mode
      ath9k: Cleanup ath_vif struct
      ath9k: Handle BSSID/AID for multiple interfaces

Stanislaw Gruszka (4):
      iwlegacy: MAINTAINERS
      iwlwifi: fix enqueue hcmd race conditions
      iwlwifi: more priv->mutex serialization
      iwlwifi: remove sync_cmd_mutex

Suraj Sumangala (1):
      Bluetooth: Increment unacked_frames count only the first transmit

Szymon Janc (15):
      Bluetooth: Opencode macros in bnep/core.c
      Bluetooth: Fix checkpatch errors and some code style issues in bn=
ep
      Bluetooth: Use #include <linux/uaccess.h> instead of <asm/uaccess=
=2Eh>
      Bluetooth: Fix checkpatch errors, code style issues and typos in =
hidp
      Bluetooth: Do not use assignments in IF conditions
      Bluetooth: Use #include <linux/uaccess.h> instead of <asm/uaccess=
=2Eh>
      Bluetooth: Fix checkpatch error in cmtp.h
      Bluetooth: Rename cmd to param in pending_cmd
      Bluetooth: Allow for NULL data in mgmt_pending_add
      Bluetooth: Add read_local_oob_data management command
      Bluetooth: Add add/remove_remote_oob_data management commands
      Bluetooth: Enable support for out of band association model
      Bluetooth: Use kthread API in hidp
      Bluetooth: Use kthread API in bnep
      Bluetooth: Use kthread API in cmtp

Thomas Gleixner (1):
      Bluetooth: Fix warning with hci_cmd_timer

Vasanthakumar Thiagarajan (1):
      ath9k_hw: Use appropriate rx gain table for AR9485

Vasily Khoruzhick (1):
      libertas_spi: Add support for suspend/resume

Vinicius Costa Gomes (1):
      Bluetooth: Fix sending LE data over USB

Wey-Yi Guy (10):
      iwlegacy: MAINTAINERS
      iwlagn: use 6030 configuration for 6035 series
      iwlwifi: remove legacy isr tasklet
      iwlagn: remove 3945 only station code
      iwlagn: remove reference to 3945 and 4965
      iwlagn: remove deprecated module parameters
      iwlagn: remove more 3945/4965 related defines
      iwlagn: return send calibration result
      iwlagn: change Copyright to 2011
      iwlagn: check more error return code

Xose Vazquez Perez (1):
      wireless: rt2x00: rt{2500,73}usb.c fix duplicate ids

Yogesh Ashok Powar (2):
      mwifiex: remove helper functions for displaying 11n capabilities
      mwifiex: remove redundant encryption_mode mapping

 Documentation/feature-removal-schedule.txt        |   11 -
 MAINTAINERS                                       |   13 +-
 drivers/net/wireless/Kconfig                      |    1 +
 drivers/net/wireless/Makefile                     |    2 +
 drivers/net/wireless/ath/Kconfig                  |    1 -
 drivers/net/wireless/ath/Makefile                 |    1 -
 drivers/net/wireless/ath/ar9170/Kconfig           |   20 -
 drivers/net/wireless/ath/ar9170/Makefile          |    3 -
 drivers/net/wireless/ath/ar9170/ar9170.h          |  258 --
 drivers/net/wireless/ath/ar9170/cmd.c             |  127 -
 drivers/net/wireless/ath/ar9170/cmd.h             |   92 -
 drivers/net/wireless/ath/ar9170/eeprom.h          |  179 --
 drivers/net/wireless/ath/ar9170/hw.h              |  430 ---
 drivers/net/wireless/ath/ar9170/led.c             |  181 --
 drivers/net/wireless/ath/ar9170/mac.c             |  519 ----
 drivers/net/wireless/ath/ar9170/main.c            | 2190 -------------=
--
 drivers/net/wireless/ath/ar9170/phy.c             | 1719 ------------
 drivers/net/wireless/ath/ar9170/usb.c             | 1008 -------
 drivers/net/wireless/ath/ar9170/usb.h             |   82 -
 drivers/net/wireless/ath/ath.h                    |    1 +
 drivers/net/wireless/ath/ath9k/ar5008_phy.c       |   45 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c     |   43 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c       |   12 -
 drivers/net/wireless/ath/ath9k/ar9003_hw.c        |   98 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c       |   12 -
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h  |  925 ------
 drivers/net/wireless/ath/ath9k/ath9k.h            |   14 +-
 drivers/net/wireless/ath/ath9k/beacon.c           |  207 +-
 drivers/net/wireless/ath/ath9k/common.c           |    2 +-
 drivers/net/wireless/ath/ath9k/debug.c            |   94 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c      |    6 +
 drivers/net/wireless/ath/ath9k/eeprom_def.c       |    7 +
 drivers/net/wireless/ath/ath9k/gpio.c             |   14 +-
 drivers/net/wireless/ath/ath9k/htc.h              |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c   |    9 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c     |   33 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h           |    6 -
 drivers/net/wireless/ath/ath9k/hw.c               |  206 +-
 drivers/net/wireless/ath/ath9k/hw.h               |   66 +-
 drivers/net/wireless/ath/ath9k/init.c             |   53 +-
 drivers/net/wireless/ath/ath9k/mac.c              |  113 +-
 drivers/net/wireless/ath/ath9k/main.c             |  175 +-
 drivers/net/wireless/ath/ath9k/phy.h              |   14 -
 drivers/net/wireless/ath/ath9k/recv.c             |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h              |    1 +
 drivers/net/wireless/ath/ath9k/xmit.c             |   29 +-
 drivers/net/wireless/ath/key.c                    |   32 +
 drivers/net/wireless/iwlwifi/Makefile             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c           |   16 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c           |   48 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c           |   29 +-
 drivers/net/wireless/iwlwifi/iwl-6000-hw.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c           |   46 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.h      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c    |   52 +-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c     |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-led.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-led.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c         |   29 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h         |   30 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c         |  142 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c      |  122 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c            |  529 +---
 drivers/net/wireless/iwlwifi/iwl-agn.h            |   45 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h       |  647 +-----
 drivers/net/wireless/iwlwifi/iwl-core.c           |  114 +-
 drivers/net/wireless/iwlwifi/iwl-core.h           |   40 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h            |   43 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h            |  274 +--
 drivers/net/wireless/iwlwifi/iwl-devtrace.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c         |   50 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h         |  191 +--
 drivers/net/wireless/iwlwifi/iwl-fh.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c           |   17 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-io.c             |  274 ++
 drivers/net/wireless/iwlwifi/iwl-io.h             |  491 +----
 drivers/net/wireless/iwlwifi/iwl-led.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h           |  342 +---
 drivers/net/wireless/iwlwifi/iwl-rx.c             |   13 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c             |   68 +-
 drivers/net/wireless/libertas/if_spi.c            |   65 +
 drivers/net/wireless/mwifiex/11n.c                |  809 ++++++
 drivers/net/wireless/mwifiex/11n.h                |  176 ++
 drivers/net/wireless/mwifiex/11n_aggr.c           |  423 +++
 drivers/net/wireless/mwifiex/11n_aggr.h           |   32 +
 drivers/net/wireless/mwifiex/11n_rxreorder.c      |  637 +++++
 drivers/net/wireless/mwifiex/11n_rxreorder.h      |   67 +
 drivers/net/wireless/mwifiex/Kconfig              |   21 +
 drivers/net/wireless/mwifiex/Makefile             |   41 +
 drivers/net/wireless/mwifiex/README               |  204 ++
 drivers/net/wireless/mwifiex/cfg80211.c           | 1456 ++++++++++
 drivers/net/wireless/mwifiex/cfg80211.h           |   31 +
 drivers/net/wireless/mwifiex/cfp.c                |  367 +++
 drivers/net/wireless/mwifiex/cmdevt.c             | 1459 ++++++++++
 drivers/net/wireless/mwifiex/debugfs.c            |  773 +++++
 drivers/net/wireless/mwifiex/decl.h               |  153 +
 drivers/net/wireless/mwifiex/fw.h                 | 1229 ++++++++
 drivers/net/wireless/mwifiex/init.c               |  662 +++++
 drivers/net/wireless/mwifiex/ioctl.h              |  411 +++
 drivers/net/wireless/mwifiex/join.c               | 1462 ++++++++++
 drivers/net/wireless/mwifiex/main.c               | 1102 ++++++++
 drivers/net/wireless/mwifiex/main.h               | 1058 +++++++
 drivers/net/wireless/mwifiex/scan.c               | 3097 +++++++++++++=
++++++++
 drivers/net/wireless/mwifiex/sdio.c               | 1770 ++++++++++++
 drivers/net/wireless/mwifiex/sdio.h               |  305 ++
 drivers/net/wireless/mwifiex/sta_cmd.c            | 1226 ++++++++
 drivers/net/wireless/mwifiex/sta_cmdresp.c        |  983 +++++++
 drivers/net/wireless/mwifiex/sta_event.c          |  405 +++
 drivers/net/wireless/mwifiex/sta_ioctl.c          | 2360 +++++++++++++=
+++
 drivers/net/wireless/mwifiex/sta_rx.c             |  182 ++
 drivers/net/wireless/mwifiex/sta_tx.c             |  202 ++
 drivers/net/wireless/mwifiex/txrx.c               |  202 ++
 drivers/net/wireless/mwifiex/util.c               |  252 ++
 drivers/net/wireless/mwifiex/util.h               |   32 +
 drivers/net/wireless/mwifiex/wmm.c                | 1237 ++++++++
 drivers/net/wireless/mwifiex/wmm.h                |  112 +
 drivers/net/wireless/mwl8k.c                      |  749 +++++-
 drivers/net/wireless/rt2x00/rt2400pci.c           |    6 +-
 drivers/net/wireless/rt2x00/rt2500pci.c           |    6 +-
 drivers/net/wireless/rt2x00/rt2500usb.c           |    5 -
 drivers/net/wireless/rt2x00/rt2800.h              |  106 +
 drivers/net/wireless/rt2x00/rt2800lib.c           |  198 ++-
 drivers/net/wireless/rt2x00/rt2800lib.h           |    1 +
 drivers/net/wireless/rt2x00/rt2800pci.c           |   19 +-
 drivers/net/wireless/rt2x00/rt2800usb.c           |    3 +-
 drivers/net/wireless/rt2x00/rt2x00.h              |    7 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c         |    1 -
 drivers/net/wireless/rt2x00/rt2x00dev.c           |   28 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h           |   23 +-
 drivers/net/wireless/rt2x00/rt2x00link.c          |   49 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c           |    7 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h           |    5 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c         |   18 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h         |    1 +
 drivers/net/wireless/rt2x00/rt61pci.c             |    6 +-
 drivers/net/wireless/rt2x00/rt73usb.c             |    2 -
 drivers/net/wireless/rtlwifi/base.c               |    5 +-
 drivers/net/wireless/rtlwifi/core.c               |    8 +-
 drivers/net/wireless/rtlwifi/efuse.c              |  106 +-
 drivers/net/wireless/rtlwifi/pci.c                |   53 +-
 drivers/net/wireless/rtlwifi/pci.h                |    4 +-
 drivers/net/wireless/rtlwifi/ps.c                 |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |   38 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h      |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c      |    2 +-
 drivers/net/wireless/rtlwifi/wifi.h               |   18 +-
 drivers/net/wireless/wl1251/cmd.h                 |    4 +-
 drivers/net/wireless/wl1251/event.c               |    6 +-
 drivers/net/wireless/wl1251/main.c                |   22 +-
 drivers/net/wireless/wl1251/ps.c                  |   23 +-
 drivers/net/wireless/wl1251/ps.h                  |    2 +-
 drivers/net/wireless/wl1251/wl1251.h              |    9 +-
 drivers/net/wireless/zd1211rw/zd_chip.c           |  262 +-
 drivers/net/wireless/zd1211rw/zd_chip.h           |  529 ++--
 drivers/net/wireless/zd1211rw/zd_rf.h             |    2 +-
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c      |  198 +-
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c     |  240 +-
 drivers/net/wireless/zd1211rw/zd_rf_rf2959.c      |   78 +-
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c      |   86 +-
 drivers/net/wireless/zd1211rw/zd_usb.c            |    4 +-
 drivers/net/wireless/zd1211rw/zd_usb.h            |    2 +-
 drivers/ssb/driver_pcicore.c                      |  104 +-
 drivers/ssb/scan.c                                |    2 +-
 include/linux/ath9k_platform.h                    |    5 +
 include/linux/ieee80211.h                         |    9 +
 include/linux/nl80211.h                           |   35 +-
 include/linux/ssb/ssb.h                           |    2 +-
 include/net/bluetooth/hci.h                       |   40 +-
 include/net/bluetooth/hci_core.h                  |   25 +-
 include/net/bluetooth/l2cap.h                     |    2 -
 include/net/bluetooth/mgmt.h                      |   47 +
 include/net/cfg80211.h                            |   43 +
 net/bluetooth/bnep/bnep.h                         |  148 +-
 net/bluetooth/bnep/core.c                         |   71 +-
 net/bluetooth/bnep/sock.c                         |    2 +-
 net/bluetooth/cmtp/capi.c                         |    6 +-
 net/bluetooth/cmtp/cmtp.h                         |   11 +-
 net/bluetooth/cmtp/core.c                         |   25 +-
 net/bluetooth/cmtp/sock.c                         |    2 +-
 net/bluetooth/hci_core.c                          |   79 +-
 net/bluetooth/hci_event.c                         |   95 +-
 net/bluetooth/hci_sysfs.c                         |   40 +-
 net/bluetooth/hidp/core.c                         |   90 +-
 net/bluetooth/hidp/hidp.h                         |    6 +-
 net/bluetooth/hidp/sock.c                         |    7 +-
 net/bluetooth/l2cap_core.c                        |   27 +-
 net/bluetooth/mgmt.c                              |  518 ++++-
 net/mac80211/Kconfig                              |    1 -
 net/mac80211/cfg.c                                |   13 +-
 net/mac80211/debugfs.c                            |   89 +-
 net/mac80211/ibss.c                               |    3 +-
 net/mac80211/ieee80211_i.h                        |    4 +-
 net/mac80211/main.c                               |    5 -
 net/mac80211/mlme.c                               |    9 -
 net/mac80211/rx.c                                 |    2 +
 net/mac80211/sta_info.c                           |   15 +-
 net/mac80211/sta_info.h                           |    1 -
 net/mac80211/status.c                             |   11 +-
 net/mac80211/tkip.c                               |    4 +-
 net/mac80211/tkip.h                               |    4 +-
 net/mac80211/util.c                               |    2 +-
 net/mac80211/wep.c                                |   34 +-
 net/mac80211/wep.h                                |    4 +-
 net/wireless/mlme.c                               |    9 +
 net/wireless/nl80211.c                            |   55 +-
 net/wireless/nl80211.h                            |    3 +
 net/wireless/reg.c                                |   71 +-
 230 files changed, 29858 insertions(+), 12692 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/ar9170/Kconfig
 delete mode 100644 drivers/net/wireless/ath/ar9170/Makefile
 delete mode 100644 drivers/net/wireless/ath/ar9170/ar9170.h
 delete mode 100644 drivers/net/wireless/ath/ar9170/cmd.c
 delete mode 100644 drivers/net/wireless/ath/ar9170/cmd.h
 delete mode 100644 drivers/net/wireless/ath/ar9170/eeprom.h
 delete mode 100644 drivers/net/wireless/ath/ar9170/hw.h
 delete mode 100644 drivers/net/wireless/ath/ar9170/led.c
 delete mode 100644 drivers/net/wireless/ath/ar9170/mac.c
 delete mode 100644 drivers/net/wireless/ath/ar9170/main.c
 delete mode 100644 drivers/net/wireless/ath/ar9170/phy.c
 delete mode 100644 drivers/net/wireless/ath/ar9170/usb.c
 delete mode 100644 drivers/net/wireless/ath/ar9170/usb.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-io.c
 create mode 100644 drivers/net/wireless/mwifiex/11n.c
 create mode 100644 drivers/net/wireless/mwifiex/11n.h
 create mode 100644 drivers/net/wireless/mwifiex/11n_aggr.c
 create mode 100644 drivers/net/wireless/mwifiex/11n_aggr.h
 create mode 100644 drivers/net/wireless/mwifiex/11n_rxreorder.c
 create mode 100644 drivers/net/wireless/mwifiex/11n_rxreorder.h
 create mode 100644 drivers/net/wireless/mwifiex/Kconfig
 create mode 100644 drivers/net/wireless/mwifiex/Makefile
 create mode 100644 drivers/net/wireless/mwifiex/README
 create mode 100644 drivers/net/wireless/mwifiex/cfg80211.c
 create mode 100644 drivers/net/wireless/mwifiex/cfg80211.h
 create mode 100644 drivers/net/wireless/mwifiex/cfp.c
 create mode 100644 drivers/net/wireless/mwifiex/cmdevt.c
 create mode 100644 drivers/net/wireless/mwifiex/debugfs.c
 create mode 100644 drivers/net/wireless/mwifiex/decl.h
 create mode 100644 drivers/net/wireless/mwifiex/fw.h
 create mode 100644 drivers/net/wireless/mwifiex/init.c
 create mode 100644 drivers/net/wireless/mwifiex/ioctl.h
 create mode 100644 drivers/net/wireless/mwifiex/join.c
 create mode 100644 drivers/net/wireless/mwifiex/main.c
 create mode 100644 drivers/net/wireless/mwifiex/main.h
 create mode 100644 drivers/net/wireless/mwifiex/scan.c
 create mode 100644 drivers/net/wireless/mwifiex/sdio.c
 create mode 100644 drivers/net/wireless/mwifiex/sdio.h
 create mode 100644 drivers/net/wireless/mwifiex/sta_cmd.c
 create mode 100644 drivers/net/wireless/mwifiex/sta_cmdresp.c
 create mode 100644 drivers/net/wireless/mwifiex/sta_event.c
 create mode 100644 drivers/net/wireless/mwifiex/sta_ioctl.c
 create mode 100644 drivers/net/wireless/mwifiex/sta_rx.c
 create mode 100644 drivers/net/wireless/mwifiex/sta_tx.c
 create mode 100644 drivers/net/wireless/mwifiex/txrx.c
 create mode 100644 drivers/net/wireless/mwifiex/util.c
 create mode 100644 drivers/net/wireless/mwifiex/util.h
 create mode 100644 drivers/net/wireless/mwifiex/wmm.c
 create mode 100644 drivers/net/wireless/mwifiex/wmm.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-04-12.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
