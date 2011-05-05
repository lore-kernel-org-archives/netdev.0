From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-05-05
Date: Thu, 5 May 2011 15:12:20 -0400
Message-ID: <20110505191219.GC3005@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50039 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab1EETP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 15:15:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another big Cinco de Mayo batch of stuff intended for 2.6.40...

Highlights include a number of mwifiex bug fixes, a batch of wl12xx
updates (including some new hardware support), a big batch of rtlwifi
fixups in preparation for some new hardware drivers, some mwl8k and
rt2x00 updates, the usual variety of iwlwifi and ath9k updates, a set
of updates to the iwlegacy drivers from Stanislaw, some ssb udpates
form Rafa=C5=82, a bunch of Bluetooth updates from Gustavo and friends,
and a handful of enhancements to other drivers and to mac80211.

Please let me know if there are problems!

John

---

The following changes since commit 5a412ad7f4c95bb5b756aa12b52646e857e7=
c75d:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/=
jkirsher/net-next-2.6 (2011-05-04 13:54:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Adrian Chadd (1):
      ath9k: fix AR9160 xpaBiasLvlFreq endianness handling

Amitkumar Karwar (4):
      cfg80211: module_param to disable HT40 in 2.4GHz band
      mwifiex: check firmware capabilities while initialising 5GHz band=
 parameters
      mwifiex: HT capability information handling
      mwifiex: fix bug in mwifiex_save_curr_bcn()

Arik Nemtsov (5):
      wl12xx: 1281/1283 support - Use different FW file for AP mode wl1=
27x/wl128x chips
      wl12xx: Clamp byte mode transfers for 128x chips
      wl12xx: configure channel/band while FW is off
      mac80211: allow low level drivers to report packet loss
      wl12xx: support FW TX inactivity triggers

Bing Zhao (1):
      mwifiex: fix missing tsf_val TLV

Chaoming_Li (17):
      rtlwifi: Change efuse routines addition of RTL8192SE and RTL8192D=
E
      rtlwifi: Change wifi.h for rtl8192se and rtl8192de
      rtlwifi: Change base routines for addition of rtl8192se and rtl81=
92de
      rtlwifi: Change cam routines for addition of rtl8192se and rtl819=
2de
      rtlwifi: Convert core routines for addition of rtl8192se and rtl8=
192de
      rtlwifi: Convert pci routines for addition of rtl8192se and rtl81=
92de
      rtlwifi: Convert ps routines for addition of rtl8192se and rtl819=
2de
      rtlwifi: Convert rc routines for addition of rtl8192se and rtl819=
2de
      rtlwifi: Convert regulatory domain routines for addition of rtl81=
92se and rtl8192de
      rtlwifi: Convert usb routines for addition of rtl8192se and rtl81=
92de
      rtlwifi: rtl8192c-common: Convert common dynamic management routi=
nes for addition of rtl8192se and rtl8192de
      rtlwifi: rtl8192c-common: Change common firmware routines for add=
ition of rtl8192se and rtl8192de
      rtlwifi: rtl8192c-common: Change common PHY routines for addition=
 of rtl8192se and rtl8192de
      rtlwifi: rtl8192ce: Change hw routine for addition of rtl8192se a=
nd rtl8192de
      rtlwifi: rtl8192ce: Change sw and LED routines for addition of rt=
l8192se and rtl8192de
      rtlwifi: rtl8192ce: Change phy and rc routines for addition of rt=
l8192se and rtl8192de
      rtlwifi: rtl8192ce: Change rtl8192ce routines phy and trx and mod=
ify rtl8192cu for addition of rtl8192se and rtl8192de

Christian Lamparter (4):
      p54: implement multicast filter
      carl9170: improve unicast PS buffering
      mac80211: fix too early reorder release timer
      mac80211: consolidate MIC failure report handling

Don Fry (2):
      iwlagn: mod param cleanup
      iwlagn: semaphore and calib cleanup

Eliad Peller (2):
      wl12xx: set the actual tid instead of the ac
      wl12xx: rearrange some ELP wake_up/sleep calls

Gertjan van Wingerde (2):
      rt2x00: Streamline rt2800 eeprom initialisations.
      rt2x00: Introduce capability flag for Bluetooth co-existence.

Gustavo F. Padovan (11):
      Merge master.kernel.org:/.../padovan/bluetooth-2.6
      Bluetooth: Refactor L2CAP channel allocation
      Bluetooth: Move conf_state to struct l2cap_chan
      Bluetooth: Rename l2cap_do_connect() to l2cap_chan_connect()
      Bluetooth: Move some more elements to struct l2cap_chan
      Bluetooth: Move more vars to struct l2cap_chan
      Bluetooth: Move more channel info to struct l2cap_chan
      Bluetooth: Move more vars to struct l2cap_chan
      Bluetooth: Move conn to struct l2cap_chan
      Bluetooth: Fix memory leak with L2CAP channels
      Bluetooth: Don't export l2cap_sock_ops

Ido Yariv (5):
      wl12xx: Clean up and fix the 128x boot sequence
      wl12xx: Clean up the block size alignment code
      wl12xx: Clean up the dummy packet mechanism
      wl12xx: Simplify TX blocks accounting
      wl12xx: Handle platforms without level trigger interrupts

Ivo van Doorn (4):
      rt2x00: Reduce tx status reading timeout
      rt2x00: Optimize TX_STA_FIFO register reading
      rt2x00: Fix optimize register access for rt2800pci
      rt2x00: Add autowake support for USB hardware

Johan Hedberg (14):
      Bluetooth: Add basic discovery commands to the management interfa=
ce
      Bluetooth: Add discovering event to the Management interface
      Bluetooth: Add automated SSP user confirmation responses
      Bluetooth: Add variable SSP auto-accept delay support
      Bluetooth: Fix HCI_CONN_AUTH_PEND flag for all authentication req=
uests
      Bluetooth: Add confirm_hint parameter to user confirmation reques=
ts
      Bluetooth: Fix reason code for pairing rejection
      Bluetooth: Fix logic in hci_pin_code_request_evt
      Bluetooth: Fix link key persistent storage criteria
      Bluetooth: Fix old_key_type logic for non-persistent keys
      Bluetooth: Fix connection key type updating for buggy controllers
      Bluetooth: Remove old_key_type from mgmt_ev_new_key
      Bluetooth: Add store_hint parameter to mgmt_new_key
      Bluetooth: Fix updating conn->auth_type in hci_io_capa_request_ev=
t

Johannes Berg (18):
      iwlagn: simplify error table reading
      iwlagn: clean up some exit code
      iwlagn: refactor down path
      iwlagn: refactor up path
      iwlagn: extend notification wait function
      iwlagn: make iwlagn_wait_notification return error code
      iwlagn: leave notification waits on firmware errors
      iwlagn: implement synchronous firmware load
      iwlagn: combine firmware code/data
      iwlagn: remove hw_ready variable
      mac80211: tear down BA sessions properly on suspend
      iwlagn: avoid hangs when restarting device
      iwlagn: introduce silent grabbing of NIC access
      iwlagn: refactor restart
      iwlagn: use proper good CRC threshold behaviour
      iwlagn: remove spectrum measurement header
      iwlagn: improve RXON checking
      iwlagn: prefer BSS context

John W. Linville (10):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      mwl8k: replace rateinfo bitfields with mask and shift macros
      ath5k: fix uninitialized var warning for txf2txs
      b43: avoid uninitialized variable warnings in phy_n
      mwifiex: fix copy-n-paste 'thinko' for tsf_val
      p54: avoid uninitialized variable warning for freq
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Juuso Oikarinen (3):
      wl12xx: Fix potential incorrect band in rx-status
      wl12xx: Add mutex protection for interface list
      wl12xx: Handle duplicate calling of remove interface

Larry Finger (2):
      rtlwifi: rtl8192ce: rtl8192cu: Fix most sparse warnings
      rtlwifi: Fix typo in pci.c

Luciano Coelho (11):
      wl12xx: add new board_tcxo_clock element to the platform data
      wl12xx: 1281/1283 support - add block size handling for sdio and =
spi
      wl12xx: use 1 spare TX block instead of two
      wl12xx: set the skbuff priority for dummy packets
      wl12xx: fix SG BT load value to reflect its new meaning
      wl12xx: fix a couple of sparse warnings about undeclared function=
s
      wl12xx: use a bitmask instead of list of booleans in scanned_ch
      wl12xx: use kstrtoul functions
      wl12xx: move hardcoded hci_io_ds value into the conf struct
      wl12xx: remove unused conf_radio_params structure
      wl12xx: fix sparse warning about undeclared wl12xx_alloc_dummy_pa=
cket

Luis R. Rodriguez (1):
      cfg80211: fix regresion on reg user timeout

Mohammed Shafi Shajakhan (3):
      ath9k: remove the unlikely check for autosleep
      ath9k: Add TSFOOR interrupt stats in debug info
      mac80211: Fix a warning due to skipping tailroom reservation for =
IV

Nishant Sarmukadam (2):
      mwl8k: Reserve buffers for tx management frames
      mwl8k: Enable life time expiry for tx packets in the hardware

Ohad Ben-Cohen (3):
      wl12xx: update bet_max_consecutive
      wl12xx: fix roaming
      wl12xx: fix "JOIN while associated" commentary

Pradeep Nemavat (2):
      mwl8k: Do not stop tx queues
      mwl8k: Add timestamp information for tx packets

Rafa=C5=82 Mi=C5=82ecki (10):
      ssb: pci: trivial: correct amount of maximum retries
      ssb: cc: use correct min_msk for 0x4312
      ssb: cc: add & fix defines
      ssb: cc: clear GPIOPULL registers on init
      ssb: mark bus as powered up earlier
      ssb: update reject bit for Target State Low
      ssb: pci: separate workarounds
      ssb: pci: update PCIe workarounds
      ssb: pci: early fix for SPROM core index
      ssb: cc: prepare clockmode support for cores rev 10+

Rajkumar Manoharan (3):
      ath9k_hw: Fix Tx IQ Calibration hang issue in AR9003 chips
      ath9k: set beacon related ps flags on bss_info change
      mac80211: Fix warnings due to -Wunused-but-set-variable

Randy Dunlap (1):
      libertas: use kernel-doc notation, fix comment style

Senthil Balasubramanian (5):
      ath9k: Fix LED gpio for AR93xx chipsets.
      ath9k_hw: Fix incorrect baseband PLL phase shift for AR9485
      ath9k: optimize the usage of power save wrappers.
      ath9k: cleanup hw pll work handler
      ath9k: Add power save wrappers and modularize hw_pll handler

Shahar Levi (11):
      wl12xx: 1281/1283 support - move IRQ polarity
      wl12xx: 1281/1283 support - Add Definitions
      wl12xx: 1281/1283 support - Add acx commands
      wl12xx: 1281/1283 support - New radio structs and functions
      wl12xx: 1281/1283 support - Loading FW & NVS
      wl12xx: 1281/1283 support - New boot sequence
      wl12xx: 1281/1283 support - use dynamic memory for the RX/TX pool=
s
      wl12xx: 1281/1283 support - Improve Tx & Rx path
      wl12xx: 1281/1283 support - Add dummy packet support
      wl12xx: 1281/1283 support - enable chip support
      wl12xx: Add support for 11n Rx STBC one spatial stream

Stanislaw Gruszka (12):
      iwlwifi: fix possible data overwrite in hcmd callback
      iwlagn: fix tx power initialization
      iwlegacy: remove duplicate initialization in iwl4956_down()
      iwlegacy: enable only rfkill interrupt when device is down
      iwlegacy: simplify init geos
      iwlegacy: remove unneeded disable_hw_scan check
      iwlegacy: remove unneeded __packed
      iwlegacy: remove scan_tx_antennas
      iwlegacy: comment typo fix diable -> disable
      iwlegacy: fix enqueue hcmd race conditions
      iwlegacy: more priv->mutex serialization
      iwlegacy: remove sync_cmd_mutex

Sujith Manoharan (13):
      ath9k: Fix warnings from -Wunused-but-set-variable
      ath9k_htc: Fix AMPDU subframe handling
      ath9k_htc: Fix max A-MPDU size handling
      ath9k_htc: Use power save wrappers when accessing HW
      ath9k_htc: Remove unused macros and structures
      mac80211: Add new API for rate selection
      ath9k_htc: Increase credit size for AR7010 devices
      ath9k_htc: Remove unused WMI_AGGR_LIMIT_CMD
      ath9k_htc: Add a new WMI command to set a rate mask
      ath9k_htc: Add set_bitrate_mask() callback
      ath9k_htc: Dump base eeprom header for UB91/94/95
      ath9k_htc: Dump modal eeprom header for UB91/94/95
      ath9k_htc: Revamp LED management

Vasanthakumar Thiagarajan (24):
      ath9k_hw: Define devid and mac version for AR9340
      ath9k_hw: Take care of few host interface register changes for AR=
9340
      ath9k_hw: Get AHB clock information from ath9k_platform_data
      ath9k_hw: Configure pll control register accordingly for AR9340
      ath9k_hw: Add initvals.h for ar9340
      ath9k_hw: Initialize mode registers from initvals.h for AR9340
      ath9k_hw: Don't do ani initialization for AR9340
      ath9k_hw: Initialize tx and rx gain table from initvals.h for ar9=
340
      ath9k_hw: Read spur frequency information from eeprom for AR9340
      ath9k_hw: Configure RF channel freqency for AR9340
      ath9k_hw: Clean up rx/tx chain configuration before AGC/IQ cal
      ath9k_hw: Fix register offset AR_PHY_65NM_CH0_THERM for AR9340
      ath9k_hw: Don't configure AR_CH0_THERM for AR9340
      ath9k_hw: Skip internal regulator configuration for AR9340
      ath9k_hw: Configure tuning capacitance value for AR9340 as well
      ath9k_hw: Enable byte Tx/Rx data swap for AR9340
      ath9k_hw: Configure chain switch table and attenuation control on=
ly for active chains
      ath9k_hw: Read iq calibration data only for active chains
      ath9k: Add AR9340 platform id to id table
      ath9k_hw: Assign macversion based on devid for built-in wmac
      ath9k_hw: Disable INTR_HOST1_FATAL to avoid interrupt strom with =
ar9430
      ath9k_hw: Enable AR9340 support
      ath9k: Fix bug in configuring hw timer
      ath9k: Fix warning: symbol 'ath9k_platform_id_table' was not decl=
ared. Should it be static?

Vivek Natarajan (4):
      ath9k_hw: Move bt_stomp to hw from common.
      ath9k_hw: Add support for btcoexistence in AR9300.
      ath9k_hw: Enable generic timer interrupt.
      ath9k: Use ps wrappers for btcoex logic.

Waldemar Rymarkiewicz (6):
      Bluetooth: Add definitions for link key types
      Bluetooth: Don't modify sec_level if auth failed
      Bluetooth: Map sec_level to link key requirements
      Bluetooth: Ignore key unauthenticated for high security
      Bluetooth: Respect local MITM req in io_cap reply
      Bluetooth: Add secure flag for mgmt_pin_code_req

Wey-Yi Guy (5):
      iwlagn: make rxon_assoc static function
      iwlagn: remove 5000 from rxon_assoc structure
      iwlagn: connect and disconnect sequence for RXON
      iwlagn: new 105 series device
      iwlagn: remove un-necessary debugfs callback

Yogesh Ashok Powar (2):
      mac80211: Skip tailroom reservation for full HW-crypto devices
      mwl8k: Reducing extra_tx_headroom for tx optimization in AP mode

 drivers/net/wireless/ath/ath5k/reset.c             |    5 +
 drivers/net/wireless/ath/ath9k/ahb.c               |    6 +-
 drivers/net/wireless/ath/ath9k/ani.c               |    6 -
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  387 ++---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   61 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  101 ++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   36 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   25 +-
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   | 1525 ++++++++++++=
++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |    2 +
 drivers/net/wireless/ath/ath9k/beacon.c            |    6 -
 drivers/net/wireless/ath/ath9k/btcoex.c            |  100 ++-
 drivers/net/wireless/ath/ath9k/btcoex.h            |   20 +-
 drivers/net/wireless/ath/ath9k/common.c            |   31 -
 drivers/net/wireless/ath/ath9k/common.h            |    8 -
 drivers/net/wireless/ath/ath9k/debug.c             |    5 +
 drivers/net/wireless/ath/ath9k/debug.h             |    4 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    4 +
 drivers/net/wireless/ath/ath9k/gpio.c              |   19 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    3 +
 drivers/net/wireless/ath/ath9k/htc.h               |   89 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |    6 +-
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |  477 ++++++-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |  204 +---
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   41 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   95 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    2 -
 drivers/net/wireless/ath/ath9k/htc_hst.h           |   11 -
 drivers/net/wireless/ath/ath9k/hw.c                |  125 ++-
 drivers/net/wireless/ath/ath9k/hw.h                |   13 +-
 drivers/net/wireless/ath/ath9k/init.c              |    2 +
 drivers/net/wireless/ath/ath9k/mac.c               |   13 +-
 drivers/net/wireless/ath/ath9k/main.c              |   49 +-
 drivers/net/wireless/ath/ath9k/phy.h               |    3 +
 drivers/net/wireless/ath/ath9k/rc.c                |   12 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    5 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   99 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    4 +-
 drivers/net/wireless/ath/ath9k/wmi.h               |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   23 -
 drivers/net/wireless/ath/carl9170/carl9170.h       |    2 +
 drivers/net/wireless/ath/carl9170/main.c           |   92 +--
 drivers/net/wireless/ath/carl9170/tx.c             |  157 ++-
 drivers/net/wireless/b43/phy_n.c                   |    7 +-
 drivers/net/wireless/iwlegacy/iwl-4965-lib.c       |    3 -
 drivers/net/wireless/iwlegacy/iwl-core.c           |   20 +-
 drivers/net/wireless/iwlegacy/iwl-core.h           |    1 -
 drivers/net/wireless/iwlegacy/iwl-dev.h            |    4 +-
 drivers/net/wireless/iwlegacy/iwl-hcmd.c           |    4 +-
 drivers/net/wireless/iwlegacy/iwl-helpers.h        |    6 +
 drivers/net/wireless/iwlegacy/iwl-tx.c             |   52 +-
 drivers/net/wireless/iwlegacy/iwl3945-base.c       |   22 +-
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |   45 +-
 drivers/net/wireless/iwlwifi/Makefile              |    1 -
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   19 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   79 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   36 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   37 +-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     | 1025 ------------=
-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.h     |   70 -
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |   41 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |   50 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  124 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |  259 +++--
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |  245 +++-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  545 +++-----
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   45 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |  105 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   87 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         | 1012 ++++++++++++=
+-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   35 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   50 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    3 -
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   24 -
 drivers/net/wireless/iwlwifi/iwl-io.c              |   36 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   11 +
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   57 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.h        |   92 --
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   15 +-
 drivers/net/wireless/libertas/cfg.c                |   45 +-
 drivers/net/wireless/libertas/cmd.c                |  245 ++--
 drivers/net/wireless/libertas/cmdresp.c            |   19 +-
 drivers/net/wireless/libertas/debugfs.c            |   36 +-
 drivers/net/wireless/libertas/decl.h               |    8 +-
 drivers/net/wireless/libertas/defs.h               |  113 +-
 drivers/net/wireless/libertas/dev.h                |   20 +-
 drivers/net/wireless/libertas/ethtool.c            |    3 +-
 drivers/net/wireless/libertas/host.h               |   33 +-
 drivers/net/wireless/libertas/if_cs.c              |   35 +-
 drivers/net/wireless/libertas/if_spi.c             |  134 ++-
 drivers/net/wireless/libertas/if_spi.h             |   68 +-
 drivers/net/wireless/libertas/if_usb.c             |  113 +-
 drivers/net/wireless/libertas/if_usb.h             |   14 +-
 drivers/net/wireless/libertas/main.c               |   99 +-
 drivers/net/wireless/libertas/mesh.c               |  210 ++-
 drivers/net/wireless/libertas/mesh.h               |    6 +-
 drivers/net/wireless/libertas/rx.c                 |   34 +-
 drivers/net/wireless/libertas/tx.c                 |   34 +-
 drivers/net/wireless/libertas/types.h              |   18 +-
 drivers/net/wireless/mwifiex/11n.c                 |  102 +-
 drivers/net/wireless/mwifiex/11n.h                 |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   61 +-
 drivers/net/wireless/mwifiex/join.c                |    4 +-
 drivers/net/wireless/mwifiex/main.h                |    2 +-
 drivers/net/wireless/mwifiex/scan.c                |   32 +-
 drivers/net/wireless/mwl8k.c                       |  111 +-
 drivers/net/wireless/p54/eeprom.c                  |    2 +-
 drivers/net/wireless/p54/fwio.c                    |   31 +
 drivers/net/wireless/p54/lmac.h                    |    1 +
 drivers/net/wireless/p54/main.c                    |   31 +
 drivers/net/wireless/p54/p54.h                     |    2 +
 drivers/net/wireless/rt2x00/rt2500usb.c            |    1 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |   31 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   14 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   18 +
 drivers/net/wireless/rt2x00/rt2x00config.c         |   31 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   88 ++
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    1 +
 drivers/net/wireless/rtlwifi/base.c                |  720 ++++++++--
 drivers/net/wireless/rtlwifi/base.h                |   60 +-
 drivers/net/wireless/rtlwifi/cam.c                 |  106 ++-
 drivers/net/wireless/rtlwifi/cam.h                 |    5 +-
 drivers/net/wireless/rtlwifi/core.c                |  408 ++++--
 drivers/net/wireless/rtlwifi/core.h                |    1 +
 drivers/net/wireless/rtlwifi/efuse.c               |   97 +-
 drivers/net/wireless/rtlwifi/efuse.h               |    5 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  626 ++++++---
 drivers/net/wireless/rtlwifi/pci.h                 |   15 +-
 drivers/net/wireless/rtlwifi/ps.c                  |  258 +++-
 drivers/net/wireless/rtlwifi/ps.h                  |    9 +
 drivers/net/wireless/rtlwifi/rc.c                  |  212 ++--
 drivers/net/wireless/rtlwifi/rc.h                  |    9 +-
 drivers/net/wireless/rtlwifi/regd.c                |   97 +-
 drivers/net/wireless/rtlwifi/regd.h                |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  523 ++++++-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h  |    2 +
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   81 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  128 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |   76 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |   27 -
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |    2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  509 +++++---
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |   34 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.h       |    2 -
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |  223 +--
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |   55 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |   58 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |   24 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h        |   17 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |  122 ++-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.h        |   14 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |  180 +--
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |   14 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.h       |   14 +
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h        |    4 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   48 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.h       |    5 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   19 +-
 drivers/net/wireless/rtlwifi/usb.h                 |    2 +
 drivers/net/wireless/rtlwifi/wifi.h                |  155 ++-
 drivers/net/wireless/wl12xx/Kconfig                |    2 +-
 drivers/net/wireless/wl12xx/acx.c                  |   93 +-
 drivers/net/wireless/wl12xx/acx.h                  |   23 +-
 drivers/net/wireless/wl12xx/boot.c                 |  285 +++-
 drivers/net/wireless/wl12xx/boot.h                 |   52 +
 drivers/net/wireless/wl12xx/cmd.c                  |   99 ++-
 drivers/net/wireless/wl12xx/cmd.h                  |   34 +
 drivers/net/wireless/wl12xx/conf.h                 |   29 +-
 drivers/net/wireless/wl12xx/debugfs.c              |    2 +-
 drivers/net/wireless/wl12xx/event.c                |   64 +-
 drivers/net/wireless/wl12xx/event.h                |   17 +-
 drivers/net/wireless/wl12xx/ini.h                  |   98 ++-
 drivers/net/wireless/wl12xx/init.c                 |   51 +-
 drivers/net/wireless/wl12xx/init.h                 |    1 +
 drivers/net/wireless/wl12xx/io.c                   |   11 +
 drivers/net/wireless/wl12xx/io.h                   |    3 +
 drivers/net/wireless/wl12xx/main.c                 |  353 ++++-
 drivers/net/wireless/wl12xx/ps.c                   |    3 -
 drivers/net/wireless/wl12xx/reg.h                  |   15 +-
 drivers/net/wireless/wl12xx/rx.c                   |   44 +-
 drivers/net/wireless/wl12xx/scan.c                 |   17 +-
 drivers/net/wireless/wl12xx/sdio.c                 |   27 +-
 drivers/net/wireless/wl12xx/sdio_test.c            |   20 +-
 drivers/net/wireless/wl12xx/spi.c                  |   17 +-
 drivers/net/wireless/wl12xx/testmode.c             |    6 +-
 drivers/net/wireless/wl12xx/tx.c                   |  234 +++-
 drivers/net/wireless/wl12xx/tx.h                   |   60 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |   66 +-
 drivers/ssb/driver_chipcommon.c                    |   68 +-
 drivers/ssb/driver_chipcommon_pmu.c                |    2 +
 drivers/ssb/driver_pcicore.c                       |  131 ++-
 drivers/ssb/main.c                                 |   23 +-
 include/linux/ath9k_platform.h                     |    2 +
 include/linux/ssb/ssb_driver_chipcommon.h          |   11 +-
 include/linux/ssb/ssb_regs.h                       |    2 +-
 include/linux/wl12xx.h                             |   29 +-
 include/net/bluetooth/hci.h                        |    9 +
 include/net/bluetooth/hci_core.h                   |   16 +-
 include/net/bluetooth/l2cap.h                      |   69 +-
 include/net/bluetooth/mgmt.h                       |   10 +-
 include/net/mac80211.h                             |   17 +
 net/bluetooth/cmtp/core.c                          |    3 +-
 net/bluetooth/hci_conn.c                           |   78 +-
 net/bluetooth/hci_core.c                           |   75 +-
 net/bluetooth/hci_event.c                          |  163 ++-
 net/bluetooth/hci_sysfs.c                          |   31 +
 net/bluetooth/hidp/core.c                          |    6 +-
 net/bluetooth/l2cap_core.c                         |  588 ++++----
 net/bluetooth/l2cap_sock.c                         |  242 ++--
 net/bluetooth/mgmt.c                               |   95 ++-
 net/bluetooth/rfcomm/core.c                        |   21 +-
 net/bluetooth/rfcomm/sock.c                        |    5 +-
 net/mac80211/aes_ccm.c                             |    6 +-
 net/mac80211/cfg.c                                 |   15 +-
 net/mac80211/driver-ops.h                          |   18 +
 net/mac80211/driver-trace.h                        |   27 +
 net/mac80211/ibss.c                                |    7 +-
 net/mac80211/ieee80211_i.h                         |    3 +
 net/mac80211/key.c                                 |   21 +-
 net/mac80211/main.c                                |   18 -
 net/mac80211/mesh.c                                |    3 -
 net/mac80211/mesh_hwmp.c                           |    4 -
 net/mac80211/pm.c                                  |   16 +-
 net/mac80211/rx.c                                  |   49 +-
 net/mac80211/sta_info.c                            |    2 -
 net/mac80211/status.c                              |    8 +
 net/mac80211/tx.c                                  |   15 +-
 net/mac80211/work.c                                |    6 +-
 net/mac80211/wpa.c                                 |   62 +-
 net/wireless/core.c                                |   17 +
 net/wireless/reg.c                                 |    3 +-
 244 files changed, 12283 insertions(+), 6490 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9340_initvals.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-spectrum.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-05-05.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
