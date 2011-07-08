From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-07-08
Date: Fri, 8 Jul 2011 12:28:08 -0400
Message-ID: <20110708162808.GB15143@tuxdriver.com>
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

Here is another batch of wireless updates intended for 3.1.  The most
interesting new thing here is the NFC subsystem.  There are also the
usual variety of driver updates, particular for iwlagn, rtlwifi, rt2x00=
,
and wl12xx.  Johannes continues to tend to mac80211 as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 31817df025e24559a01d33ddd68bd11b21bf=
9d7b:

  packet: Fix build with INET disabled. (2011-07-07 08:18:04 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Aloisio Almeida Jr (3):
      NFC: add NFC socket family
      NFC: pn533: add NXP pn533 nfc device driver
      NFC: add Documentation/networking/nfc.txt

Amitkumar Karwar (1):
      mwifiex: modify SDIO aggregation Tx/Rx buffer size

Andrew Morton (1):
      drivers/net/wireless/rtlwifi/rtl8192de/phy.c: fix udelay() usage

Christian Lamparter (5):
      carl9170: import 1.9.4 firmware headers
      carl9170: enable IEEE80211_HW_NEED_DTIM_PERIOD
      carl9170: allow PSM if the 5 GHz band is selected
      mac80211: fix smatch complains
      carl9170: use carl9170 queue enums

Eliad Peller (12):
      wl12xx: add support for rx streaming
      wl12xx: add automatic rx streaming triggers
      wl12xx: add rx_streaming debugfs entry
      wl12xx: remove unused crc7 references
      wl12xx: fix erroneous commit (cb5ae0)
      wl12xx: don't check wow param on suspend/resume
      wl12xx: clear wl->wow_enabled on resume
      wl12xx: enable/disable beacon filtering on ap suspend/resume
      wl12xx_sdio: enable wowlan only if enable_irq_wake() succeeded
      wl12xx: check the vif's operstate after join
      wl12xx: use _ni version of ieee80211_tx_status
      wl12xx: use freezable workqueue for netstack_work

Emmanuel Grumbach (4):
      iwlagn: introduce transport layer and implement rx_init
      iwlagn: add rx_free to transport layer
      iwlagn: move the tx allocation funcs to the transport layer
      iwlagn: remove the indirection for the rx write pointer

=46elipe Balbi (5):
      net: wl12xx: sdio: id_tables should be __devinitconst
      net: wl12xx: remove some unnecessary prints
      net: wl12xx: care for optional operations
      net: wl12xx: remove the nops
      net: wl12xx: remove unnecessary prints

Gertjan van Wingerde (6):
      rt2x00: Serialize TX operations on a queue.
      rt2x00: Don't use queue entry as parameter when creating TX descr=
iptor.
      rt2x00: Reduce window of a queue's tx lock.
      rt2x00: Add device ID for RT539F device.
      rt2x00: Properly identify rt2800usb devices.
      rt2x00: Implement tx_frames_pending mac80211 callback function.

Ido Yariv (3):
      wl12xx: Check for FW quirks as soon as the FW boots
      wl12xx: Avoid recovery while one is already in progress
      wl12xx: Support routing FW logs to the host

Jean Delvare (1):
      ipw2100: Fix command list for debugging

Jesper Juhl (1):
      net, wireless: Don't return uninitialized in __cfg80211_stop_sche=
d_scan()

Johannes Berg (5):
      iwlagn: verify mutex held for sync commands
      mac80211: allow driver to impose WoWLAN restrictions
      mac80211: allow driver to iterate keys
      cfg80211/nl80211: support GTK rekey offload
      mac80211: support GTK rekey offload

John W. Linville (2):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jon Mason (1):
      iwlwifi: remove unnecessary read of PCI_CAP_ID_EXP

Larry Finger (4):
      rtlwifi: rtl8192de: Remove irq_enabled boolean
      rtlwifi: rtl8192de: Remove comparison of boolean with true
      rtlwifi: rtl8192de: Replace loops calling udelay with single mdel=
ay
      rtlwifi: rtl8192de: Fix error exit from hw_init

Lauro Ramos Venancio (3):
      NFC: add nfc subsystem core
      NFC: add nfc generic netlink interface
      NFC: add the NFC socket raw protocol

Luciano Coelho (1):
      wl12xx: split channel array per band in sched_scan

Michael B=C3=BCsch (1):
      b43: Add RX side DMA memory barrier

Mike McCormack (1):
      rtlwifi: rtl8192{ce,cu,se} Remove irq_enabled

Ohad Ben-Cohen (1):
      wl12xx: don't bail if mmc isn't MMC_CAP_POWER_OFF_CARD

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: detect PCI core working in hostmode

Sergei Shtylyov (3):
      ssb: PCI revision ID register is 8-bit wide
      ssb: use pci_dev->revision
      ssb: use pci_dev->subsystem_{vendor,device}

Shahar Levi (2):
      wl12xx: Enable beacon early termination in 2.4GHz band only
      wl12xx: Add Support for Low Power DRPw (LPD) Mode

Wey-Yi Guy (6):
      iwlagn: re-define the testmode cmd and attr enum
      iwlagn: add correct firmware name for 135 series
      iwlagn: add module parameter to disable stuck queue watchdog time=
r
      iwlagn: scd memory boundary
      iwlagn: call bt_coex directlly
      iwlagn: remove hcmd ops

Yogesh Ashok Powar (1):
      mac80211: Skip tailroom reservation for full HW-crypto devices wi=
th race fix

 Documentation/networking/nfc.txt             |  128 ++
 drivers/Kconfig                              |    2 -
 drivers/Makefile                             |    1 +
 drivers/bcma/Kconfig                         |    6 +
 drivers/bcma/Makefile                        |    1 +
 drivers/bcma/bcma_private.h                  |    4 +
 drivers/bcma/driver_pci.c                    |   38 +-
 drivers/bcma/driver_pci_host.c               |   14 +
 drivers/net/wireless/ath/carl9170/carl9170.h |    3 +-
 drivers/net/wireless/ath/carl9170/fw.c       |    2 +-
 drivers/net/wireless/ath/carl9170/fwcmd.h    |   19 +-
 drivers/net/wireless/ath/carl9170/fwdesc.h   |   18 +-
 drivers/net/wireless/ath/carl9170/hw.h       |   15 +-
 drivers/net/wireless/ath/carl9170/main.c     |   11 +-
 drivers/net/wireless/ath/carl9170/phy.c      |    6 -
 drivers/net/wireless/ath/carl9170/version.h  |    6 +-
 drivers/net/wireless/ath/carl9170/wlan.h     |   25 +-
 drivers/net/wireless/b43/dma.c               |    1 +
 drivers/net/wireless/ipw2x00/ipw2100.c       |    2 +-
 drivers/net/wireless/iwlwifi/Makefile        |    1 +
 drivers/net/wireless/iwlwifi/iwl-1000.c      |    2 -
 drivers/net/wireless/iwlwifi/iwl-2000.c      |   21 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |    4 -
 drivers/net/wireless/iwlwifi/iwl-6000.c      |    5 -
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c  |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c   |   88 +--
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c  |   19 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c    |   90 --
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |   54 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h       |    5 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |   22 +-
 drivers/net/wireless/iwlwifi/iwl-core.h      |   18 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   22 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c      |   13 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h      |   19 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |   47 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.h  |  236 +++--
 drivers/net/wireless/iwlwifi/iwl-trans.c     |  423 +++++++
 drivers/net/wireless/iwlwifi/iwl-trans.h     |   64 +
 drivers/net/wireless/iwlwifi/iwl-tx.c        |  139 +---
 drivers/net/wireless/mwifiex/sdio.h          |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c      |    1 +
 drivers/net/wireless/rt2x00/rt2500pci.c      |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c      |    1 +
 drivers/net/wireless/rt2x00/rt2800pci.c      |    2 +
 drivers/net/wireless/rt2x00/rt2800usb.c      |    5 +-
 drivers/net/wireless/rt2x00/rt2x00.h         |    1 +
 drivers/net/wireless/rt2x00/rt2x00crypto.c   |    6 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h      |    3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      |   14 +
 drivers/net/wireless/rt2x00/rt2x00queue.c    |  108 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h    |    2 +
 drivers/net/wireless/rt2x00/rt61pci.c        |    1 +
 drivers/net/wireless/rt2x00/rt73usb.c        |    1 +
 drivers/net/wireless/rtlwifi/pci.c           |    4 -
 drivers/net/wireless/rtlwifi/pci.h           |    1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |    2 -
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c |    9 -
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c  |   19 +-
 drivers/net/wireless/rtlwifi/rtl8192de/led.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c  |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c  |    3 -
 drivers/net/wireless/wl12xx/Kconfig          |    2 +-
 drivers/net/wireless/wl12xx/acx.c            |   49 +-
 drivers/net/wireless/wl12xx/acx.h            |   16 +
 drivers/net/wireless/wl12xx/boot.c           |   33 +
 drivers/net/wireless/wl12xx/cmd.c            |   94 ++-
 drivers/net/wireless/wl12xx/cmd.h            |   62 +
 drivers/net/wireless/wl12xx/conf.h           |   55 +
 drivers/net/wireless/wl12xx/debugfs.c        |  138 +++-
 drivers/net/wireless/wl12xx/event.c          |   36 +-
 drivers/net/wireless/wl12xx/ini.h            |    3 +
 drivers/net/wireless/wl12xx/init.c           |   19 +
 drivers/net/wireless/wl12xx/io.c             |    7 +-
 drivers/net/wireless/wl12xx/io.h             |   14 +
 drivers/net/wireless/wl12xx/main.c           |  590 ++++++++--
 drivers/net/wireless/wl12xx/ps.c             |   12 +-
 drivers/net/wireless/wl12xx/rx.c             |   39 +-
 drivers/net/wireless/wl12xx/rx.h             |   12 +
 drivers/net/wireless/wl12xx/scan.c           |   63 +-
 drivers/net/wireless/wl12xx/scan.h           |   17 +-
 drivers/net/wireless/wl12xx/sdio.c           |   71 +-
 drivers/net/wireless/wl12xx/spi.c            |   15 +-
 drivers/net/wireless/wl12xx/testmode.c       |    2 +-
 drivers/net/wireless/wl12xx/tx.c             |   33 +-
 drivers/net/wireless/wl12xx/wl12xx.h         |   38 +-
 drivers/nfc/Kconfig                          |   24 +-
 drivers/nfc/Makefile                         |    3 +
 drivers/nfc/pn533.c                          | 1632 ++++++++++++++++++=
++++++++
 drivers/ssb/pci.c                            |    9 +-
 include/linux/nfc.h                          |  126 ++
 include/linux/nl80211.h                      |   39 +
 include/linux/socket.h                       |    4 +-
 include/linux/ssb/ssb.h                      |    2 +-
 include/net/cfg80211.h                       |   26 +
 include/net/mac80211.h                       |   47 +
 include/net/nfc.h                            |  156 +++
 net/Kconfig                                  |    1 +
 net/Makefile                                 |    1 +
 net/core/sock.c                              |    6 +-
 net/mac80211/cfg.c                           |   16 +
 net/mac80211/driver-ops.h                    |   10 +
 net/mac80211/driver-trace.h                  |   49 +
 net/mac80211/ieee80211_i.h                   |    3 +
 net/mac80211/key.c                           |   96 ++-
 net/mac80211/mesh_pathtbl.c                  |    4 +-
 net/mac80211/mlme.c                          |    4 +-
 net/mac80211/pm.c                            |   16 +-
 net/mac80211/tx.c                            |   14 +-
 net/nfc/Kconfig                              |   16 +
 net/nfc/Makefile                             |    7 +
 net/nfc/af_nfc.c                             |   98 ++
 net/nfc/core.c                               |  468 ++++++++
 net/nfc/netlink.c                            |  537 +++++++++
 net/nfc/nfc.h                                |  117 ++
 net/nfc/rawsock.c                            |  354 ++++++
 net/wireless/mlme.c                          |   11 +
 net/wireless/nl80211.c                       |  113 ++
 net/wireless/nl80211.h                       |    4 +
 net/wireless/scan.c                          |    5 +-
 124 files changed, 6268 insertions(+), 1033 deletions(-)
 create mode 100644 Documentation/networking/nfc.txt
 create mode 100644 drivers/bcma/driver_pci_host.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-trans.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-trans.h
 create mode 100644 drivers/nfc/pn533.c
 create mode 100644 include/linux/nfc.h
 create mode 100644 include/net/nfc.h
 create mode 100644 net/nfc/Kconfig
 create mode 100644 net/nfc/Makefile
 create mode 100644 net/nfc/af_nfc.c
 create mode 100644 net/nfc/core.c
 create mode 100644 net/nfc/netlink.c
 create mode 100644 net/nfc/nfc.h
 create mode 100644 net/nfc/rawsock.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-07-08.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
