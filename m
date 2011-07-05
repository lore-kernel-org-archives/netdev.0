From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-07-05
Date: Tue, 5 Jul 2011 16:41:07 -0400
Message-ID: <20110705204106.GG7540@tuxdriver.com>
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

Here is another big batch of changed intended for 3.1.  This looks
bigger than it is, as it also contains a wireless-2.6 pull to resolve
some build conflicts.

The most noteworth item is yet another rtlwifi-based driver (rtl8192de)=
=2E
There is also some HT-phy work for b43, plus the usual contributions
from the ath9k and iwlwifi crews and a variety of other bits here and
there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 7d09926d1decb658d4e24f70216b6b0b7416=
8026:

  bnx2x: Fix warning message during 57712/8727 initialization (2011-07-=
05 04:21:40 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Arik Nemtsov (5):
      mac80211: fix rx->key NULL dereference during mic failure
      mac80211: reestablish mis-configured existing Rx BA sessions
      mac80211: dynamic PS - don't enter PS when TX frames are pending
      mac80211: propagate information about STA WME support down
      wl12xx: AP-mode - use mac80211 indication about STA WME support

Chaoming Li (12):
      rtlwifi: rtl8192de: Merge def.h
      rtlwifi: rtl8192de: Merge dynamic management routines
      rtlwifi: rtl8192de: Merge firmware routines
      rtlwifi: rtl8192de: Merge hardware routines
      rtlwifi: rtl8192de: Merge led routines
      rtlwifi: rtl8192de: Merge phy routines
      rtlwifi: rtl8192de: Merge register definitions
      rtlwifi: rtl8192de: Merge rf routines
      rtlwifi: rtl8192de: Merge main (sw) routines
      rtlwifi: rtl8192de: Merge table routines
      rtlwifi: rtl8192de: Merge TX and RX routines
      rtlwifi: rtl8192de: Modify Kconfig and Makefile routines for new =
driver

Dan Carpenter (2):
      mwifiex: restore handling of NULL parameters
      rtlwifi: potential forever loop in rtl92de_hw_init()

Emmanuel Grumbach (1):
      iwlagn: Fix a bug introduced by the HUGE command removal

Evgeni Golov (1):
      iwlagn: fix *_UCODE_API_MAX output in the firmware field

Geert Uytterhoeven (1):
      bcma: main.c needs to include <linux/slab.h>

Hauke Mehrtens (1):
      ssb: fix ssb clock rate according to broadcom source

Joe Perches (1):
      rt2x00: Fix unspeficied typo

Johannes Berg (10):
      iwlagn: fix change_interface for P2P types
      iwlagn: use PM ops macro
      iwlagn: fix cmd queue unmap
      iwlagn: extend host command timeout
      iwlagn: fill beacon TX rate properly
      iwlagn: don't use CCK rates for P2P interfaces
      iwlagn: fix cmd queue unmap
      iwlagn: map command buffers BIDI
      wireless: unify QoS control field definitions
      mac80211: restrict advertised HW scan rates

John W. Linville (6):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth=
-2.6
      Merge branch 'wireless-2.6' of git://git.kernel.org/.../iwlwifi/i=
wlwifi-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      iwlagn: use PCI_DMA_* for pci_* operations
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jon Mason (3):
      iwlegacy: remove unnecessary read of PCI_CAP_ID_EXP
      rtlwifi: remove unnecessary read of PCI_CAP_ID_EXP
      rtlwifi: use PCI_VENDOR_ID_*

Larry Finger (4):
      rtlwifi: rtl8192se: Handle duplicate PCI ID 0x10ec:0x8192 conflic=
t with r8192e_pci
      rtl8192cu: Fix missing firmware load
      rtlwifi: Fix build problems introduced by merging rtl8192de
      rtlwifi: rtl8192de: Fix build errors when using allyes configurat=
ion

Mohammed Shafi Shajakhan (4):
      ath9k_hw: Add carrier leak correction in desired gain calculation
      ath9k_hw: make use of the gain_table_entry macro
      ath9k: move few descriptor macros to ath9k.h
      ath9k_htc: Add device ID for Sony UWA-BR100

Paul Stewart (1):
      mac80211: Drop DS Channel PARAM in directed probe

Rafa=C5=82 Mi=C5=82ecki (10):
      b43: HT-PHY: prepare place for HT-PHY tables
      b43: HT-PHY: upload PHY values when switching channel
      b43: HT-PHY: perform some tables ops on channel switching
      b43: HT-PHY: add channel switching tables for 2 GHz band
      b43: HT-PHY: implement lacking 0x908 PHY reg op
      b43: HT-PHY: replace radio routing magic numbers
      b43: HT-PHY: init radio when enabling it
      b43: HT-PHY: add init tables
      b43: HT-PHY: basic PHY init
      b43: HT-PHY: correct 0x2059 radio init

Rajkumar Manoharan (2):
      ath9k_hw: Fix false tx hung detection in AR9003 chips
      ath9k: Fix locking issue during tx completion

Randy Dunlap (1):
      bluetooth: uses crypto interfaces, select CRYPTO

Sergei Shtylyov (2):
      ssb: use pci_dev->revision
      iwlwifi: use pci_dev->revision, again

Stanislaw Gruszka (1):
      iwlagn: fix rmmod crash

 drivers/bcma/main.c                             |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.c     |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c   |   38 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h     |    3 +
 drivers/net/wireless/ath/ath9k/ath9k.h          |    5 +
 drivers/net/wireless/ath/ath9k/beacon.c         |    8 +
 drivers/net/wireless/ath/ath9k/hif_usb.c        |    2 +
 drivers/net/wireless/ath/ath9k/init.c           |    7 -
 drivers/net/wireless/ath/ath9k/main.c           |   13 +-
 drivers/net/wireless/ath/ath9k/xmit.c           |    7 +-
 drivers/net/wireless/ath/carl9170/rx.c          |    2 +-
 drivers/net/wireless/b43/Makefile               |    1 +
 drivers/net/wireless/b43/phy_ht.c               |  132 +-
 drivers/net/wireless/b43/phy_ht.h               |   14 +-
 drivers/net/wireless/b43/radio_2059.c           |  135 +
 drivers/net/wireless/b43/radio_2059.h           |    5 +
 drivers/net/wireless/b43/tables_phy_ht.c        |  750 +++++
 drivers/net/wireless/b43/tables_phy_ht.h        |   22 +
 drivers/net/wireless/iwlegacy/iwl-core.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c         |    5 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c         |    7 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c         |    5 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c      |   17 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c          |   26 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h          |    2 +
 drivers/net/wireless/iwlwifi/iwl-core.c         |   16 +-
 drivers/net/wireless/iwlwifi/iwl-core.h         |    7 -
 drivers/net/wireless/iwlwifi/iwl-hcmd.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c          |   20 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c           |   25 +-
 drivers/net/wireless/libertas_tf/main.c         |    2 +-
 drivers/net/wireless/mac80211_hwsim.c           |    2 +
 drivers/net/wireless/mwifiex/sta_cmd.c          |    2 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c      |   29 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h       |    2 +-
 drivers/net/wireless/rtlwifi/Kconfig            |   15 +-
 drivers/net/wireless/rtlwifi/Makefile           |    1 +
 drivers/net/wireless/rtlwifi/pci.c              |   23 +-
 drivers/net/wireless/rtlwifi/pci.h              |   11 -
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h    |    2 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c     |   20 +
 drivers/net/wireless/rtlwifi/rtl8192de/Makefile |   14 +
 drivers/net/wireless/rtlwifi/rtl8192de/def.h    |  269 ++
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c     | 1355 ++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/dm.h     |  212 ++
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c     |  790 +++++
 drivers/net/wireless/rtlwifi/rtl8192de/fw.h     |  155 +
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c     | 2326 ++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/hw.h     |   66 +
 drivers/net/wireless/rtlwifi/rtl8192de/led.c    |  159 +
 drivers/net/wireless/rtlwifi/rtl8192de/led.h    |   38 +
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c    | 3837 +++++++++++++++=
++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/phy.h    |  178 ++
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h    | 1313 ++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c     |  628 ++++
 drivers/net/wireless/rtlwifi/rtl8192de/rf.h     |   44 +
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c     |  423 +++
 drivers/net/wireless/rtlwifi/rtl8192de/sw.h     |   37 +
 drivers/net/wireless/rtlwifi/rtl8192de/table.c  | 1690 ++++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/table.h  |   57 +
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c    |  959 ++++++
 drivers/net/wireless/rtlwifi/rtl8192de/trx.h    |  756 +++++
 drivers/net/wireless/rtlwifi/wifi.h             |    3 -
 drivers/net/wireless/wl12xx/cmd.c               |    9 +-
 drivers/ssb/main.c                              |    4 +-
 drivers/ssb/scan.c                              |    3 +-
 include/linux/ieee80211.h                       |   18 +-
 include/net/cfg80211.h                          |    2 +-
 include/net/mac80211.h                          |    2 +
 net/bluetooth/Kconfig                           |    1 +
 net/mac80211/agg-rx.c                           |    6 +-
 net/mac80211/cfg.c                              |    5 +-
 net/mac80211/ieee80211_i.h                      |    6 +-
 net/mac80211/mlme.c                             |   41 +-
 net/mac80211/rx.c                               |    2 +-
 net/mac80211/scan.c                             |    8 +-
 net/mac80211/util.c                             |   21 +-
 net/mac80211/wme.c                              |    3 +-
 net/mac80211/wme.h                              |    5 -
 net/mac80211/work.c                             |    2 +-
 net/mac80211/wpa.c                              |    8 +-
 net/wireless/nl80211.c                          |    3 +-
 84 files changed, 16663 insertions(+), 202 deletions(-)
 create mode 100644 drivers/net/wireless/b43/tables_phy_ht.c
 create mode 100644 drivers/net/wireless/b43/tables_phy_ht.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192de/trx.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-07-05.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
