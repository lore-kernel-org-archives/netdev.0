From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-06-08
Date: Wed, 8 Jun 2011 15:12:47 -0400
Message-ID: <20110608191246.GD27028@tuxdriver.com>
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

Here is the first big wireless pull request for the 3.1 cycle.
As usual, this covers a lot of ground -- mostly driver updates.

Some highlights include some math algorithm additions to lib/ from
the Broadcom team, sizeable update series for rt2x00 and rtlwifi,
the usual iwlagn and ath9k updates from the Intel and Atheros teams
(and a few other folks), some more mwifiex updates from the Marvell
folks, and a bunch of bcma, ssb and b43 updates from Rafa=C5=82 Mi=C5=82=
ecki.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ffbc03bc75b39c7bd412e7cc6d2185c11b0f=
fedd:

  net: add needed interrupt.h (2011-06-08 00:15:34 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Amitkumar Karwar (1):
      mwifiex: remove support for old chipsets W0/W1

Arend van Spriel (2):
      lib: crc8: add new library module providing crc8 algorithm
      lib: cordic: add library module providing cordic angle calculatio=
n

Daniel Drake (1):
      libertas_sdio: handle spurious interrupts

Daniel Halperin (1):
      iwlwifi: disambiguate invalid DMA index warnings

Emmanuel Grumbach (2):
      iwlagn: solve sparse warning
      iwlagn: free the ICT ISR when the request_irq failed

=46abrice Deyber (1):
      ath9k: Further fix for mesh beaconing

=46elix Fietkau (3):
      ath9k: unify edma and non-edma tx code, improve tx fifo handling
      ath9k_hw: remove ath9k_hw_get_desc_link
      ath9k: show excessive-retry MPDUs in debugfs

Gertjan van Wingerde (6):
      rt2x00: Enable PA_PE bits in TX_PIN_CFG according to active band.
      rt2x00: Don't disable G0 PA_PE bit in case of BT coexistence.
      rt2x00: Add support for RT3572/RT3592/RT3592+Bluetooth combo card
      rt2x00: Interface sequence lock doesn't have to disable interrupt=
s.
      rt2x00: Move rt2800_txdone and rt2800_txdone_entry_check to rt280=
0usb.
      rt2x00: Enabled rt35xx device support by default.

Greg Dietsche (6):
      iwlegacy: remove unreachable code
      iwlegacy: remove unecessary if statement
      iwlegacy: return -EINVAL instead of -1
      iwlegacy: propagate error return value
      iwlegacy: add missing null check
      iwlwifi: remove unecessary if statement

Javier Lopez (1):
      mac80211_hwsim driver support userspace frame tx/rx

Johannes Berg (3):
      iwlagn: fix dual-mode RXON
      iwlagn: advertise interface combinations
      iwlagn: fix interface combinations

John W. Linville (3):
      Revert "mac80211: Skip tailroom reservation for full HW-crypto de=
vices"
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Larry Finger (9):
      b43: Fix warnings from gcc 4.6.0
      rtlwifi: Fix warnings from gcc 4.6.0
      rtl8192c-common: Fix warnings from gcc 4.6.0
      rtl8192ce: Fix warnings from gcc 4.6.0
      rtl8192cu: Fix warnings from gcc 4.6.0
      rtl8192se: Fix warnings from gcc 4.6.0
      b43legacy: Fix warnings from gcc 4.6.0
      rtlwifi: rtl8192se: Use write barrier when assigning ownership
      rtlwifi: rtl8192se: Synchronize IRQ after disabling it

Luis R. Rodriguez (1):
      cfg80211: skip disabled channels on channel survey

Mike McCormack (8):
      rtlwifi: Synchronize IRQ after disabling it
      rtlwifi: Remove set_rfpowerstate_inprogress
      rtlwifi: Store loop index in local variable
      rtlwifi: Run IPS leave work in a tasklet
      rtlwifi: Don't block interrupts in spinlocks
      rtlwifi: Assign rx buffer ownership to hardware last
      rtlwifi: Use write barrier when assigning ownership
      rtlwifi: Fix logic in rx_interrupt

Mohammed Shafi Shajakhan (7):
      ath9k: remove redundant if check
      ath9k: make ath9k_setpower function as static
      ath9k: mark few functions as static
      ath9k: wake up chip before initializing PAPRD table
      ath9k: Add a debug entry to start/stop ANI
      ath9k: better position PAPRD debug message
      ath9k: make use of a helper to get paprd scale factor

Nick Kossifidis (1):
      ath5k: Disable fast channel switching by default

Rafa=C5=82 Mi=C5=82ecki (21):
      b43: rename ssb_device variable in ssb specific functions
      b43: add bus device abstraction layer
      b43: bus: abstract R/W operations
      b43: bus: abstract 80211 core info
      b43: bus: abstract SPROM
      b43: bus: abstract device structs and irq
      b43: bus: abstract chip info
      b43: bus: abstract board info
      b43: bus: abstract bus and core operations
      bcma: add IRQ number and pointer to DMA dev
      bcma: pci: implement interrupts control
      b43: LP-PHY: use new pointers path to access ssb_device
      b43: SDIO: use new pointers path to access ssb_device
      b43: use new pointers path to access ssb_device in SSB specific p=
laces
      b43: bus: add helpers for checking host type
      bcma: host pci: implement block R/W operations
      ssb: fix PCI(e) driver regression causing oops on PCI cards
      b43: do not use SSB specific flags when calling core reset functi=
on
      bcma: read SPROM and extract MAC from it
      b43: add an option to register BROKEN bcma driver
      b43: add BCMA 80211 core specific defines

Rajkumar Manoharan (2):
      ath9k: Remove ATH9K_BEACON_PERIOD mask
      ath9k: Handle IBSS status changes in BSS_CHANGED_IBSS

Shahar Levi (2):
      mac80211: Stop BA session event from device
      wl12xx: Stop BA session event from device

Stanislaw Gruszka (5):
      iwlagn: fix channel switch locking
      iwlagn: use cts-to-self protection on 5000 adapters series
      rt2x00: fix rmmod crash
      iwl4965: set tx power after rxon_assoc
      iwlagn: refactor iwlagn_mac_channel_switch

Thadeu Lima de Souza Cascardo (1):
      mac80211: call dev_alloc_name before copying name to sdata

Wey-Yi Guy (10):
      nl80211: add testmode dump support
      iwlagn: send tx power command if defer cause by RXON not match
      iwlagn: remove un-necessary tx power ops
      iwlagn: change the logging level for aggregation enable check
      iwlagn: change log to better represent the state of aggregation p=
rocess
      iwlagn: save the latest smps mode
      iwlagn: set smps mode after assoc for 1000 device
      iwlagn: move all post scan functions in one place
      iwlagn: direct call to post_scan function
      iwlagn: call commit_rxon function directly

Yogesh Ashok Powar (4):
      mwifiex: remove list traversal in mwifiex_num_pkts_in_txq
      mwifiex: Remove redundant skb_queue_empty checks
      mwifiex: adding check for enough space before padding
      mwifiex: disable transmission buffer aggregation for AMSDU packet=
s

Zefir Kurtisi (1):
      minstrel_ht: fixed rate mode through debugfs

 drivers/bcma/Kconfig                               |    5 +
 drivers/bcma/Makefile                              |    2 +-
 drivers/bcma/bcma_private.h                        |    3 +
 drivers/bcma/driver_pci.c                          |   23 +
 drivers/bcma/host_pci.c                            |   52 +++
 drivers/bcma/main.c                                |    9 +
 drivers/bcma/sprom.c                               |  162 +++++++
 drivers/net/wireless/ath/ath.h                     |    1 +
 drivers/net/wireless/ath/ath5k/base.c              |   11 +-
 drivers/net/wireless/ath/ath5k/reset.c             |    5 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    6 -
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    8 -
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   24 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    8 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   21 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   59 +++-
 drivers/net/wireless/ath/ath9k/debug.h             |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |    8 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    5 -
 drivers/net/wireless/ath/ath9k/hw.c                |    6 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 -
 drivers/net/wireless/ath/ath9k/init.c              |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |  150 ++++---
 drivers/net/wireless/ath/ath9k/xmit.c              |  338 ++++++------=
---
 drivers/net/wireless/b43/Kconfig                   |    5 +
 drivers/net/wireless/b43/Makefile                  |    1 +
 drivers/net/wireless/b43/b43.h                     |   51 ++-
 drivers/net/wireless/b43/bus.c                     |  122 +++++
 drivers/net/wireless/b43/bus.h                     |   62 +++
 drivers/net/wireless/b43/dma.c                     |   38 +-
 drivers/net/wireless/b43/leds.c                    |   15 +-
 drivers/net/wireless/b43/lo.c                      |    6 +-
 drivers/net/wireless/b43/main.c                    |  234 ++++++----
 drivers/net/wireless/b43/main.h                    |    2 +-
 drivers/net/wireless/b43/phy_a.c                   |   21 +-
 drivers/net/wireless/b43/phy_common.c              |    8 +-
 drivers/net/wireless/b43/phy_g.c                   |   92 ++--
 drivers/net/wireless/b43/phy_lp.c                  |  135 +++---
 drivers/net/wireless/b43/phy_n.c                   |   37 +-
 drivers/net/wireless/b43/pio.c                     |   10 +-
 drivers/net/wireless/b43/rfkill.c                  |    9 +-
 drivers/net/wireless/b43/sdio.c                    |    4 +-
 drivers/net/wireless/b43/sysfs.c                   |    4 +-
 drivers/net/wireless/b43/tables_lpphy.c            |   15 +-
 drivers/net/wireless/b43/wa.c                      |   24 +-
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/b43legacy/dma.c               |   10 +-
 drivers/net/wireless/b43legacy/main.c              |    8 +-
 drivers/net/wireless/b43legacy/xmit.c              |    2 -
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c        |    3 +
 drivers/net/wireless/iwlegacy/iwl-4965.c           |    9 +-
 drivers/net/wireless/iwlegacy/iwl-eeprom.c         |    1 -
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   75 ----
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    5 -
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    4 -
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |   15 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   91 +++-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  206 ++++++---
 drivers/net/wireless/iwlwifi/iwl-core.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   15 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   13 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   24 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |    6 +-
 drivers/net/wireless/libertas/if_sdio.c            |   21 +-
 drivers/net/wireless/mac80211_hwsim.c              |  462 ++++++++++++=
+++++++-
 drivers/net/wireless/mac80211_hwsim.h              |  133 ++++++
 drivers/net/wireless/mwifiex/11n_aggr.c            |   54 ++-
 drivers/net/wireless/mwifiex/main.c                |   18 +-
 drivers/net/wireless/mwifiex/main.h                |   12 +-
 drivers/net/wireless/mwifiex/sdio.c                |    8 +-
 drivers/net/wireless/mwifiex/sdio.h                |    2 +
 drivers/net/wireless/mwifiex/wmm.c                 |   30 +-
 drivers/net/wireless/rt2x00/Kconfig                |    9 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   16 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |  376 ++++++++++++=
----
 drivers/net/wireless/rt2x00/rt2800lib.h            |    1 -
 drivers/net/wireless/rt2x00/rt2800pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   83 ++++-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    3 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    4 +
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    5 +-
 drivers/net/wireless/rtlwifi/base.c                |    4 -
 drivers/net/wireless/rtlwifi/efuse.c               |    6 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   41 +-
 drivers/net/wireless/rtlwifi/ps.c                  |   48 +--
 drivers/net/wireless/rtlwifi/regd.c                |   18 -
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    2 -
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    9 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |   14 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    2 -
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |    2 -
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |    5 -
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |    2 -
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   18 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    6 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    2 +-
 drivers/net/wireless/wl12xx/boot.c                 |    3 +-
 drivers/net/wireless/wl12xx/event.c                |   23 +
 drivers/net/wireless/wl12xx/event.h                |   17 +-
 drivers/net/wireless/wl12xx/init.c                 |    1 +
 drivers/net/wireless/wl12xx/main.c                 |    5 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |    1 +
 drivers/ssb/driver_pcicore.c                       |   10 +-
 include/linux/bcma/bcma.h                          |   25 +
 include/linux/bcma/bcma_driver_chipcommon.h        |    1 +
 include/linux/cordic.h                             |   48 ++
 include/linux/crc8.h                               |  101 +++++
 include/net/cfg80211.h                             |   11 +
 include/net/mac80211.h                             |   21 +
 lib/Kconfig                                        |   14 +
 lib/Makefile                                       |    3 +
 lib/cordic.c                                       |  101 +++++
 lib/crc8.c                                         |   86 ++++
 net/mac80211/agg-rx.c                              |   15 +
 net/mac80211/cfg.c                                 |   14 +
 net/mac80211/ht.c                                  |    6 +
 net/mac80211/ieee80211_i.h                         |    3 -
 net/mac80211/iface.c                               |    4 +
 net/mac80211/key.c                                 |   21 +-
 net/mac80211/rc80211_minstrel.c                    |    9 +
 net/mac80211/rc80211_minstrel.h                    |   12 +
 net/mac80211/rc80211_minstrel_ht.c                 |    7 +
 net/mac80211/sta_info.h                            |    3 +
 net/mac80211/tx.c                                  |    7 +-
 net/wireless/nl80211.c                             |  107 +++++-
 133 files changed, 3173 insertions(+), 1293 deletions(-)
 create mode 100644 drivers/bcma/sprom.c
 create mode 100644 drivers/net/wireless/b43/bus.c
 create mode 100644 drivers/net/wireless/b43/bus.h
 create mode 100644 drivers/net/wireless/mac80211_hwsim.h
 create mode 100644 include/linux/cordic.h
 create mode 100644 include/linux/crc8.h
 create mode 100644 lib/cordic.c
 create mode 100644 lib/crc8.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-06-08.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
