From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6.26 2008-04-08
Date: Tue, 8 Apr 2008 17:10:43 -0400
Message-ID: <20080408211043.GA17197@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another week, another 50+ patches for 2.6.26...

There are the usual libertas, iwlwifi, and b43 (and ssb) updates, plus a
few other fixes for issues already in net-2.6.26.  There is also some
movement of files to more convenient places or names.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26/

---

The following changes since commit 8eefca4888c986d993b2571eb31f0397a5d0a178:
  David S. Miller (1):
        Merge branch 'net-2.6.26-isatap-20080403' of git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.26.git master

Chr (1):
      mac80211: add station aid into ieee80211_tx_control

Christian Lamparter (2):
      p54: move to separate directory
      drivers/net/wireless/p54/net2280.h: silence checkpatch.pl

Denys Vlasenko (1):
      wavelan_cs: stop inlining largish static functions

Holger Schurig (4):
      libertas: move association code from join.c into scan.c
      libertas: move association code from scan.c into assoc.c
      libertas: move lbs_update_channel out of assoc.c
      libertas: remove lbs_get_fwversion()

Ivo van Doorn (1):
      rt2x00: Use lib->config_filter() during scheduled packet filter config

Jiri Slaby (1):
      mac80211: fix defined but not used

Johannes Berg (10):
      iwlwifi: fix some warnings
      mac80211: fix possible sta-debugfs work lockup
      mac80211: clean up IEEE80211_FC use
      iwlwifi: honour regulatory restrictions in scan code
      mac80211: make debugfs files root-only
      mac80211: fix ieee80211_ioctl_giwrate
      mac80211: fix sta-info pinning
      mac80211: fix key vs. sta locking problems
      mac80211: rename files
      mac80211: fix key debugfs default_key link

John W. Linville (5):
      Revert "mac80211: use a struct for bss->mesh_config"
      drivers/net/wireless/iwlwifi/iwl-debugfs.c: fix another '%llu' warning
      iwlwifi/Kconfg: make IWLWIFI_LEDS invisible
      drivers/net/wireless/iwlwifi/iwl-3945.h: correct CONFIG_IWL4965_LEDS typo
      cfg80211: default to regulatory max power for channel

Luis R. Rodriguez (1):
      prism54: set carrier flags correctly

Michael Buesch (12):
      ssb-pcmcia: IRQ and DMA related fixes
      b43: Add PIO support for PCMCIA devices
      ssb: Turn suspend/resume upside down
      ssb: Fix build for non-PCIhost
      ssb: Add support for block-I/O
      b43: Use SSB block-I/O to do PIO
      b43: Add more N-PHY stuff
      b43: Fix TBTT and PU timings
      b43: Beaconing fixes
      b43: Fix beacon BH update
      b43: Fix PHY TX control words in SHM
      b43: use b43_is_mode() call

Mohamed Abbas (2):
      iwlwifi: fix rfkill memory error
      mac80211: notify mac from low level driver (iwlwifi)

Pavel Machek (1):
      adm8211: remove commented-out code

Reinette Chatre (3):
      iwl4965: use IWLWIFI_LEDS config variable
      iwlwifi: ensure led registration complete as part of initialization
      mac80211: notify upper layers after lower

Ron Rindjunsky (1):
      mac80211: BA session debug prints changes

Tomas Winkler (7):
      mac80211: eliminate conf_ht
      iwlwifi: eliminate conf_ht
      mac80211: add association capabilty and timing info into bss_conf
      iwlwifi: Eliminate association from beacon
      iwlwifi: hw names cleanup
      iwlwifi: move driver status inliners into iwl-core.h
      iwlwifi: use ieee80211_frequency_to_channel

 drivers/net/wireless/Kconfig                |   65 +--
 drivers/net/wireless/Makefile               |    4 +-
 drivers/net/wireless/adm8211.c              |    7 -
 drivers/net/wireless/b43/Kconfig            |   18 +
 drivers/net/wireless/b43/Makefile           |    1 +
 drivers/net/wireless/b43/b43.h              |   63 ++-
 drivers/net/wireless/b43/dma.c              |  120 ++--
 drivers/net/wireless/b43/dma.h              |    3 +
 drivers/net/wireless/b43/main.c             |  399 ++++++---
 drivers/net/wireless/b43/nphy.c             |    1 -
 drivers/net/wireless/b43/pcmcia.c           |   10 +-
 drivers/net/wireless/b43/pio.c              |  842 ++++++++++++++++++
 drivers/net/wireless/b43/pio.h              |  220 +++++
 drivers/net/wireless/b43/xmit.c             |   84 ++-
 drivers/net/wireless/b43/xmit.h             |   32 +-
 drivers/net/wireless/iwlwifi/Kconfig        |   10 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   10 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h  |   16 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |  222 +-----
 drivers/net/wireless/iwlwifi/iwl-4965.h     |   32 +-
 drivers/net/wireless/iwlwifi/iwl-core.c     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   57 ++
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |    3 +-
 drivers/net/wireless/iwlwifi/iwl-led.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h     |   74 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c   |   40 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.h   |    2 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    8 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |  319 +++----
 drivers/net/wireless/libertas/Makefile      |    2 +-
 drivers/net/wireless/libertas/assoc.c       | 1231 ++++++++++++++++++++++++++-
 drivers/net/wireless/libertas/assoc.h       |   28 +
 drivers/net/wireless/libertas/cmd.c         |   18 +-
 drivers/net/wireless/libertas/cmdresp.c     |    2 +-
 drivers/net/wireless/libertas/decl.h        |    3 -
 drivers/net/wireless/libertas/dev.h         |   41 +-
 drivers/net/wireless/libertas/ethtool.c     |   10 +-
 drivers/net/wireless/libertas/join.c        |  872 -------------------
 drivers/net/wireless/libertas/join.h        |   48 -
 drivers/net/wireless/libertas/main.c        |    2 +-
 drivers/net/wireless/libertas/scan.c        |  364 +--------
 drivers/net/wireless/libertas/scan.h        |   62 +--
 drivers/net/wireless/libertas/wext.c        |   19 +-
 drivers/net/wireless/net2280.h              |  452 ----------
 drivers/net/wireless/p54/Kconfig            |   63 ++
 drivers/net/wireless/p54/Makefile           |    3 +
 drivers/net/wireless/p54/net2280.h          |  452 ++++++++++
 drivers/net/wireless/{ => p54}/p54.h        |    0 
 drivers/net/wireless/{ => p54}/p54common.c  |    0 
 drivers/net/wireless/{ => p54}/p54common.h  |    0 
 drivers/net/wireless/{ => p54}/p54pci.c     |    0 
 drivers/net/wireless/{ => p54}/p54pci.h     |    0 
 drivers/net/wireless/{ => p54}/p54usb.c     |    0 
 drivers/net/wireless/{ => p54}/p54usb.h     |    0 
 drivers/net/wireless/prism54/isl_ioctl.c    |    5 +-
 drivers/net/wireless/prism54/islpci_dev.c   |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |   12 +-
 drivers/net/wireless/wavelan_cs.c           |   47 +-
 drivers/net/wireless/wavelan_cs.p.h         |   26 +-
 drivers/ssb/Kconfig                         |    5 +
 drivers/ssb/driver_chipcommon.c             |    2 +-
 drivers/ssb/main.c                          |  189 +++--
 drivers/ssb/pci.c                           |   70 ++
 drivers/ssb/pcihost_wrapper.c               |   10 +
 drivers/ssb/pcmcia.c                        |  181 ++++-
 drivers/ssb/ssb_private.h                   |    5 +
 include/linux/ssb/ssb.h                     |   29 +-
 include/linux/ssb/ssb_driver_chipcommon.h   |    3 +-
 include/net/mac80211.h                      |   36 +-
 net/mac80211/Makefile                       |   12 +-
 net/mac80211/aes_ccm.c                      |    2 +-
 net/mac80211/cfg.c                          |   46 +-
 net/mac80211/debugfs.c                      |    6 +-
 net/mac80211/debugfs_key.c                  |   42 +-
 net/mac80211/debugfs_key.h                  |   11 +-
 net/mac80211/debugfs_netdev.c               |    8 +-
 net/mac80211/debugfs_sta.c                  |    2 +-
 net/mac80211/ieee80211_i.h                  |   32 +-
 net/mac80211/{ieee80211_iface.c => iface.c} |    0 
 net/mac80211/key.c                          |  408 ++++++----
 net/mac80211/{ieee80211_key.h => key.h}     |   21 +-
 net/mac80211/{ieee80211_led.c => led.c}     |    2 +-
 net/mac80211/{ieee80211_led.h => led.h}     |    0 
 net/mac80211/{ieee80211.c => main.c}        |  101 ++-
 net/mac80211/mesh.c                         |    4 +
 net/mac80211/mesh.h                         |   10 -
 net/mac80211/mesh_hwmp.c                    |    2 -
 net/mac80211/mesh_plink.c                   |    3 +-
 net/mac80211/{ieee80211_sta.c => mlme.c}    |  126 ++--
 net/mac80211/{ieee80211_rate.c => rate.c}   |    2 +-
 net/mac80211/{ieee80211_rate.h => rate.h}   |    0 
 net/mac80211/rc80211_pid_algo.c             |    2 +-
 net/mac80211/rc80211_pid_debugfs.c          |    2 +-
 net/mac80211/rx.c                           |    2 +-
 net/mac80211/sta_info.c                     |  183 +++--
 net/mac80211/sta_info.h                     |    3 +-
 net/mac80211/tkip.c                         |    2 +-
 net/mac80211/tkip.h                         |    2 +-
 net/mac80211/tx.c                           |    5 +-
 net/mac80211/util.c                         |    2 +-
 net/mac80211/wep.h                          |    2 +-
 net/mac80211/{ieee80211_ioctl.c => wext.c}  |   48 +-
 net/wireless/reg.c                          |    5 +-
 106 files changed, 4857 insertions(+), 3222 deletions(-)
 create mode 100644 drivers/net/wireless/b43/pio.c
 create mode 100644 drivers/net/wireless/b43/pio.h
 delete mode 100644 drivers/net/wireless/libertas/join.c
 delete mode 100644 drivers/net/wireless/libertas/join.h
 delete mode 100644 drivers/net/wireless/net2280.h
 create mode 100644 drivers/net/wireless/p54/Kconfig
 create mode 100644 drivers/net/wireless/p54/Makefile
 create mode 100644 drivers/net/wireless/p54/net2280.h
 rename drivers/net/wireless/{ => p54}/p54.h (100%)
 rename drivers/net/wireless/{ => p54}/p54common.c (100%)
 rename drivers/net/wireless/{ => p54}/p54common.h (100%)
 rename drivers/net/wireless/{ => p54}/p54pci.c (100%)
 rename drivers/net/wireless/{ => p54}/p54pci.h (100%)
 rename drivers/net/wireless/{ => p54}/p54usb.c (100%)
 rename drivers/net/wireless/{ => p54}/p54usb.h (100%)
 rename net/mac80211/{ieee80211_iface.c => iface.c} (100%)
 rename net/mac80211/{ieee80211_key.h => key.h} (84%)
 rename net/mac80211/{ieee80211_led.c => led.c} (99%)
 rename net/mac80211/{ieee80211_led.h => led.h} (100%)
 rename net/mac80211/{ieee80211.c => main.c} (96%)
 rename net/mac80211/{ieee80211_sta.c => mlme.c} (98%)
 rename net/mac80211/{ieee80211_rate.c => rate.c} (99%)
 rename net/mac80211/{ieee80211_rate.h => rate.h} (100%)
 rename net/mac80211/{ieee80211_ioctl.c => wext.c} (98%)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26-2008-04-08.patch.bz2
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
