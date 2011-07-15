From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-07-15
Date: Fri, 15 Jul 2011 11:34:36 -0400
Message-ID: <20110715153435.GA2566@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57778 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab1GOPrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 11:47:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is yet another batch of wireless networking changes intended
for 3.1, with probably a smidge more yet to come... :-)

This includes another Bluetooth pull, mostly some cleanups,
restructuring, and some minor fixes.  Along with the usual iwlagn and
ath9k updates, mwifiex, wl12xx, ath5k, and b43 all see significant
activity.  Johannes has done some housekeeping in mac80211 as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ecae42d37045ec71831d0e0e493e00b0e073=
2edd:

  net/ps3: Fix gelic RX DMA restart (2011-07-14 16:03:29 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Amitkumar Karwar (3):
      mwifiex: fix regression in WEP security mode
      mwifiex: fix minor issue in debugfs command 'info'
      mwifiex: 11n specific configuration for transmit

Andre Guedes (7):
      Bluetooth: Add extfeatures to struct hci_dev
      Bluetooth: Write LE Host Supported command
      Bluetooth: Add enable_le module parameter
      Bluetooth: Add lmp_host_le_capable() macro
      Bluetooth: Remove enable_smp parameter
      Bluetooth: Fix potential deadlock in hci_core
      Bluetooth: Fix potential deadlock in mgmt

Arik Nemtsov (7):
      wl12xx: AP mode - support FW TX inactivity triggers
      wl12xx: use 802.11 header location after relocation to frame star=
t
      wl12xx: schedule TX packets according to FW occupancy
      wl12xx: implement Tx watermarks per AC
      wl12xx: initialize max_power levels for 11a channels
      wl12xx: always initialize AP-mode max power level
      wl12xx: start/stop queues according to global per-AC counters

Christian Lamparter (1):
      carl9170: Implement tx_frames_pending mac80211 callback function

Daniel Drake (1):
      libertas: fix handling of command timeout, completion and interru=
ption

Don Fry (1):
      iwlagn: remove iwlagn_hcmd_utils structure and call directly

Eduardo Bacchi Kienetz (1):
      rt2800usb: Add new device ID for Belkin

Eliad Peller (3):
      wl12xx: configure suspend/resume only if associated/started
      wl12xx: add stop_scan command
      wl12xx: implement cancel_hw_scan() callback

Emmanuel Grumbach (7):
      iwlagn: remove the CMD_MAPPED flag
      iwlagn: add an API to free the TX context
      iwlagn: add an API for RX stop
      iwlagn: add an API for TX stop
      iwlagn: remove code duplication
      iwlagn: consolidate the API that sends host commands and move to =
transport
      iwlagn: provide heplers to access the transport ops

=46elix Fietkau (17):
      ath9k_hw: remove hardcoded PLL overrides for AR9280
      ath9k_hw: always enable 5 GHz fast clock for AR9280
      ath9k_hw: fix MAC clock for half/quarter rate
      ath9k_hw: fix MAC clock rate for AR9287 v1.3+
      ath9k_hw: initialize more timing related registers for half/quart=
er channels
      ath9k_hw: remove ar9287 v1.3+ specific hardcoded register hacks
      ath9k_hw: set 5 GHz half/quarter channels on AR9002 using fractio=
nal mode
      ath9k_hw: fix synth delay for half/quarter channels
      ath9k_hw: add a missing delay for an analog register
      ath5k: add missing checks for rfgain probe
      ath5k: apply the synth voltage tweak only on AR5112 rev 2
      ath5k: fix reference clock frequency for spur mitigation on AR241=
3
      ath5k: initialize common->clockrate
      ath5k: delay full calibration after reset
      ath5k: fix reference clock usec duration setting restore
      ath5k: disable 32KHz sleep clock operation by default
      ath5k: do not call ieee80211_stop_queue for queues not managed by=
 mac80211

=46ry, Donald H (3):
      iwlagn: remove the indirection for update_chain_flags
      iwlagn: remove the indirection for iwl_apm_init
      iwlagn: remove indirection for eeprom_query_addr

Gustavo F. Padovan (2):
      Bluetooth: Fix bad locking balance
      Bluetooth: Clean up unused struct hci_conn items

Hauke Mehrtens (1):
      bcma: add check if sprom is available before accessing it.

Ido Yariv (1):
      wl12xx: Increase low & high TX watermarks

Ilia Kolomisnky (1):
      Bluetooth: Fixes l2cap "command reject" reply according to spec

Joe Perches (5):
      Bluetooth: Rename function bt_err to bt_to_errno
      Bluetooth: Add bt_printk
      ath5k: Add missing breaks in switch/case
      iwlegacy: Add missing comma between constant string array
      iwlagn: Add missing comma between constant string array

Johannes Berg (11):
      mac80211: fix TKIP races, make API easier to use
      mac80211: fix CCMP races
      mac80211: fix CMAC races
      mac80211: use AES_BLOCK_SIZE
      mac80211: simplify RX PN/IV handling
      mac80211: allow drivers to access key sequence counter
      mac80211: allow driver to generate P1K for IV32
      cfg80211: fix docbook
      mac80211: fix docbook
      mac80211: allocate only one RX queue
      mac80211: allow driver to disconnect after resume

John W. Linville (4):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth=
-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix duplicate if test

Luciano Coelho (1):
      cfg80211: return -ENOENT when stopping sched_scan while not runni=
ng

Mat Martineau (6):
      Bluetooth: Fix indentation whitespace
      Bluetooth: ERTM timeouts need to be converted to jiffies
      Bluetooth: Check earlier for L2CAP ERTM frames to drop
      Bluetooth: Move code for ERTM local busy state to separate functi=
ons
      Bluetooth: Use event-driven approach for handling ERTM receive bu=
ffer
      Bluetooth: Remove L2CAP busy queue

Meenakshi Venkataraman (2):
      mac80211: add driver RSSI threshold events
      iwlagn: Enable/disable PS poll based on RSSI and BT coex traffic =
state

Mohammed Shafi Shajakhan (3):
      ath9k_hw: Disable PAPRD based on paprd_ht20_mask for 5GHz
      ath9k: remove an unnecessary function declaration
      mac80211: remove a redundant check

Ohad Ben-Cohen (1):
      wl12xx: one SDIO initialization is enough

Olivier Sobrie (1):
      libertas: fix errors in functions accessing module registers

Oz Krakowski (1):
      wl12xx: fix Tx security sequence number handling

Pavel Roskin (14):
      ath5k: remove PRIV_ENTRY and PRIV_ASSIGN macros, they obfuscate t=
he code
      ath5k: replace spaces with tabs as suggested by checkpatch.pl
      ath5k: remove unneeded parentheses after return
      ath5k: use KERN_WARNING in ATH5K_PRINTF
      ath5k: use DEFINE_PCI_DEVICE_TABLE in led.c, mark users with __de=
vinit
      ath5k: use more readable way to clear MAC address
      ath5k: don't use volatile, it's not needed
      ath5k: use parentheses around macro definitions
      ath5k: fix misplaced or extraneous braces found by checkpatch.pl
      ath5k: fix formatting errors found by checkpatch.pl
      ath5k: use kstrtoint() to parse numbers coming from sysfs
      ath5k: read sc->imask with sc->irqlock held
      ath5k: validate mode in ath5k_ani_init() before trying to set it
      ath5k: fix typos, bad comment formatting and GHz in place of MHz

Rafa=C5=82 Mi=C5=82ecki (13):
      b43: make b43_wireless_init bus generic
      b43: implement BCMA bus ops
      b43: use switches for SSB specific code
      b43: handle BCMA in bus switches
      b43: bus: add helpers for getting/setting wldev from/in bus core
      b43: change selecting ucode for newer cores
      b43: select BLOCKIO for BCMA
      b43: use radio ID reading code to older cores only
      b43: read radio ID on new cores
      b43: LCN-PHY add place for new PHY support
      b43: define firmwares for HT and LCN PHYs
      b43: LCN-PHY: include new PHY in common code
      b43: HT-PHY: define dummy TX power functions

Rajkumar Manoharan (6):
      ath9k_htc: do not configure filter before driver is started
      mac80211: Restart STA timers only on associated state
      ath9k_hw: Update AR9003 interval to improve 5G Tx EVM
      ath9k_hw: Disable power detector calibration for AR9003
      ath9k_hw: Remove read-only registers from AR9003 intervals
      ath9k_htc: Inform stack about tx ack status

Randy Dunlap (1):
      Bluetooth: uses crypto interfaces, select CRYPTO

Sebastian Andrzej Siewior (1):
      net/b43: don't return IRQ_HANDLED if nothing was done

Senthil Balasubramanian (1):
      ath9k_hw: Fix incorrect key_miss handling

Steven.Li (1):
      Bluetooth: Add Atheros AR3012 one PID/VID supported

Vinicius Costa Gomes (12):
      Bluetooth: Add support for SMP phase 3 (key distribution)
      Bluetooth: Add new structures for supporting SM key distribution
      Bluetooth: Add functions to manipulate the link key list for SMP
      Bluetooth: Reject an encryption request when the key isn't found
      Bluetooth: Fix SM pairing parameters negotiation
      Bluetooth: Add support for storing the LTK
      Bluetooth: Use the link key list to temporarily store the STK
      Bluetooth: Use the stored LTK for restabilishing security
      Bluetooth: Remove unused field in hci_conn
      Bluetooth: Add support for communicating keys with userspace
      Bluetooth: Add support for storing the key size
      Bluetooth: Add support for returning the encryption key size

Wey-Yi Guy (9):
      iwlagn: remove the indirection for the dma channel num
      iwlagn: remove double level temperature indirect call
      iwlagn: use bt handler for 2030 and 135 series devices
      iwlagn: declare static
      iwlagn: add CMD_ON_DEMAND flag for host command from testmode
      iwlagn: allow application own the uCode operation
      iwlagn: block regular host commands if driver don't own uCode
      iwlagn: separate and enhance the fixed rate from
      iwlagn: fix warning in testmode attribute table

Yogesh Ashok Powar (2):
      mwifiex: 4-byte alignment in mwifiex_process_sta_txpd()
      mwifiex: add cfg80211 handler for set_bitrate_mask

 Documentation/DocBook/80211.tmpl                   |    5 +-
 drivers/bcma/main.c                                |    4 +-
 drivers/bcma/sprom.c                               |    3 +
 drivers/bluetooth/ath3k.c                          |    5 +
 drivers/bluetooth/btusb.c                          |   12 +-
 drivers/net/wireless/ath/ath5k/ahb.c               |    4 +-
 drivers/net/wireless/ath/ath5k/ani.c               |    9 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |  167 +++++-----
 drivers/net/wireless/ath/ath5k/attach.c            |   24 +-
 drivers/net/wireless/ath/ath5k/base.c              |   71 ++--
 drivers/net/wireless/ath/ath5k/base.h              |   11 +-
 drivers/net/wireless/ath/ath5k/caps.c              |    4 +-
 drivers/net/wireless/ath/ath5k/debug.c             |  207 ++++++------
 drivers/net/wireless/ath/ath5k/desc.h              |    4 +-
 drivers/net/wireless/ath/ath5k/dma.c               |    8 +-
 drivers/net/wireless/ath/ath5k/eeprom.c            |   46 ++--
 drivers/net/wireless/ath/ath5k/eeprom.h            |   12 +-
 drivers/net/wireless/ath/ath5k/initvals.c          |   14 +-
 drivers/net/wireless/ath/ath5k/led.c               |    8 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    4 +-
 drivers/net/wireless/ath/ath5k/pci.c               |   14 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |   16 +-
 drivers/net/wireless/ath/ath5k/phy.c               |  100 +++---
 drivers/net/wireless/ath/ath5k/reg.h               |   89 +++---
 drivers/net/wireless/ath/ath5k/reset.c             |   45 ++-
 drivers/net/wireless/ath/ath5k/rfbuffer.h          |    4 +-
 drivers/net/wireless/ath/ath5k/rfgain.h            |    8 +-
 drivers/net/wireless/ath/ath5k/sysfs.c             |   10 +-
 drivers/net/wireless/ath/ath5k/trace.h             |   15 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    5 +
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |   39 ---
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   34 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   30 ++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    9 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   94 +++++-
 drivers/net/wireless/ath/ath9k/hw.h                |    4 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    3 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   50 ++--
 drivers/net/wireless/ath/ath9k/reg.h               |    5 -
 drivers/net/wireless/ath/carl9170/main.c           |    8 +
 drivers/net/wireless/b43/Kconfig                   |   14 +
 drivers/net/wireless/b43/Makefile                  |    1 +
 drivers/net/wireless/b43/b43.h                     |    1 -
 drivers/net/wireless/b43/bus.c                     |  129 +++++++
 drivers/net/wireless/b43/bus.h                     |    8 +
 drivers/net/wireless/b43/dma.c                     |    9 +-
 drivers/net/wireless/b43/main.c                    |  361 ++++++++++++=
+++-----
 drivers/net/wireless/b43/phy_common.c              |    6 +
 drivers/net/wireless/b43/phy_common.h              |    3 +
 drivers/net/wireless/b43/phy_ht.c                  |   12 +-
 drivers/net/wireless/b43/phy_lcn.c                 |   52 +++
 drivers/net/wireless/b43/phy_lcn.h                 |   14 +
 drivers/net/wireless/b43/phy_n.c                   |   62 +++-
 drivers/net/wireless/b43/tables_phy_lcn.c          |   34 ++
 drivers/net/wireless/b43/tables_phy_lcn.h          |    6 +
 drivers/net/wireless/b43/xmit.c                    |    3 +-
 drivers/net/wireless/iwlegacy/iwl-4965-tx.c        |    3 +-
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   41 ++-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   29 +--
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   30 +--
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   15 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.h       |    7 -
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |  115 +------
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  162 +++++++--
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   28 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   55 +++-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |  109 ++-----
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   62 +++-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   19 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    3 +
 drivers/net/wireless/iwlwifi/iwl-core.c            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   50 +---
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   49 +++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    1 -
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   32 +--
 drivers/net/wireless/iwlwifi/iwl-led.c             |    3 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |    9 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   47 +++-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   20 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c         |   51 +++-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   14 +-
 drivers/net/wireless/iwlwifi/iwl-trans.c           |  154 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   41 +++
 drivers/net/wireless/iwlwifi/iwl-tx.c              |  139 +-------
 drivers/net/wireless/libertas/cmd.c                |   46 ++-
 drivers/net/wireless/libertas/cmd.h                |    2 +
 drivers/net/wireless/libertas/cmdresp.c            |    6 +-
 drivers/net/wireless/libertas/main.c               |   12 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   56 +++-
 drivers/net/wireless/mwifiex/debugfs.c             |    2 +-
 drivers/net/wireless/mwifiex/decl.h                |    4 +-
 drivers/net/wireless/mwifiex/fw.h                  |   11 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |   10 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |   13 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    2 +
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    2 +-
 drivers/net/wireless/wl12xx/acx.c                  |   12 +-
 drivers/net/wireless/wl12xx/acx.h                  |    4 +-
 drivers/net/wireless/wl12xx/boot.c                 |    4 +-
 drivers/net/wireless/wl12xx/cmd.c                  |    6 +-
 drivers/net/wireless/wl12xx/conf.h                 |   10 +-
 drivers/net/wireless/wl12xx/debugfs.c              |   15 +-
 drivers/net/wireless/wl12xx/event.c                |   42 +++
 drivers/net/wireless/wl12xx/event.h                |   12 +-
 drivers/net/wireless/wl12xx/init.c                 |    7 +-
 drivers/net/wireless/wl12xx/main.c                 |  202 ++++++++----
 drivers/net/wireless/wl12xx/ps.c                   |    9 +-
 drivers/net/wireless/wl12xx/scan.c                 |   27 ++
 drivers/net/wireless/wl12xx/scan.h                 |    1 +
 drivers/net/wireless/wl12xx/sdio.c                 |   12 +-
 drivers/net/wireless/wl12xx/tx.c                   |  143 ++++++---
 drivers/net/wireless/wl12xx/tx.h                   |   28 ++-
 drivers/net/wireless/wl12xx/wl12xx.h               |   24 +-
 include/linux/nl80211.h                            |    3 +-
 include/net/bluetooth/bluetooth.h                  |   12 +-
 include/net/bluetooth/hci.h                        |   18 +
 include/net/bluetooth/hci_core.h                   |   29 ++-
 include/net/bluetooth/l2cap.h                      |   25 ++-
 include/net/bluetooth/mgmt.h                       |    2 +
 include/net/bluetooth/smp.h                        |    1 +
 include/net/cfg80211.h                             |    1 +
 include/net/mac80211.h                             |  171 ++++++++--
 net/bluetooth/hci_core.c                           |  101 +++++--
 net/bluetooth/hci_event.c                          |   87 +++++-
 net/bluetooth/l2cap_core.c                         |  216 ++++--------
 net/bluetooth/l2cap_sock.c                         |   69 ++++-
 net/bluetooth/lib.c                                |   23 ++-
 net/bluetooth/mgmt.c                               |  148 +++++----
 net/bluetooth/sco.c                                |    4 +-
 net/bluetooth/smp.c                                |  208 ++++++++++--
 net/mac80211/aes_ccm.c                             |   37 +-
 net/mac80211/aes_ccm.h                             |    2 -
 net/mac80211/aes_cmac.c                            |   10 +-
 net/mac80211/aes_cmac.h                            |    2 +-
 net/mac80211/cfg.c                                 |   27 +-
 net/mac80211/debugfs_key.c                         |   13 +-
 net/mac80211/driver-ops.h                          |    8 +
 net/mac80211/driver-trace.h                        |   46 +++
 net/mac80211/ieee80211_i.h                         |   27 ++-
 net/mac80211/iface.c                               |    7 +-
 net/mac80211/key.c                                 |   75 ++++
 net/mac80211/key.h                                 |   32 +-
 net/mac80211/mlme.c                                |   58 +++-
 net/mac80211/rx.c                                  |   36 ++-
 net/mac80211/sta_info.h                            |    3 +-
 net/mac80211/tkip.c                                |  108 +++---
 net/mac80211/tkip.h                                |    8 +-
 net/mac80211/tx.c                                  |    3 +
 net/mac80211/util.c                                |   67 ++++
 net/mac80211/wpa.c                                 |   94 +++---
 net/wireless/scan.c                                |    2 +-
 162 files changed, 3892 insertions(+), 1916 deletions(-)
 create mode 100644 drivers/net/wireless/b43/phy_lcn.c
 create mode 100644 drivers/net/wireless/b43/phy_lcn.h
 create mode 100644 drivers/net/wireless/b43/tables_phy_lcn.c
 create mode 100644 drivers/net/wireless/b43/tables_phy_lcn.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-07-15.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
