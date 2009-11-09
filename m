From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-11-09
Date: Mon, 9 Nov 2009 13:30:10 -0500
Message-ID: <20091109183010.GF2805@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davme-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another big batch of patches intended for 2.6.33...  Among the usual
suspects are big updates for ath9k, iwlwifi, wl1271, mwl8k, and (especi=
ally)
rt2x00.  Also included are some patches to move some old pre-802.11
drivers over to staging, and a number of mac80211 updates.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 29906f6a427d2004a515ebbcdc7b28bae8f6=
c19c:
  Patrick McHardy (1):
        vlan: cleanup multiple unregistrations

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Andrey Yurovsky (1):
      libertas: remove internal buffers from GSPI driver

Bartlomiej Zolnierkiewicz (41):
      rt2800usb: make Kconfig help entry more helpful
      rt2800pci: make Kconfig help entry more helpful
      rt2800usb: fix rt2800usb_rfcsr_read()
      rt2800pci: fix crypto in TX frame
      rt2800pci: fix comment about register access
      rt2800pci: fix comment about IV/EIV fields
      rt2x00: fix rt2x00usb_register_read() comment
      rt2800usb: use rt2x00usb_register_multiwrite() to set key entries
      rt2800usb: fix comments in rt2800usb.h
      rt2x00: remove needless ifdefs from rt2x00leds.h
      rt2800usb: add rt2800_register_[read,write]() wrappers
      rt2800pci: add rt2800_register_[read,write]() wrappers
      rt2800usb: add rt2800_register_multi[read,write]() wrappers
      rt2800pci: add rt2800_register_multi[read,write]() wrappers
      rt2800usb: add rt2800_regbusy_read() wrapper
      rt2800pci: add rt2800_regbusy_read() wrapper
      rt2800usb: add rt2800_bbp_[read,write]() wrappers
      rt2800pci: add rt2800_bbp_[read,write]() wrappers
      rt2800usb: add rt2800_rfcsr_[read,write]() wrappers
      rt2800pci: add rt2800_rfcsr_[read,write]() wrappers
      rt2800usb: add rt2800_rf_[read,write]() wrappers
      rt2800pci: add rt2800_rf_[read,write]() wrappers
      rt2800usb: add rt2800_mcu_request() wrapper
      rt2800pci: add rt2800_mcu_request() wrapper
      rt2x00: add driver private field to struct rt2x00_dev
      rt2800usb: convert to use struct rt2800_ops methods
      rt2800pci: convert to use struct rt2800_ops methods
      rt2x00: fix rt2x00usb_register_multiwrite() arguments
      rt2x00: fix rt2x00usb_regbusy_read() arguments
      rt2x00: fix rt2x00pci_register_multi[read,write]() arguments
      rt2800: add rt2800lib.h
      rt2800usb: add RXINFO_DESC_SIZE definition
      rt2800: fix duplication in header files
      rt2800: fix comments in rt2800.h
      rt2x00: add support for different chipset interfaces
      rt2800: prepare for rt2800lib addition
      rt2800: add rt2800lib (part one)
      rt2800: add rt2800lib (part two)
      rt2x00: move REGISTER_BUSY_* definitions to rt2x00.h
      rt2800: add rt2800lib (part three)
      rt2800: add rt2800lib (part four)

Ben M Cahill (5):
      iwlwifi: remove unneeded locks from apm_stop() and stop_master()
      iwlwifi: remove power-wasting calls to apm_ops.init()
      iwlagn: invoke L0S workaround for 6000/1000 series
      iwlagn: Clarify FH_TX interrupt
      iwlagn: update write pointers for all tx queues after wakeup

Christian Lamparter (1):
      p54: disable channels with incomplete calibration data sets

Greg Kroah-Hartman (4):
      Staging: strip: add TODO file
      Staging: arlan: add TODO file
      Staging: wavelan: add TODO file
      Staging: netwave: add TODO file

G=E1bor Stefanik (1):
      b43: LP-PHY: Begin implementing calibration & software RFKILL sup=
port

Johannes Berg (19):
      cfg80211/mac80211: use debugfs_remove_recursive
      mac80211_hwsim: don't register CCK rates on 5ghz
      mac80211: remove outdated comment
      mac80211: split hardware scan by band
      mac80211: fix radiotap header generation
      mac80211: remove RX_FLAG_RADIOTAP
      mac80211: introduce ieee80211_beacon_get_tim()
      mac80211: deprecate qual value
      mac80211: unconditionally set IEEE80211_TX_CTL_SEND_AFTER_DTIM
      mac80211: also drop qos-nullfunc frames silently
      mac80211: remove sent_ps_buffered
      mac80211: remove bogus code
      mac80211: make CALL_TXH a statement
      mac80211: fix scan abort sanity checks
      cfg80211: validate scan channels
      cfg80211: remove dead variable
      mac80211: make ieee80211_find_sta per virtual interface
      mac80211: fix internal scan request
      mac80211: async station powersave handling

John W. Linville (7):
      strip: move driver to staging
      arlan: move driver to staging
      wavelan: move driver to staging
      netwave: move driver to staging
      wireless: remove WLAN_80211 and WLAN_PRE80211 from Kconfig
      wl1271: depend on INET
      mwl8k: use integral index instead of pointer for driver_data

Jouni Malinen (3):
      cfg80211: Fix WEXT compat siwauth wpa and group cipher
      mac80211_hwsim: Check idle state on TX
      mac80211_hwsim: Send ACK frames on the hwsim0 interface

Juuso Oikarinen (6):
      wl1271: Remove excess null-data template settings
      wl1271: Increase TX power value
      wl1271: Check result code of commands
      wl1271: Add retry implementation for PSM entries
      wl1271: Correct endianness-handling of command status
      wl1271: Generalize command response reading

Kalle Valo (3):
      mac80211: refactor dynamic power save check
      mac80211: fix dynamic power save for devices with nullfunc suppor=
t in hw
      wl1251: enable power save

Keng-Yu Lin (1):
      ath5k: add LED support for Acer Aspire One AO751h/AO531h

Larry Finger (4):
      b43legacy: Fix DMA TX bounce buffer copying
      b43: Remove deprecated 'qual' from returned RX status
      b43legacy: Remove deprecated 'qual' from returned RX status
      rtl8187: Remove deprecated 'qual' from returned RX status

Lennert Buytenhek (28):
      mwl8k: fix GET_STAT firmware command packet layout
      mwl8k: coding style cleanups
      mwl8k: minor transmit quiescing rework
      mwl8k: fix multicast address filter programming
      mwl8k: use the mac80211-provided workqueue instead of creating ou=
r own
      mwl8k: implement FIF_ALLMULTI
      mwl8k: enforce FIF_BCN_PRBRESP_PROMISC when no STA interfaces are=
 active
      mwl8k: clear hardware MAC address if no STA interface configured
      mwl8k: use cond_resched() when loading firmware blocks
      mwl8k: clarify WME transmit queue 0/1 swizzling
      mwl8k: report rate and other information for received frames
      mwl8k: add support for enabling hardware sniffer mode
      mwl8k: shorten receive/transmit state variable names
      mwl8k: pci BAR mapping changes
      mwl8k: change pci id table driver data to a structure pointer
      mwl8k: spell out the names of firmware images in the pci driver d=
ata
      mwl8k: handle loading AP firmware images
      mwl8k: use pci_unmap_addr{,set}() to keep track of unmap addresse=
s on rx
      mwl8k: allow for different receive descriptor formats
      mwl8k: set ->interface_modes from the driver data
      mwl8k: rename mwl8k_cmd_get_hw_spec() to mwl8k_cmd_get_hw_spec_st=
a()
      mwl8k: add the commands used for AP firmware initialisation
      mwl8k: implement AP firmware antenna configuration
      mwl8k: add AP firmware handling to ->configure_filter()
      mwl8k: add AP firmware handling to ->start()
      mwl8k: add AP firmware (mbss) handling to mwl8k_set_mac_addr()
      mwl8k: implement AP firmware EDCA parameter configuration
      mwl8k: add support for the 88w8366

Luciano Coelho (1):
      wl1271: fix init loop timeout

Luis R. Rodriguez (21):
      ath9k_hw: move mac name and rf name helpers to hw code
      ath9k_hw: distinguish single-chip solutions on initial probe prin=
t
      ath9k_hw: add AR9271 single chip name mapping
      ath9k_hw: correct AR_PHY_SPECTRAL_SCAN register offset
      ath9k_hw: remove bogus register write on ath9k_hw_9271_pa_cal()
      ath9k_hw: modify the rf control register for ar9271 revision 1.0
      ath9k_hw: update register initialization/reset values for ar9271
      ath9k_hw: change the way we initialize the pll for ar9271
      ath9k_hw: start documenting 802.11n RF anlong front ends
      ath9k_hw: bail out early on ath9k_hw_init_rf()
      ath9k_hw: simplify rf attach and rename to ath9k_hw_rf_alloc_ext_=
banks()
      ath9k_hw: simplify ath9k_hw_rf_alloc_ext_banks()
      ath9k_hw: rename ath9k_hw_rf_free() to ath9k_hw_rf_free_ext_banks=
()
      ath9k_hw: make both analog channel change routines return int
      ath9k_hw: use a callback for frequency change
      ath9k_hw: order phy.c code and integrate spur mitigation
      ath9k_hw: make spur mitigation a callback
      ath9k_hw: remove unused modesIndex param from ath9k_hw_write_regs=
()
      ath9k_hw: Fix and complete force bias for AR5416
      ath9k_hw: make ath9k_phy_modify_rx_buffer() static
      wl1271: use __dev_alloc_skb() on RX

Randy Dunlap (1):
      wireless: airo_cs needs WEXT_SPY

Reinette Chatre (7):
      iwlwifi: provide firmware version
      iwlwifi: unmap memory before use
      iwlwifi: move iwl_[un]init_drv to iwlagn
      iwlwifi: split adding broadcast station from others
      iwl3945: store station rate scale information in mac80211 station=
 structure
      iwlagn: move rate scale initialization to init function
      iwlwifi: print warning when sending host command fails

Sujith (1):
      mac80211: Fix IBSS merge

Wey-Yi Guy (3):
      iwlwifi: coex API data structure
      iwlwifi: add SM PS support for 6x50 series
      iwlwifi: add wimax/wifi coexist support for 6x50 series

Zhu Yi (1):
      mac80211: make align adjustment code support paged SKB

 drivers/net/wireless/Kconfig                       |  140 +--
 drivers/net/wireless/Makefile                      |   10 -
 drivers/net/wireless/ath/Kconfig                   |    1 -
 drivers/net/wireless/ath/ar9170/Kconfig            |    2 +-
 drivers/net/wireless/ath/ath5k/Kconfig             |    2 +-
 drivers/net/wireless/ath/ath5k/led.c               |    2 +
 drivers/net/wireless/ath/ath9k/Kconfig             |    2 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   10 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    4 +
 drivers/net/wireless/ath/ath9k/hw.c                |  669 ++-----
 drivers/net/wireless/ath/ath9k/hw.h                |   22 +-
 drivers/net/wireless/ath/ath9k/initvals.h          |   29 +-
 drivers/net/wireless/ath/ath9k/main.c              |   58 -
 drivers/net/wireless/ath/ath9k/pci.c               |   10 +-
 drivers/net/wireless/ath/ath9k/phy.c               | 1100 +++++++++---
 drivers/net/wireless/ath/ath9k/phy.h               |   40 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    3 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    3 +
 drivers/net/wireless/ath/ath9k/xmit.c              |    3 +-
 drivers/net/wireless/b43/Kconfig                   |    2 +-
 drivers/net/wireless/b43/b43.h                     |    2 -
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/b43/phy_lp.c                  |  783 +++++++--
 drivers/net/wireless/b43/phy_lp.h                  |   11 +-
 drivers/net/wireless/b43/xmit.c                    |    1 -
 drivers/net/wireless/b43legacy/Kconfig             |    2 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |    2 -
 drivers/net/wireless/b43legacy/dma.c               |   17 +-
 drivers/net/wireless/b43legacy/main.c              |    2 +-
 drivers/net/wireless/b43legacy/xmit.c              |    1 -
 drivers/net/wireless/hostap/Kconfig                |    1 -
 drivers/net/wireless/ipw2x00/Kconfig               |    6 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |  102 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |   35 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   25 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  143 ++-
 drivers/net/wireless/iwlwifi/iwl-calib.c           |    1 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |  161 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  236 ++--
 drivers/net/wireless/iwlwifi/iwl-core.h            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   11 +
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    2 +
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    1 +
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   69 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   13 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   15 +-
 drivers/net/wireless/iwmc3200wifi/Kconfig          |    2 +-
 drivers/net/wireless/libertas/Kconfig              |    2 +-
 drivers/net/wireless/libertas/if_spi.c             |  136 +--
 drivers/net/wireless/mac80211_hwsim.c              |   67 +-
 drivers/net/wireless/mwl8k.c                       | 1258 +++++++++---=
-
 drivers/net/wireless/orinoco/Kconfig               |    2 +-
 drivers/net/wireless/p54/Kconfig                   |    2 +-
 drivers/net/wireless/p54/eeprom.c                  |   31 +-
 drivers/net/wireless/rt2x00/Kconfig                |   18 +-
 drivers/net/wireless/rt2x00/Makefile               |    1 +
 drivers/net/wireless/rt2x00/rt2800.h               | 1816 ++++++++++++=
+++++++
 drivers/net/wireless/rt2x00/rt2800lib.c            | 1817 ++++++++++++=
+++++++
 drivers/net/wireless/rt2x00/rt2800lib.h            |  134 ++
 drivers/net/wireless/rt2x00/rt2800pci.c            | 1908 ++----------=
--------
 drivers/net/wireless/rt2x00/rt2800pci.h            | 1780 ------------=
------
 drivers/net/wireless/rt2x00/rt2800usb.c            | 1828 +-----------=
-------
 drivers/net/wireless/rt2x00/rt2800usb.h            | 1818 +-----------=
--------
 drivers/net/wireless/rt2x00/rt2x00.h               |   43 +
 drivers/net/wireless/rt2x00/rt2x00leds.h           |    4 -
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   24 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   17 +-
 drivers/net/wireless/rtl818x/rtl8187.h             |    1 -
 drivers/net/wireless/rtl818x/rtl8187_dev.c         |   13 +-
 drivers/net/wireless/wl12xx/Kconfig                |    3 +-
 drivers/net/wireless/wl12xx/wl1251_main.c          |    3 +-
 drivers/net/wireless/wl12xx/wl1271.h               |    3 +
 drivers/net/wireless/wl12xx/wl1271_acx.c           |    2 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c          |    5 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |   99 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |    3 +-
 drivers/net/wireless/wl12xx/wl1271_conf.h          |    8 +
 drivers/net/wireless/wl12xx/wl1271_event.c         |   53 +
 drivers/net/wireless/wl12xx/wl1271_event.h         |    7 +
 drivers/net/wireless/wl12xx/wl1271_init.c          |    7 +-
 drivers/net/wireless/wl12xx/wl1271_main.c          |   19 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c            |    2 +-
 drivers/net/wireless/zd1211rw/Kconfig              |    2 +-
 drivers/staging/Kconfig                            |    8 +
 drivers/staging/Makefile                           |    5 +
 drivers/staging/arlan/Kconfig                      |   15 +
 drivers/staging/arlan/Makefile                     |    3 +
 drivers/staging/arlan/TODO                         |    7 +
 .../{net/wireless =3D> staging/arlan}/arlan-main.c   |    0
 .../{net/wireless =3D> staging/arlan}/arlan-proc.c   |    0
 drivers/{net/wireless =3D> staging/arlan}/arlan.h    |    0
 drivers/staging/netwave/Kconfig                    |   11 +
 drivers/staging/netwave/Makefile                   |    1 +
 drivers/staging/netwave/TODO                       |    7 +
 .../{net/wireless =3D> staging/netwave}/netwave_cs.c |    0
 drivers/staging/strip/Kconfig                      |   22 +
 drivers/staging/strip/Makefile                     |    1 +
 drivers/staging/strip/TODO                         |    7 +
 drivers/{net/wireless =3D> staging/strip}/strip.c    |    0
 drivers/staging/wavelan/Kconfig                    |   38 +
 drivers/staging/wavelan/Makefile                   |    2 +
 drivers/staging/wavelan/TODO                       |    7 +
 drivers/{net/wireless =3D> staging/wavelan}/i82586.h |    0
 drivers/{net/wireless =3D> staging/wavelan}/i82593.h |    0
 .../{net/wireless =3D> staging/wavelan}/wavelan.c    |    0
 .../{net/wireless =3D> staging/wavelan}/wavelan.h    |    0
 .../{net/wireless =3D> staging/wavelan}/wavelan.p.h  |    0
 .../{net/wireless =3D> staging/wavelan}/wavelan_cs.c |    0
 .../{net/wireless =3D> staging/wavelan}/wavelan_cs.h |    0
 .../wireless =3D> staging/wavelan}/wavelan_cs.p.h    |    0
 include/linux/ieee80211.h                          |   12 +-
 include/net/ieee80211_radiotap.h                   |    2 +-
 include/net/mac80211.h                             |  116 +-
 net/mac80211/cfg.c                                 |    7 -
 net/mac80211/debugfs.c                             |   73 +-
 net/mac80211/debugfs.h                             |    2 -
 net/mac80211/debugfs_key.c                         |   44 +-
 net/mac80211/debugfs_netdev.c                      |  174 +--
 net/mac80211/debugfs_sta.c                         |   38 +-
 net/mac80211/ibss.c                                |    4 +
 net/mac80211/ieee80211_i.h                         |  123 +--
 net/mac80211/iface.c                               |    8 +-
 net/mac80211/key.h                                 |   12 -
 net/mac80211/main.c                                |   11 +-
 net/mac80211/rate.c                                |    7 +-
 net/mac80211/rx.c                                  |  173 +--
 net/mac80211/scan.c                                |  119 +-
 net/mac80211/sta_info.c                            |  136 ++-
 net/mac80211/sta_info.h                            |   47 +-
 net/mac80211/tx.c                                  |   99 +-
 net/mac80211/util.c                                |    8 +-
 net/wireless/core.c                                |    3 +-
 net/wireless/core.h                                |   11 -
 net/wireless/debugfs.c                             |   15 +-
 net/wireless/debugfs.h                             |    3 -
 net/wireless/mlme.c                                |    2 -
 net/wireless/nl80211.c                             |   34 +-
 net/wireless/scan.c                                |    6 +
 net/wireless/wext-compat.c                         |    6 +-
 147 files changed, 8305 insertions(+), 9862 deletions(-)
 create mode 100644 drivers/net/wireless/rt2x00/rt2800.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2800lib.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2800lib.h
 create mode 100644 drivers/staging/arlan/Kconfig
 create mode 100644 drivers/staging/arlan/Makefile
 create mode 100644 drivers/staging/arlan/TODO
 rename drivers/{net/wireless =3D> staging/arlan}/arlan-main.c (100%)
 rename drivers/{net/wireless =3D> staging/arlan}/arlan-proc.c (100%)
 rename drivers/{net/wireless =3D> staging/arlan}/arlan.h (100%)
 create mode 100644 drivers/staging/netwave/Kconfig
 create mode 100644 drivers/staging/netwave/Makefile
 create mode 100644 drivers/staging/netwave/TODO
 rename drivers/{net/wireless =3D> staging/netwave}/netwave_cs.c (100%)
 create mode 100644 drivers/staging/strip/Kconfig
 create mode 100644 drivers/staging/strip/Makefile
 create mode 100644 drivers/staging/strip/TODO
 rename drivers/{net/wireless =3D> staging/strip}/strip.c (100%)
 create mode 100644 drivers/staging/wavelan/Kconfig
 create mode 100644 drivers/staging/wavelan/Makefile
 create mode 100644 drivers/staging/wavelan/TODO
 rename drivers/{net/wireless =3D> staging/wavelan}/i82586.h (100%)
 rename drivers/{net/wireless =3D> staging/wavelan}/i82593.h (100%)
 rename drivers/{net/wireless =3D> staging/wavelan}/wavelan.c (100%)
 rename drivers/{net/wireless =3D> staging/wavelan}/wavelan.h (100%)
 rename drivers/{net/wireless =3D> staging/wavelan}/wavelan.p.h (100%)
 rename drivers/{net/wireless =3D> staging/wavelan}/wavelan_cs.c (100%)
 rename drivers/{net/wireless =3D> staging/wavelan}/wavelan_cs.h (100%)
 rename drivers/{net/wireless =3D> staging/wavelan}/wavelan_cs.p.h (100=
%)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-11-09.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
