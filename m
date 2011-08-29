From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2011-08-29
Date: Mon, 29 Aug 2011 16:25:06 -0400
Message-ID: <20110829202506.GD1406@tuxdriver.com>
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

Here is another batch of updates intended for 3.2.  Highlights include
an NFC fix, a batch of carl9170 updates, some mesh updates, a big batch
of b43 updates, ath9k updates, and a variety of other bits.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit f3116f62cb56ef5efd172371fab688bb2752=
9f69:

  ixgbe: clear RNBC only for 82598 (2011-08-29 01:35:28 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.=
git for-davem

Alex Hacker (1):
      ath9k_hw: fix EIFS value to microseconds

Aloisio Almeida Jr (1):
      MAINTAINERS: Add NFC subsystem entry

Amitkumar Karwar (1):
      libertas: update readme file

Arik Nemtsov (1):
      mac80211: allow action frames with unknown BSSID in GO mode

Bill Jordan (1):
      ath9k: fix MGMT packets when using TKIP

Christian Lamparter (6):
      carl9170: fix timekeeping for HW_COUNTER firmwares
      carl9170: import updated firmware headers
      carl9170: improve site survey
      carl9170: export HW random number generator
      p54: improve site survey
      carl9170: Use do_div for 64-bit division to fix 32-bit kernels

Dan Carpenter (2):
      libertas: handle mesh networks in lbs_iface_active()
      bcma: signedness bug in bcma_get_next_core()

Eliad Peller (2):
      nl80211/cfg80211: add STA WME parameters
      mac80211: add uapsd_queues and max_sp params fields

=46elix Fietkau (2):
      b43: reload phy and bss settings after core restarts
      ath9k: remove a bogus WARN_ON

Guy Eilam (2):
      mac80211: refactor sta_info_insert_rcu to 3 main stages
      mac80211: fix race condition between assoc_done and first EAP pac=
ket

Helmut Schaa (2):
      wireless: Introduce defines for BAR TID_INFO & MULTI_TID fields
      mac80211: Tear down BA session on BAR tx failure

Javier Cardona (8):
      mac80211: improve mpath debugging
      mac80211: fix mpath timer NULL function
      mac80211: mesh locking fixes
      mac80211: fix mesh path flushing
      mac80211: mesh gate implementation
      {nl,mac}80211: add missing root mode meshconf entries
      {nl,cfg,mac}80211: let userspace set RANN interval
      {nl,cfg,mac}80211: let userspace make meshif mesh gate

John W. Linville (3):
      ath9k: remove replicated null check in ath_pci_aspm_init
      b43: correct warning for uninitialized variable 'macstat'
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into for-davem

Julia Lawall (1):
      drivers/net/wireless/mwifiex/scan.c: test the just-initialized va=
lue

Larry Finger (5):
      rtlwifi: Install updated rate-mapping routine
      rtlwifi: rtl8192ce: Convert to use the new rate-mapping routine i=
n rtlwifi
      rtlwifi: rtl8192cu: Convert to use the new rate-mapping routine i=
n rtlwifi
      rtlwifi: rtl8192se: Convert to use the new rate-mapping routine i=
n rtlwifi
      rtlwifi: rtl8192de: Convert to use the new rate-mapping routine i=
n rtlwifi

Luis R. Rodriguez (4):
      wireless: relicense regulatory header to ISC
      MAINTANERS: update Qualcomm Atheros addresses
      ath9k_hw: add AR9580 support
      ath9k: add AR9580 support

Michael Buesch (1):
      b43/legacy: Remove firmware IDs

Mohammed Shafi Shajakhan (2):
      ath9k: Add support for get_stats callback
      ath9k_htc: Add get_stats call back

Nishant Sarmukadam (1):
      mwl8k: Traffic to clients gets affected when one client leaves a =
cyrpto bss

Rafa=C5=82 Mi=C5=82ecki (27):
      b43: rename TX header formats
      b43: use enum for firmware header format
      b43: support new TX header, noticed to be used by 598.314+ fw
      b43: support new RX header, noticed to be used in 598.314+ fw
      bcma: implement BCM4331 workaround for external PA lines
      b43: include HT-PHY in some common code
      b43: make forcing clock common (HT-PHY also uses that)
      b43: HT-PHY: init: zero EXTG registers
      b43: HT-PHY: init: implement few simple PHY writes
      b43: HT-PHY: init: copy tables and reset CCA
      b43: HT-PHY: init: init BPHY and upload 0x1a table
      b43: HT-PHY: init: add missing PHY mask/set ops
      b43: HT-PHY: init: add some AFE (Analog Frontend) operation
      b43: HT-PHY: init: add missing small-tables writes
      b43: HT-PHY: allow writing longer tables with a single call
      ssb: fix DMA translation for some specific boards
      b43: fix DMA on some bugged hardware
      b43: LCN-PHY: add very basic PHY ops
      b43: LCN-PHY: implement disabling radio
      b43: LCN-PHY: switch analog
      b43: LCN-PHY: add init tables
      b43: LCN-PHY: basic PHY init
      b43: LCN-PHY: init 0x2064 radio
      b43: warn when forcing PIO mode
      b43: drop Kconfig option of forcing PIO mode
      b43: HT-PHY: use separated function for forcing RF sequence
      b43: HT-PHY: read clip state

Rajkumar Manoharan (15):
      ath9k_hw: Fix exceed transmission burst-time of 5GHz
      ath9k: Fix rx overrun interrupt storm
      ath9k: Re-enable RXOEL interrupt after processing rx buffers
      ath9k: Remove unused argument tsf from ath9k_hw_rxprocdesc
      ath9k: qinfo never be NULL in setuptxqueue
      ath9k_hw: Remove unnecessary chainmask configuration
      ath9k: Remove SC_OP_ENABLE_APM
      ath9k: Move ath9k_init_crypto to common
      ath9k: Fix noisefloor history update for extn chains
      ath9k: Fix invalid noisefloor reading due to channel update
      ath9k: Dump modal noisefloor calibration history
      ath9k_hw: Fix descriptor status of TxOpExceeded
      ath9k: Change rate control to use legacy rate as last MRR
      ath9k_hw: Disable Walsh spatial spreading for 2 chains
      ath9k: Send legacy rated frames as unaggregated

Samuel Ortiz (1):
      NFC: Reserve tx head and tail room

Stanislaw Gruszka (3):
      ath9k: remove ->config_pci_powersave() redundant argument
      ath9k: merge common ->config_pci_powersave() checks
      ath9k: do btcoex ASPM disabling at initialization time

Stefan Assmann (1):
      rtlwifi: add module parameter to set global debug level

Thomas Pedersen (7):
      mac80211: fix mesh beacon format
      ieee80211: introduce Self Protected Action codes
      mac80211: update mesh peering frame codes
      mac80211: update mesh peering frame format
      ieee80211: add mesh action codes
      mac80211: update mesh path selection frame format
      mac80211: mesh gate fixes

 MAINTAINERS                                        |   25 +-
 drivers/bcma/driver_chipcommon_pmu.c               |   20 +-
 drivers/bcma/scan.c                                |    2 +-
 drivers/bcma/sprom.c                               |    6 +
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    8 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   15 -
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   89 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   32 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    2 -
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   | 1673 ++++++++++++=
++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    3 +-
 drivers/net/wireless/ath/ath9k/common.c            |   26 +
 drivers/net/wireless/ath/ath9k/common.h            |    1 +
 drivers/net/wireless/ath/ath9k/debug.c             |   55 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   21 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   17 +
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    8 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   11 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    8 +-
 drivers/net/wireless/ath/ath9k/init.c              |   27 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   19 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   54 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   48 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   34 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   12 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   14 +
 drivers/net/wireless/ath/ath9k/xmit.c              |   44 +-
 drivers/net/wireless/ath/carl9170/Kconfig          |   14 +
 drivers/net/wireless/ath/carl9170/carl9170.h       |   24 +
 drivers/net/wireless/ath/carl9170/cmd.c            |   34 +
 drivers/net/wireless/ath/carl9170/cmd.h            |    1 +
 drivers/net/wireless/ath/carl9170/fw.c             |    3 +
 drivers/net/wireless/ath/carl9170/fwcmd.h          |   11 +
 drivers/net/wireless/ath/carl9170/main.c           |  229 +++-
 drivers/net/wireless/ath/carl9170/phy.c            |   16 +-
 drivers/net/wireless/ath/carl9170/version.h        |    4 +-
 drivers/net/wireless/b43/Kconfig                   |   10 -
 drivers/net/wireless/b43/b43.h                     |   23 +-
 drivers/net/wireless/b43/dma.c                     |  126 +-
 drivers/net/wireless/b43/dma.h                     |   13 +-
 drivers/net/wireless/b43/main.c                    |   66 +-
 drivers/net/wireless/b43/phy_common.c              |   32 +
 drivers/net/wireless/b43/phy_common.h              |    2 +
 drivers/net/wireless/b43/phy_ht.c                  |  203 +++
 drivers/net/wireless/b43/phy_ht.h                  |   19 +
 drivers/net/wireless/b43/phy_lcn.c                 |  211 +++-
 drivers/net/wireless/b43/phy_lcn.h                 |   16 +-
 drivers/net/wireless/b43/phy_n.c                   |   40 +-
 drivers/net/wireless/b43/pio.c                     |   12 +-
 drivers/net/wireless/b43/tables_phy_ht.c           |   84 +
 drivers/net/wireless/b43/tables_phy_ht.h           |    4 +
 drivers/net/wireless/b43/tables_phy_lcn.c          |  432 +++++
 drivers/net/wireless/b43/tables_phy_lcn.h          |   16 +
 drivers/net/wireless/b43/xmit.c                    |  120 +-
 drivers/net/wireless/b43/xmit.h                    |   62 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |    4 -
 drivers/net/wireless/b43legacy/main.c              |    4 +-
 drivers/net/wireless/libertas/README               |   25 -
 drivers/net/wireless/libertas/dev.h                |    4 +-
 drivers/net/wireless/mwifiex/scan.c                |    4 +-
 drivers/net/wireless/mwl8k.c                       |    3 -
 drivers/net/wireless/p54/eeprom.c                  |   26 +-
 drivers/net/wireless/p54/fwio.c                    |    2 +
 drivers/net/wireless/p54/main.c                    |  113 ++-
 drivers/net/wireless/p54/p54.h                     |   18 +
 drivers/net/wireless/p54/txrx.c                    |   66 +
 drivers/net/wireless/rtlwifi/base.c                |  161 ++
 drivers/net/wireless/rtlwifi/base.h                |    2 +
 drivers/net/wireless/rtlwifi/debug.c               |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |  139 --
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |  116 +--
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   28 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   23 +-
 drivers/net/wireless/rtlwifi/rtl8192de/def.h       |   35 -
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |  121 +--
 drivers/net/wireless/rtlwifi/rtl8192de/trx.h       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |   39 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |  124 +--
 drivers/net/wireless/rtlwifi/wifi.h                |   35 +
 drivers/nfc/pn533.c                                |   17 +-
 drivers/ssb/main.c                                 |   24 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |   18 +
 include/linux/ieee80211.h                          |   59 +-
 include/linux/nfc.h                                |    2 +
 include/linux/nl80211.h                            |   32 +
 include/net/cfg80211.h                             |   12 +-
 include/net/mac80211.h                             |    2 +
 include/net/nfc.h                                  |    7 +-
 include/net/regulatory.h                           |   16 +-
 net/mac80211/Kconfig                               |   13 +
 net/mac80211/agg-tx.c                              |    2 +-
 net/mac80211/cfg.c                                 |   19 +
 net/mac80211/debugfs_netdev.c                      |    8 +-
 net/mac80211/ieee80211_i.h                         |    1 +
 net/mac80211/mesh.c                                |  259 +++-
 net/mac80211/mesh.h                                |   36 +-
 net/mac80211/mesh_hwmp.c                           |  130 +-
 net/mac80211/mesh_pathtbl.c                        |  305 ++++-
 net/mac80211/mesh_plink.c                          |  241 ++--
 net/mac80211/mlme.c                                |   59 +-
 net/mac80211/rx.c                                  |   48 +-
 net/mac80211/sta_info.c                            |  330 +++--
 net/mac80211/sta_info.h                            |   30 +-
 net/mac80211/status.c                              |   18 +
 net/mac80211/tx.c                                  |   14 +-
 net/nfc/core.c                                     |    6 +-
 net/nfc/rawsock.c                                  |   13 +-
 net/wireless/mesh.c                                |    3 +
 net/wireless/nl80211.c                             |   42 +
 net/wireless/util.c                                |    6 +-
 121 files changed, 5613 insertions(+), 1490 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9580_1p0_initvals.=
h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
011-08-29.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
