From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-02-22
Date: Mon, 22 Feb 2010 13:56:38 -0500
Message-ID: <20100222185638.GC2988@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is one more big batch of wireless bits intended for 2.6.34.  Along
with the usual variety of driver fixes are some mac80211 bits from
Johannes, a number of iwlwifi updates from Intel, and a big batch of of
wl1271 bits from Nokia.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 06c92ee6384c33dbb6e313c66272181db70a=
bbb0:
  Alexander Beregalov (1):
        eepro: fix netdev_mc_count conversion

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (2):
      iwlwifi: cleanup return values
      iwlwifi: indicate calib version for 6050 series

Darren Jenkins (1):
      drivers/net/wireless/p54/txrx.c Fix off by one error

=46elix Fietkau (2):
      ath9k: fix rate control fallback rate selection
      ath9k: fix beacon timer restart after a card reset

=46rederic Leroy (1):
      staging: rtl8192su: fix compile error from wireless-testing commi=
t

Gertjan van Wingerde (4):
      rt2x00: Introduce SoC interface type.
      rt2x00: Reorganize RT chipset setting for PCI/SOC devices.
      rt2x00: rework RT chipset and revision determination for PCI an S=
OC devices.
      rt2x00: rt2800 - Make rt30xx and rt35xx chipsets configurable.

Hauke Mehrtens (3):
      b43legacy: fix typo in ifdef comment
      rtl8187: fix typo in ifdef comment
      ssb: fix typo in ifdef comment

Jean-Fran=E7ois Moine (1):
      p54usb: Add the USB ID for Belkin (Accton) FD7050E ver 1010ec

Johannes Berg (8):
      mac80211: fix netdev rename
      mac80211: reject unhandled action frames
      mac80211: split ieee80211_drop_unencrypted
      ar9170: convert to new station add/remove callbacks
      p54: convert to new station add/remove callbacks
      mac80211_hwsim: convert to new station add/remove callbacks
      ath9k: convert to new station add/remove callbacks
      mwl8k: convert to new station add/remove callbacks

John W. Linville (1):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6

Jouni Malinen (2):
      cfg80211/mac80211: allow registering for and sending action frame=
s
      ath9k: Use the Beacon TX rate from mac80211

Juuso Oikarinen (11):
      wl1271: Fix PSM entry
      wl1271: Fix channel changing code
      wl1271: Add SSID configuration for JOIN in ad-hoc
      wl1271: Use NVS INI file configuration
      wl1271: Retrieve device mac address from the nvs file
      wl1271: Fix random MAC address setting
      wl1271: Optimized RX path packet retrieval
      wl1271: Fix key-remove error
      wl1271: Fix WEP key handling
      wl1271: Fix ad-hoc SSID update
      wl1271: Fix beacon filter table configuration

Kalle Valo (7):
      nl80211: add power save commands
      wl1271: modify wl1271_acx_ac_cfg() to use function parameters
      wl1271: modify wl1271_acx_tid_cfg() to use function parameters
      wl1271: implement WMM
      wl1271: wakeup chip in op_conf_tx()
      wl1271: add testmode support
      MAINTAINERS: update Kalle's email address

Larry Finger (1):
      ssb: Add PCI ID 0x4322 to PHU handling

Luciano Coelho (2):
      wl1271: add most of the normal initialization commands to PLT mod=
e
      wl1271: skip 3 unused bytes from the NVS

Pavel Roskin (2):
      mwl8k: disable softirqs when accessing sta_notify_list
      Introduce PCMCIA_DEVICE_PROD_ID3

Randy Dunlap (1):
      wireless: airo_cs build fixes

Reinette Chatre (4):
      iwlwifi: fix scan race
      iwlwifi: reset card during probe
      iwl3945: remove STATUS macros from header
      iwlwifi: enable serialization of synchronous commands

Shimada Hirofumi (1):
      p54usb: Add usbid for Corega CG-WLUSB2GT.

Stanislaw Gruszka (1):
      iwlwifi: use dma_alloc_coherent

Teemu Paasikivi (4):
      wl1271: Moved common IO functions from wl271_spi.c to wl1271_io.c
      wl1271: Renamed IO functions
      wl1271: Added IO reset and init functions
      wl1271: Added alloc and free hw functions

Thadeu Lima de Souza Cascardo (1):
      nl80211: does not allow NEW_STATION and DEL_STATION for mesh

Trieu 'Andrew' Nguyen (2):
      iwlwifi: Adjusting PLCP error threshold for 1000 NIC
      iwlwifi: Monitor and recover the aggregation TX flow failure

Wey-Yi Guy (8):
      iwlwifi: clear all tx queues when firmware ready
      iwlwifi: multiple force reset mode
      iwlwifi: add debug function to reset/reload radio/firmware
      iwlwifi: check for aggregation frame and queue
      iwlwifi: remove unused op-code in PHY Calibration command
      iwlwifi: clear all the stop_queue flag after load firmware
      iwlwifi: separated time check for different type of force reset
      iwlwifi: add debugfs to monitor force reset parameters

 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/airo.c                        |    1 +
 drivers/net/wireless/ath/ar9170/main.c             |   70 ++--
 drivers/net/wireless/ath/ath9k/beacon.c            |   19 +-
 drivers/net/wireless/ath/ath9k/main.c              |   35 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   15 +-
 drivers/net/wireless/b43legacy/leds.h              |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c            |   17 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |   18 -
 drivers/net/wireless/iwlwifi/iwl-4965.c            |    7 +
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    7 +
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   79 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   15 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   29 ++-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    4 -
 drivers/net/wireless/iwlwifi/iwl-core.c            |   59 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   60 +++-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   26 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |    7 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   80 +++-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   37 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   64 ++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   42 +-
 drivers/net/wireless/mac80211_hwsim.c              |   32 +-
 drivers/net/wireless/mwl8k.c                       |  106 +----
 drivers/net/wireless/orinoco/orinoco_cs.c          |    9 +-
 drivers/net/wireless/p54/main.c                    |   28 +-
 drivers/net/wireless/p54/p54usb.c                  |    2 +
 drivers/net/wireless/p54/txrx.c                    |    2 +-
 drivers/net/wireless/rt2x00/Kconfig                |   67 +++-
 drivers/net/wireless/rt2x00/rt2400pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    1 +
 drivers/net/wireless/rt2x00/rt2500pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   14 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  115 +++--
 drivers/net/wireless/rt2x00/rt2800pci.c            |   49 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |  306 ++++++++----=
-
 drivers/net/wireless/rt2x00/rt2x00.h               |   66 +--
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    7 -
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    1 +
 drivers/net/wireless/rt2x00/rt2x00soc.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2x00soc.h            |   10 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   14 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    9 +
 drivers/net/wireless/rt2x00/rt73usb.c              |    7 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    2 +
 drivers/net/wireless/rtl818x/rtl8187_leds.c        |    2 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.h        |    2 +-
 drivers/net/wireless/wl12xx/Makefile               |    4 +-
 drivers/net/wireless/wl12xx/wl1271.h               |   34 ++-
 drivers/net/wireless/wl12xx/wl1271_acx.c           |   62 ++--
 drivers/net/wireless/wl12xx/wl1271_acx.h           |   13 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c          |  106 ++---
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |  136 ++-----
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |   88 +----
 drivers/net/wireless/wl12xx/wl1271_conf.h          |  144 +------
 drivers/net/wireless/wl12xx/wl1271_event.c         |   50 ++-
 drivers/net/wireless/wl12xx/wl1271_init.c          |   38 ++-
 drivers/net/wireless/wl12xx/wl1271_init.h          |    4 +
 drivers/net/wireless/wl12xx/wl1271_io.c            |  213 +++++++++
 drivers/net/wireless/wl12xx/wl1271_io.h            |   68 +++
 drivers/net/wireless/wl12xx/wl1271_main.c          |  481 ++++++++++++=
--------
 drivers/net/wireless/wl12xx/wl1271_ps.c            |   22 +-
 drivers/net/wireless/wl12xx/wl1271_ps.h            |    3 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c            |   11 +-
 drivers/net/wireless/wl12xx/wl1271_spi.c           |  157 -------
 drivers/net/wireless/wl12xx/wl1271_spi.h           |   30 --
 drivers/net/wireless/wl12xx/wl1271_testmode.c      |  283 ++++++++++++
 drivers/net/wireless/wl12xx/wl1271_testmode.h      |   31 ++
 drivers/net/wireless/wl12xx/wl1271_tx.c            |   28 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h            |   36 ++
 drivers/ssb/driver_chipcommon_pmu.c                |    7 +
 drivers/ssb/ssb_private.h                          |    4 +-
 drivers/staging/rtl8192su/ieee80211/ieee80211.h    |   12 +-
 .../staging/rtl8192su/ieee80211/ieee80211_r8192s.h |    2 +-
 drivers/staging/rtl8192su/ieee80211/ieee80211_rx.c |   18 +-
 .../rtl8192su/ieee80211/ieee80211_softmac.c        |   38 +-
 .../staging/rtl8192su/ieee80211/rtl819x_BAProc.c   |    4 +-
 drivers/staging/rtl8192su/r8192U_core.c            |    4 +-
 include/linux/nl80211.h                            |   51 ++-
 include/net/cfg80211.h                             |   54 ++-
 include/net/mac80211.h                             |    6 +-
 include/pcmcia/device_id.h                         |    5 +
 net/mac80211/cfg.c                                 |   12 +-
 net/mac80211/ieee80211_i.h                         |    6 +-
 net/mac80211/iface.c                               |    2 +-
 net/mac80211/mlme.c                                |   35 ++
 net/mac80211/rx.c                                  |  140 ++++--
 net/mac80211/status.c                              |    7 +-
 net/wireless/core.c                                |   20 +-
 net/wireless/core.h                                |    9 +
 net/wireless/mlme.c                                |  166 +++++++
 net/wireless/nl80211.c                             |  440 ++++++++++++=
++++--
 net/wireless/nl80211.h                             |    8 +
 net/wireless/wext-compat.c                         |   10 +-
 104 files changed, 3097 insertions(+), 1621 deletions(-)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_io.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_io.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_testmode.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_testmode.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-02-22.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
