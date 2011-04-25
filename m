From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-04-25
Date: Mon, 25 Apr 2011 15:30:17 -0400
Message-ID: <20110425193017.GC28814@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60917 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab1DYTpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 15:45:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another big batch of updates intended for 2.6.40...

There is the usual huge batch of changes for ath9k, and iwlagn, a bunch
for ath9k_htc, rt2x00, and ath5k, a few more for mwifiex, and a handful
of others.  Also included is a big batch of Bluetooth updates as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit b71d1d426d263b0b6cb5760322efebbfc89d4463:

  inet: constify ip headers and in6_addr (2011-04-22 11:04:14 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git for-davem

Amitkumar Karwar (4):
      mwifiex: cleanup ioctl wait queue and abstraction layer
      mwifiex: remove unused function parameters
      mwifiex: remove some macro definitions
      mwifiex: optimize driver initialization code

Antonio Ospite (1):
      rfkill: Regulator consumer driver for rfkill

Bing Zhao (2):
      mwifiex: fix cmd_skb headroom decreasing issue
      mwifiex: rename function mwifiex_is_ba_stream_avail

Brian Cavagnolo (1):
      mwl8k: use traffic threshold to decide when to start ampdu

Chaoming Li (1):
      rtlwifi: rtl8192ce: Fix LED initialization

Felix Fietkau (23):
      ath9k: fix PS-Poll reception on AR9160 and earlier
      ath9k: fix too early enabling of rx during ath_startrecv()
      ath9k_hw: remove unnecessary parts of the AR9380 SREV check
      ath5k: fix tx status reporting issues
      ath5k: fix short preamble rate duration value
      ath5k: fix SIFS time handling
      ath5k: fix slot time handling
      ath5k: optimize tx descriptor setup
      ath5k: remove ts_rate from ath5k_tx_status
      ath5k: optimize tx status processing
      ath5k: optimize rx status processing
      ath5k: remove ts_retry from ath5k_tx_status
      ath5k: clean up debugfs code
      ath5k: reduce interrupt load caused by rx/tx interrupts
      mac80211: receive EAP frames from a station in an AP VLAN on the main AP
      ath5k: disable 5 GHz support if a 2.4 GHz radio is detected
      ath: unshare struct ath_bus_ops between ath5k and ath9k
      ath5k: add a new bus op for reading the mac address
      ath5k: fix the EEPROM check for hw AES crypto support
      ath5k: disable 5 GHz support for the dualband PHY chip on dual-radio AR5312
      mac80211: add a function for setting the TIM bit for a specific station
      ath9k: fix powersave frame filtering/buffering in AP mode
      ath9k: assign keycache slots to unencrypted stations

Gabor Juhos (1):
      ath9k: introduce ATH9K_{PCI,AHB} config options

Garen Tamrazian (1):
      iwlagn: fix radar frame rejection

Gertjan van Wingerde (6):
      rt2x00: Linksys WUSB600N rev2 is a RT3572 device.
      rt2x00: Allow dynamic addition of PCI/USB IDs.
      rt2x00: Add USB IDs.
      rt2x00: RT33xx device support is no longer experimental.
      rt2x00: Enable support for RT53xx PCI devices by default.
      rt2x00: Merge rt2x00ht.c contents in other files.

Gustavo F. Padovan (26):
      Bluetooth: Create struct l2cap_chan
      Bluetooth: Use struct list_head for L2CAP channels list
      Bluetooth: Remove struct del_list
      Bluetooth: Move ident to struct l2cap_chan
      Bluetooth: Move conf_{req,rsp} stuff to struct l2cap_chan
      Bluetooth: clean up l2cap_sock_recvmsg()
      Bluetooth: Move conn_state to struct l2cap_chan
      Bluetooth: Move of ERTM *_seq vars to struct l2cap_chan
      Bluetooth: Move more ERTM stuff to struct l2cap_chan
      Bluetooth: Move SDU related vars to struct l2cap_chan
      Bluetooth: Move remote info to struct l2cap_chan
      Bluetooth: Move ERTM timers to struct l2cap_chan
      Bluetooth: Move srej and busy queues to struct l2cap_chan
      Bluetooth: Move busy workqueue to struct l2cap_chan
      Bluetooth: Fix lockdep warning with skb list lock
      Bluetooth: Move SREJ list to struct l2cap_chan
      Bluetooth: Remove some sk references from l2cap_core.c
      Bluetooth: Remove unneeded uninitialized_vars()
      Bluetooth: Move tx queue to struct l2cap_chan
      Bluetooth: Fix wrong comparison in listen()
      Bluetooth: Clean up ath3k_load_firmware()
      Bluetooth: Add proper handling of received LE data
      Bluetooth: Check return value of hci_recv_stream_fragment()
      Bluetooth: Don't lock sock inside l2cap_get_sock_by_scid()
      Bluetooth: Fix another locking unbalance
      Bluetooth: Fix lockdep warning in L2CAP

Helmut Schaa (7):
      rt2x00: Fix stuck queue in tx failure case
      rt2x00: Make rt2x00_queue_entry_for_each more flexible
      rt2x00: Use correct TBTT_SYNC config in AP mode
      rt2x00: Update TX_SW_CFG2 init value
      rt2x00: Use TXOP_HTTXOP for beacons
      rt2x00: Always inline rt2x00pci_enable_interrupt
      rt2x00: Optimize register access in rt2800pci

Ivo van Doorn (5):
      rt2x00: Split rt2x00dev->flags
      rt2x00: Decrease association time for USB devices
      rt2x00: Optimize register access in rt2800usb
      rt2x00: Implement get_ringparam callback function
      rt2x00: Implement get_antenna and set_antenna callback functions

Javier Cardona (9):
      nl80211: rename NL80211_MESH_SETUP_VENDOR_PATH_SEL_IE
      cfg80211/nl80211: Add userspace authentication flag to mesh setup
      mac80211: ignore peers if security is enabled for this mesh
      nl80211/mac80211: let userspace authenticate stations
      mac80211: Let user space receive and send mesh auth/deauth frames
      mac80211: ignore peer link requests from unauthenticated stations.
      nl80211/mac80211: Perform PLINK_ACTION on new station
      nl80211: New notification to discover mesh peer candidates.
      mac80211: send notification on new peer candidate for our secure mesh

Jiejing Zhang (1):
      Bluetooth: hci_uart: check the return value of recv()

Johannes Berg (7):
      iwlwifi: fix bugs in change_interface
      iwlagn: clean up & autodetect statistics
      iwlagn: downgrade warning on unknown TLV
      iwlagn: remove most BUG_ON instances
      iwlagn: verify that huge commands are synchronous
      iwlagn: use huge command for beacon
      mac80211: explain padding in place of rate field

Johannes Stezenbach (4):
      rt2800usb: read TX_STA_FIFO asynchronously
      rt2x00: fix queue timeout checks
      rt2800usb: handle TX status timeouts
      rt2800usb: add timer to handle TX_STA_FIFO

John W. Linville (6):
      ath5k: improve pcal error handling for ENOMEM case
      ath5k: improve comments for optimized tx descriptor setup
      ath9k: avoid using trinary operator w/ TX_STAT_INC
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6 into for-davem

Kevin Gan (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8787

Larry Finger (1):
      rtlwifi: Fix unitialized variable warnings

Layne Edwards (1):
      rt2x00: Enable WLAN LED on Ralink SoC (rt305x) devices

Luis R. Rodriguez (1):
      ath: fix 0x6C for beaconing/passive scan flags based on country IE

Mark Davis (1):
      rt2800usb: Add seven new USB IDs

Mohammed Shafi Shajakhan (1):
      {mac|nl}80211: Add station connected time

Nishant Sarmukadam (1):
      mwl8k: interrupt handling changes

Paul Bolle (1):
      iwl4965: drop a lone pr_err()

Rajkumar Manoharan (10):
      ath9k_hw: Fix instable target power control b/w CCK/OFDM
      ath9k: Fix kernel panic on module unload
      ath9k_hw: Remove unused code in AR9287 eeprom
      ath9k_hw: update Ar9003 intervals to fix carrier leak
      ath9k_hw: update AR9003 low_ob_db_tx_gain to improve spur performance
      ath9k: Fix improper beacon slot selection in IBSS
      ath9k_htc: Add debugfs support to change debug mask
      ath9k_htc: Cleanup HTC debugfs
      ath9k_htc: Fix free slot value for cab queue
      ath9k: Fix beacon generation on foreign channel

Randy Dunlap (1):
      mac80211: fix debugfs printk format warning

Senthil Balasubramanian (3):
      ath9k: Add RSSI information from control and extension chains
      ath9k: Update gain table for AR9485
      ath: Add a missing world regulatory domain 0x6C

Sergei Shtylyov (1):
      iwlegacy: use pci_dev->revision

Sujith Manoharan (40):
      ath9k_htc: Remove AR7010 v1.0 support
      ath9k_htc: Rename firmware
      ath9k_htc: Add a WMI command to get the firmware version
      ath9k_htc: Fix WMI and beacon header
      ath9k_htc: Add beacon slots
      ath9k_htc: Add TSF adjust capability
      ath9k_htc: Configure the beacon queue
      ath9k_htc: Handle buffered frames in AP mode
      ath9k_htc: Fix beacon miss under heavy load
      ath9k_htc: Queue WMI events
      ath9k_htc: Move debug code to a separate file
      ath9k_htc: Add RX error statistics
      ath9k_htc: Fix RX length check
      ath9k_htc: Remove unused WMI commands
      ath9k_htc: Use SKB's private area for TX parameters
      ath9k_htc: Sync struct ath9k_htc_target_sta with FW
      ath9k_htc: Sync struct ath9k_htc_target_vif with FW
      ath9k_htc: Sync struct ath9k_htc_cap_target with FW
      ath9k_htc: Remove unused WMI_WLAN_TXCOMP_EVENTID
      ath9k_htc: Move TX specific stuff to a separate structure
      ath9k_htc: Reduce TX queue size
      ath9k_htc: Sync MGMT/DATA packet headers with firmware
      ath9k_htc: Add a new WMI event WMI_TXSTATUS_EVENTID
      ath9k_htc: Increase URB count for REG_IN pipe
      ath9k_htc: Fix TX queue management
      ath9k_htc: Introduce new HTC API
      ath9k_htc: Move endpoint header parsing to TX tasklet
      ath9k_htc: Add TX slots
      ath9k_htc: Use helper functions for TX processing
      ath9k_htc: Drain pending TX frames properly
      ath9k_htc: Optimize HTC start/stop API
      ath9k_htc: Drain packets on station removal
      ath9k_htc: Add support for TX completion
      ath9k_htc: Add a debugfs file to dump TX slot information
      ath9k_htc: Add a debugfs file showing endpoint status
      ath9k_htc: Add a timer to cleanup WMI events
      ath9k_htc: Use separate URB pool for management frames
      ath9k_htc: Use helper routines for transmission
      ath9k_htc: Add detailed firmware statistics
      ath9k_htc: Enable AP and P2P modes

Szymon Janc (1):
      Bluetooth: Fix Out Of Band pairing when mgmt interface is disabled

Vasanthakumar Thiagarajan (2):
      ath9k: Implement integer mode for AR9485
      ath9k: Register id table for platform device

Vivek Natarajan (2):
      mac80211: Check for queued frames before entering power save.
      ath9k: Implement dev_tx_frames_pending callback.

Wey-Yi Guy (18):
      iwlagn: remove un-necessary function pointer
      iwlagn: PAPD read for 2000 series devices
      iwlagn: no 3945 define needed
      iwlagn: remove unused 3945 define
      iwlagn: cleanup to remove the reference for 3945
      iwlagn: remove more reference to legacy devices
      iwlagn: remove un-needed configuration
      iwlagn: more cleanup to remove unused reference
      iwlagn: all _agn devices support power save mode
      iwlagn: tx power calib always done in firmware
      iwlagn: sensitivity and chain noise done by driver
      iwlagn: use direct call for led functions
      iwlagn: always support uCode trace
      iwlagn: temperature should be measure for all _agn devices
      iwlagn: no 5.2GHz/HT40 support for bgn devices
      iwlagn: remove un-necessary ieee80211_ops
      iwlagn: remove legacy ops
      iwlagn: remove led_ops

Yogesh Ashok Powar (4):
      mwifiex: use common keyinfo bitmap for different key types
      mwl8k: Fix checkpatch.pl and sparse warnings and errors
      mwifiex: remove redundant "return" at end of void function
      mwifiex: remove redundant local variables and comments

cozybit Inc (1):
      mac80211: Allocate new mesh path and portal tables before taking locks

roel (2):
      ath9k_hw: index out of bounds
      ath9k: index out of bounds

root (1):
      iwlwifi: remove extranious macro from firmware define

 drivers/bluetooth/Kconfig                          |    4 +-
 drivers/bluetooth/ath3k.c                          |    3 -
 drivers/bluetooth/btmrvl_sdio.c                    |  124 ++-
 drivers/bluetooth/btmrvl_sdio.h                    |   68 +-
 drivers/bluetooth/hci_ath.c                        |    7 +-
 drivers/bluetooth/hci_h4.c                         |    7 +-
 drivers/bluetooth/hci_ldisc.c                      |    6 +-
 drivers/net/wireless/ath/ath.h                     |    9 +-
 drivers/net/wireless/ath/ath5k/ahb.c               |   28 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |   31 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    7 +-
 drivers/net/wireless/ath/ath5k/base.c              |   71 +-
 drivers/net/wireless/ath/ath5k/base.h              |    7 +-
 drivers/net/wireless/ath/ath5k/caps.c              |    3 +
 drivers/net/wireless/ath/ath5k/debug.c             |   65 +-
 drivers/net/wireless/ath/ath5k/debug.h             |   17 -
 drivers/net/wireless/ath/ath5k/desc.c              |  158 +--
 drivers/net/wireless/ath/ath5k/eeprom.c            |  158 +--
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    9 +
 drivers/net/wireless/ath/ath5k/pci.c               |   32 +
 drivers/net/wireless/ath/ath5k/pcu.c               |   35 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    4 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   21 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    6 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   14 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |   12 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    6 +
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  178 ++--
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   12 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   17 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |   10 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   12 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   44 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   40 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    7 +
 drivers/net/wireless/ath/ath9k/eeprom.h            |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   26 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   25 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |  334 ++++--
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    7 +-
 drivers/net/wireless/ath/ath9k/htc.h               |  211 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |  318 ++++-
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |  505 ++++++++
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |   12 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   91 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  322 ++----
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |  790 +++++++++---
 drivers/net/wireless/ath/ath9k/htc_hst.c           |   50 +-
 drivers/net/wireless/ath/ath9k/htc_hst.h           |   14 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    5 +
 drivers/net/wireless/ath/ath9k/hw.c                |   45 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    9 +
 drivers/net/wireless/ath/ath9k/mac.h               |    1 -
 drivers/net/wireless/ath/ath9k/main.c              |   63 +
 drivers/net/wireless/ath/ath9k/phy.h               |    1 -
 drivers/net/wireless/ath/ath9k/rc.c                |    3 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    6 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   35 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |  122 ++-
 drivers/net/wireless/ath/ath9k/wmi.h               |   80 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  111 ++-
 drivers/net/wireless/ath/key.c                     |    6 +-
 drivers/net/wireless/ath/regd.c                    |    8 +-
 drivers/net/wireless/ath/regd_common.h             |    2 +
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c        |    1 -
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |    2 +-
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   24 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   43 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   34 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   52 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   43 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     |  134 +--
 drivers/net/wireless/iwlwifi/iwl-agn-led.c         |   73 --
 drivers/net/wireless/iwlwifi/iwl-agn-led.h         |   33 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   39 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   13 +
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |    3 +
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   66 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    3 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   64 -
 drivers/net/wireless/iwlwifi/iwl-core.c            |   71 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   56 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   53 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   44 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    6 -
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    1 -
 drivers/net/wireless/iwlwifi/iwl-fh.h              |   38 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   13 +
 drivers/net/wireless/iwlwifi/iwl-led.c             |   30 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c           |   17 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   16 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |  319 +++---
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    9 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   39 +-
 drivers/net/wireless/mwifiex/11n.c                 |   34 +-
 drivers/net/wireless/mwifiex/11n.h                 |   53 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    5 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   36 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |    6 +-
 drivers/net/wireless/mwifiex/README                |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  224 ++---
 drivers/net/wireless/mwifiex/cfp.c                 |   17 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |  194 ++--
 drivers/net/wireless/mwifiex/debugfs.c             |    7 +-
 drivers/net/wireless/mwifiex/decl.h                |   38 +-
 drivers/net/wireless/mwifiex/fw.h                  |   29 +-
 drivers/net/wireless/mwifiex/init.c                |   14 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    3 +-
 drivers/net/wireless/mwifiex/join.c                |  128 +--
 drivers/net/wireless/mwifiex/main.c                |  174 +--
 drivers/net/wireless/mwifiex/main.h                |  142 +--
 drivers/net/wireless/mwifiex/scan.c                |  154 +--
 drivers/net/wireless/mwifiex/sdio.c                |   49 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |  127 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   47 +-
 drivers/net/wireless/mwifiex/sta_event.c           |   25 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           | 1081 +++-------------
 drivers/net/wireless/mwifiex/sta_tx.c              |    8 +-
 drivers/net/wireless/mwifiex/txrx.c                |    4 +-
 drivers/net/wireless/mwifiex/util.c                |   55 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   24 +-
 drivers/net/wireless/mwifiex/wmm.h                 |    8 +-
 drivers/net/wireless/mwl8k.c                       |   77 +-
 drivers/net/wireless/rt2x00/Kconfig                |   26 +-
 drivers/net/wireless/rt2x00/Makefile               |    1 -
 drivers/net/wireless/rt2x00/rt2400pci.c            |   29 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   28 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   85 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  135 ++-
 drivers/net/wireless/rt2x00/rt2800pci.c            |  244 ++--
 drivers/net/wireless/rt2x00/rt2800usb.c            |  621 ++++++----
 drivers/net/wireless/rt2x00/rt2x00.h               |   97 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   77 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |    4 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   42 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   23 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c             |  136 --
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   34 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |   12 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   95 ++-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  159 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   33 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |  126 ++-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   31 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   64 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |  189 ++--
 drivers/net/wireless/rtlwifi/base.c                |   12 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |   14 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.h       |    1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    2 +-
 include/linux/nl80211.h                            |   34 +-
 include/linux/rfkill-regulator.h                   |   48 +
 include/net/bluetooth/l2cap.h                      |  130 +-
 include/net/cfg80211.h                             |   33 +-
 include/net/mac80211.h                             |   16 +
 net/bluetooth/hci_event.c                          |    4 +
 net/bluetooth/l2cap_core.c                         | 1344 +++++++++++---------
 net/bluetooth/l2cap_sock.c                         |   72 +-
 net/mac80211/cfg.c                                 |   29 +-
 net/mac80211/debugfs_sta.c                         |   26 +
 net/mac80211/driver-ops.h                          |   13 +
 net/mac80211/driver-trace.h                        |   20 +
 net/mac80211/ieee80211_i.h                         |    5 +-
 net/mac80211/main.c                                |    9 +-
 net/mac80211/mesh.c                                |   14 +-
 net/mac80211/mesh.h                                |    3 +-
 net/mac80211/mesh_pathtbl.c                        |   49 +-
 net/mac80211/mesh_plink.c                          |   35 +-
 net/mac80211/mlme.c                                |   17 +-
 net/mac80211/rx.c                                  |   26 +-
 net/mac80211/sta_info.c                            |   16 +-
 net/mac80211/sta_info.h                            |    5 +
 net/mac80211/tx.c                                  |    2 +-
 net/rfkill/Kconfig                                 |   11 +
 net/rfkill/Makefile                                |    1 +
 net/rfkill/rfkill-regulator.c                      |  164 +++
 net/wireless/mesh.c                                |   23 +-
 net/wireless/nl80211.c                             |   67 +-
 net/wireless/nl80211.h                             |    4 +
 192 files changed, 7204 insertions(+), 5938 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_drv_debug.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-led.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-led.h
 delete mode 100644 drivers/net/wireless/rt2x00/rt2x00ht.c
 create mode 100644 include/linux/rfkill-regulator.h
 create mode 100644 net/rfkill/rfkill-regulator.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2011-04-25.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
