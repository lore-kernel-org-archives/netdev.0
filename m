From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-12-08
Date: Wed, 8 Dec 2010 16:04:32 -0500
Message-ID: <20101208210432.GH2423@tuxdriver.com>
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

Here is the latest batch of updates intended for 2.6.38.  It also
includes my last wireless-2.6 pull request that you just added
to net-2.6.

This includes the usual batch of drivers updates, with ath9k and
iwlwifi as the usual standouts.  This also includes some mac80211
documentation updates from Johannes, and a flurry of ath5k updates
from Nick.  This also includes a collection of bluetooth updates by
way of Gustavo, a couple of libertas updates, some more work on b43
N-phy support, and a variety of other patches.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit cfa969e385a23e4c85f50e0ed5de25a2e18b=
f9d4:

  Revert "ehea: Use the standard logging functions" (2010-12-06 20:45:2=
8 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Anderson Lizardo (1):
      Bluetooth: Fix error handling for l2cap_init()

Andrei Emeltchenko (8):
      Bluetooth: Check sk is not owned before freeing l2cap_conn
      Bluetooth: timer check sk is not owned before freeing
      Bluetooth: do not use assignment in if condition
      Bluetooth: clean up sco code
      Bluetooth: clean up rfcomm code
      Bluetooth: clean up l2cap code
      Bluetooth: clean up hci code
      Bluetooth: clean up legal text

Andy Shevchenko (1):
      wireless: ray_cs: use '%pm' format option to print MAC

Bala Shanmugam (1):
      Bluetooth: Add new PID for Atheros 3011

Ben Greear (1):
      ath9k: Move debugfs under ieee80211/[phyname]/ath9k/

Bruno Randolf (1):
      cfg80211: Add documentation for antenna ops

Christian Lamparter (2):
      carl9170: fix carl9170_tx_prepare typo
      mac80211: ignore non-bcast mcast deauth/disassoc franes

Daniel Drake (1):
      libertas: fix memory corruption in lbs_remove_card()

David Kilroy (1):
      orinoco: abort scan on interface down

=46elix Fietkau (12):
      ath9k: fix software retry counter tracking
      ath9k_hw: fix endian issues with CTLs on AR9003
      ath9k_hw: fix more bitfield related endian issues
      ath5k: Use Generic DMA for later support of AHB bus.
      ath5k: Introduce ath5k_init_softc function as in ath9k
      ath5k: Move PCI bus functions to separate file.
      ath5k: Use generic eeprom read from common ath_bus_opts struct.
      ath5k: Check if pci pdev struct is initialized in common function=
s.
      ath5k: Add a function to read chipset's MAC revision
      ath5k: Add initial registers values for radio RF2317 chip.
      ath5k: Add AHB bus support.
      ath5k: Fix reset and interrupts for AHB type of devices.

Gabor Juhos (1):
      ath9k: use per-device struct for pm_qos_* operations

Gustavo F. Padovan (4):
      Bluetooth: Fix not returning proper error in SCO
      Merge git://git.kernel.org/.../padovan/bluetooth-2.6 into test
      Bluetooth: Get rid of __l2cap_get_sock_by_psm()
      Bluetooth: Get rid of __rfcomm_get_sock_by_channel()

Hauke Mehrtens (1):
      ssb: Add sysfs attributes to ssb devices

Helmut Schaa (1):
      mac80211: Minor optimization in ieee80211_rx_h_data

Joe Perches (2):
      ath9k: hif_usb: Reduce indent 1 column
      wireless: Remove unnecessary casts of usb_get_intfdata

Johan Hedberg (3):
      Bluetooth: Simplify remote features callback function logic
      Bluetooth: Create a unified authentication request function
      Bluetooth: Automate remote name requests

Johannes Berg (17):
      iwlagn: remove powersave warning
      iwlagn: fix station powersave accounting for aggregation
      iwlagn: advertise reliable TX status
      iwlwifi: use mac80211 AC defines
      ath9k/carl9170: advertise P2P
      nl80211/cfg80211: extend mgmt-tx API for off-channel
      mac80211: implement off-channel mgmt TX
      mac80211: fix RX aggregation locking
      cfg80211: include CQM packet loss docs
      mac80211: document workqueue
      mac80211: publish docs for _ni functions
      mac80211: publish some misc docs
      mac80211: publish some rate control docs
      mac80211: document aggregation
      mac80211: publish interface iteration docs
      mac80211: document station handling
      mac80211: publish SMPS docs

Johannes Stezenbach (1):
      mac80211/rt2x00: add ieee80211_tx_status_ni()

John W. Linville (5):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-2.6
      Revert "ath9k: Fix STA disconnect issue due to received MIC faile=
d bcast frames"
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (1):
      mac80211: Fix frame injection using non-AP vif

Mohammed Shafi Shajakhan (1):
      ath9k: Add support for Adaptive Power Management

Nick Kossifidis (30):
      ath5k: Reset cleanup and generic cleanup
      ath5k: Add new function to stop rx/tx DMA
      ath5k: Stop PCU on reset
      ath5k: Use new dma_stop function on base.c
      ath5k: Debug DMA timeouts
      ath5k: Use DCU early termination correctly
      ath5k: Check RXE when setting RXDP
      ath5k: Use new function to stop beacon queue
      ath5k: Add new field on ath5k_hw to track bandwidth modes
      ath5k: Put core clock initialization on a new function
      ath5k: Small cleanup on tweak_initvals
      ath5k: Increase PHY settling parameters for turo mode
      ath5k: Move tx retries setting outside reset_tx_queue
      ath5k: Extend get_default_sifs/slot_time
      ath5k: Extend rate_duration
      ath5k: Set all IFS intervals, not just slot time
      ath5k: Use turbo flag on DCU
      ath5k: Always set IFS intervals on reset
      ath5k: Tweak power detector delays on RF5111/RF5112
      ath5k: Update spur mitigation filter for turbo/half/quarter
      ath5k: Update PLL programming for turbo/half/quarter
      ath5k: Skip powertable setting when we are on the same channel
      ath5k: Support synth-only channel change for AR2413/AR5413
      ath5k: No need to save/restore staid flags on reset
      ath5k: Tweak phy activate to rx start delay based on bwmode
      ath5k: Skip tx power setting on AR5210 for now
      ath5k: Use correct clock when setting ofdm timings
      ath5k: Cleanup turbo channel flags
      ath5k: Clean up turbo mode initvals/rfregs
      ath5k: Set turbo bit on rf bank 2

Rafa=C5=82 Mi=C5=82ecki (8):
      ssb: extract indexes for power tables
      b43: N-PHY: swap values for radio registers 0x3b and 0x3c
      b43: N-PHY: implement very basic TX power control management
      b43: N-PHY: initialize perical variable, add missing call to CCA =
reset
      b43: N-PHY: fix RSSI calibration
      b43: N-PHY: fix RSSI selection
      b43: N-PHY: use defines for RSSI types
      b43: N-PHY: fix code path on PHY init

Rajkumar Manoharan (2):
      ath9k: Disable SWBA interrupt on remove_interface
      Revert "ath9k_htc: Handle monitor mode properly for HTC devices"

Senthil Balasubramanian (2):
      mac80211: Fix STA disconnect due to MIC failure
      ath9k: Fix STA disconnect issue due to received MIC failed bcast =
frames

Stanislaw Gruszka (1):
      iwlagn: fix microcode error on 4965

Stefan Seyfried (1):
      Bluetooth: Fix log spamming in btusb due to autosuspend

Sujith Manoharan (1):
      ath9k_htc: Remove unused structures

Sven Neumann (1):
      libertas: fix invalid access

Vasanthakumar Thiagarajan (3):
      ath9k: Reintroduce modparam to enable btcoex
      ath9k: Remove code which enables btcoex based on subsys id
      ath9k: Fix bug in reading input gpio state for ar9003

Vasiliy Kulikov (3):
      Bluetooth: bnep: fix information leak to userland
      Bluetooth: cmtp: fix information leak to userland
      Bluetooth: hidp: fix information leak to userland

Wey-Yi Guy (8):
      iwlwifi: remove unused define
      iwlwifi: use antenna information in EEPROM
      iwlagn: Offical name for 6050g2 device
      iwlagn: Offical name for 6000g2a device
      iwlagn: Offical name for 6000g2b device
      iwlagn: Offical name for 100/130 device
      iwlagn: use different kill mask when SCO active
      iwlagn: minor change in bt coex normal LUT

 Documentation/DocBook/80211.tmpl               |   70 ++-
 drivers/bluetooth/ath3k.c                      |    4 +
 drivers/bluetooth/btusb.c                      |   12 +-
 drivers/net/wireless/ath/ar9170/usb.c          |    6 +-
 drivers/net/wireless/ath/ath.h                 |    2 +
 drivers/net/wireless/ath/ath5k/Kconfig         |   17 +-
 drivers/net/wireless/ath/ath5k/Makefile        |    2 +
 drivers/net/wireless/ath/ath5k/ahb.c           |  219 +++++
 drivers/net/wireless/ath/ath5k/ani.c           |    6 +-
 drivers/net/wireless/ath/ath5k/ath5k.h         |  260 ++++--
 drivers/net/wireless/ath/ath5k/attach.c        |   28 +-
 drivers/net/wireless/ath/ath5k/base.c          |  753 ++++++----------
 drivers/net/wireless/ath/ath5k/base.h          |    5 +-
 drivers/net/wireless/ath/ath5k/caps.c          |    6 -
 drivers/net/wireless/ath/ath5k/debug.c         |    1 +
 drivers/net/wireless/ath/ath5k/debug.h         |    2 +
 drivers/net/wireless/ath/ath5k/desc.c          |   24 +-
 drivers/net/wireless/ath/ath5k/dma.c           |  180 ++++-
 drivers/net/wireless/ath/ath5k/eeprom.c        |  127 ++--
 drivers/net/wireless/ath/ath5k/eeprom.h        |    2 +-
 drivers/net/wireless/ath/ath5k/initvals.c      |  409 ++++----
 drivers/net/wireless/ath/ath5k/led.c           |   11 +-
 drivers/net/wireless/ath/ath5k/pci.c           |  326 +++++++
 drivers/net/wireless/ath/ath5k/pcu.c           |  571 ++++++++----
 drivers/net/wireless/ath/ath5k/phy.c           |  641 ++++++++++---
 drivers/net/wireless/ath/ath5k/qcu.c           |  692 ++++++++------
 drivers/net/wireless/ath/ath5k/reg.h           |   31 +-
 drivers/net/wireless/ath/ath5k/reset.c         | 1221 +++++++++++-----=
--------
 drivers/net/wireless/ath/ath5k/rfbuffer.h      | 1169 ++++++++--------=
-------
 drivers/net/wireless/ath/ath5k/sysfs.c         |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |  317 ++++---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h |    9 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |    6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h         |    7 +-
 drivers/net/wireless/ath/ath9k/beacon.c        |    3 +-
 drivers/net/wireless/ath/ath9k/btcoex.c        |   23 -
 drivers/net/wireless/ath/ath9k/btcoex.h        |    1 -
 drivers/net/wireless/ath/ath9k/debug.c         |   35 +-
 drivers/net/wireless/ath/ath9k/debug.h         |   16 -
 drivers/net/wireless/ath/ath9k/eeprom.c        |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom.h        |   28 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |   11 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c       |  119 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |   64 ++-
 drivers/net/wireless/ath/ath9k/htc_hst.h       |   19 -
 drivers/net/wireless/ath/ath9k/hw.c            |   12 +-
 drivers/net/wireless/ath/ath9k/hw.h            |    1 +
 drivers/net/wireless/ath/ath9k/init.c          |   44 +-
 drivers/net/wireless/ath/ath9k/main.c          |   21 +-
 drivers/net/wireless/ath/ath9k/reg.h           |    6 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |   27 +-
 drivers/net/wireless/ath/carl9170/fw.c         |    3 +-
 drivers/net/wireless/ath/carl9170/main.c       |    3 +-
 drivers/net/wireless/ath/carl9170/tx.c         |    2 +-
 drivers/net/wireless/ath/carl9170/usb.c        |    3 +-
 drivers/net/wireless/b43/phy_n.c               |  305 +++++--
 drivers/net/wireless/b43/phy_n.h               |    2 +-
 drivers/net/wireless/b43/radio_2055.c          |  246 +++---
 drivers/net/wireless/iwlwifi/iwl-1000.c        |   12 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c        |   20 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   66 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c  |   20 +
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |   34 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c      |   45 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c   |   24 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |    3 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h    |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h      |    1 -
 drivers/net/wireless/libertas/if_sdio.c        |    1 -
 drivers/net/wireless/libertas/if_spi.c         |    1 -
 drivers/net/wireless/libertas/main.c           |    2 -
 drivers/net/wireless/orinoco/main.c            |   12 +-
 drivers/net/wireless/orinoco/scan.c            |    8 +
 drivers/net/wireless/orinoco/scan.h            |    1 +
 drivers/net/wireless/p54/p54usb.c              |    2 +-
 drivers/net/wireless/ray_cs.c                  |   14 +-
 drivers/net/wireless/rt2x00/rt2800pci.c        |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h           |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c        |    9 +-
 drivers/net/wireless/zd1201.c                  |    2 +-
 drivers/ssb/main.c                             |   30 +
 drivers/ssb/pci.c                              |   44 +
 include/linux/nl80211.h                        |   25 +-
 include/linux/ssb/ssb.h                        |    4 +
 include/linux/ssb/ssb_regs.h                   |   40 +
 include/net/bluetooth/hci.h                    |   16 +-
 include/net/bluetooth/hci_core.h               |   14 +-
 include/net/bluetooth/l2cap.h                  |   22 +-
 include/net/bluetooth/rfcomm.h                 |   18 +-
 include/net/bluetooth/sco.h                    |   20 +-
 include/net/cfg80211.h                         |   18 +-
 include/net/mac80211.h                         |   28 +-
 net/bluetooth/bnep/core.c                      |    1 +
 net/bluetooth/cmtp/core.c                      |    1 +
 net/bluetooth/hci_conn.c                       |   23 +-
 net/bluetooth/hci_core.c                       |   66 +-
 net/bluetooth/hci_event.c                      |  177 +++-
 net/bluetooth/hci_sock.c                       |   17 +-
 net/bluetooth/hidp/core.c                      |    2 +-
 net/bluetooth/l2cap.c                          |   94 ++-
 net/bluetooth/rfcomm/core.c                    |    8 +-
 net/bluetooth/rfcomm/sock.c                    |   24 +-
 net/bluetooth/rfcomm/tty.c                     |   28 +-
 net/bluetooth/sco.c                            |   28 +-
 net/mac80211/agg-rx.c                          |    8 +-
 net/mac80211/cfg.c                             |   94 ++-
 net/mac80211/debugfs_sta.c                     |   29 +-
 net/mac80211/ieee80211_i.h                     |    5 +
 net/mac80211/rx.c                              |   28 +-
 net/mac80211/sta_info.h                        |   29 +-
 net/mac80211/status.c                          |   15 +-
 net/mac80211/tx.c                              |    7 +-
 net/mac80211/work.c                            |   22 +
 net/wireless/core.h                            |    4 +-
 net/wireless/mlme.c                            |    9 +-
 net/wireless/nl80211.c                         |   57 +-
 116 files changed, 5566 insertions(+), 3909 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/ahb.c
 create mode 100644 drivers/net/wireless/ath/ath5k/pci.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-12-08.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
