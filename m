From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 00/20] Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:40 -0700
Message-ID: <cover.1339739415.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	libertas-dev@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update logging style

Joe Perches (20):
  adm8211: Use pr_<level>
  airo_cs: Use pr_<level>
  at76c50x-usb: Use pr_<level>
  atmel: atmel_cs: Use pr_<level>
  b43: Use pr_<level>
  b43legacy: Use pr_<level>
  hostap: Use pr_<level>
  ipw2x00: Use pr_<level>
  libertas: Use pr_<level>
  libertas_tf: Use pr_<level>
  mac80211_hwsim: Use pr_<level>
  mwl8k: Use pr_<level>
  orinoco: Use pr_<level>
  p54: Use pr_<level>
  prism54: Use pr_<level>
  ray_cs: Use pr_<level>
  rtl818x: Use pr_<level>
  ti: Use pr_<level>
  wl3501_cs: Use pr_<level>
  zd_usb: Use pr_<level>

 drivers/net/wireless/adm8211.c                |   67 ++--
 drivers/net/wireless/airo_cs.c                |    4 +-
 drivers/net/wireless/at76c50x-usb.c           |   15 +-
 drivers/net/wireless/atmel.c                  |   71 ++--
 drivers/net/wireless/atmel_cs.c               |    4 +-
 drivers/net/wireless/b43/debugfs.c            |   20 +-
 drivers/net/wireless/b43/main.c               |   41 +--
 drivers/net/wireless/b43/pcmcia.c             |    5 +-
 drivers/net/wireless/b43legacy/b43legacy.h    |   14 +-
 drivers/net/wireless/b43legacy/debugfs.c      |    4 +-
 drivers/net/wireless/b43legacy/dma.c          |    2 +
 drivers/net/wireless/b43legacy/main.c         |   16 +-
 drivers/net/wireless/b43legacy/phy.c          |    2 +
 drivers/net/wireless/b43legacy/radio.c        |    5 +-
 drivers/net/wireless/b43legacy/xmit.c         |    2 +
 drivers/net/wireless/hostap/hostap_80211_rx.c |  125 ++++----
 drivers/net/wireless/hostap/hostap_80211_tx.c |   78 ++---
 drivers/net/wireless/hostap/hostap_ap.c       |   77 ++---
 drivers/net/wireless/hostap/hostap_cs.c       |   53 ++--
 drivers/net/wireless/hostap/hostap_download.c |  143 ++++-----
 drivers/net/wireless/hostap/hostap_hw.c       |  438 +++++++++++--------------
 drivers/net/wireless/hostap/hostap_info.c     |   36 +-
 drivers/net/wireless/hostap/hostap_ioctl.c    |  175 +++++------
 drivers/net/wireless/hostap/hostap_main.c     |  142 ++++-----
 drivers/net/wireless/hostap/hostap_pci.c      |   26 +-
 drivers/net/wireless/hostap/hostap_plx.c      |   69 ++---
 drivers/net/wireless/hostap/hostap_proc.c     |   18 +-
 drivers/net/wireless/hostap/hostap_wlan.h     |   16 +-
 drivers/net/wireless/ipw2x00/ipw2100.c        |  225 +++++--------
 drivers/net/wireless/ipw2x00/ipw2100.h        |    4 +-
 drivers/net/wireless/ipw2x00/ipw2200.c        |   54 ++--
 drivers/net/wireless/ipw2x00/ipw2200.h        |   36 ++-
 drivers/net/wireless/ipw2x00/libipw.h         |   24 +-
 drivers/net/wireless/ipw2x00/libipw_geo.c     |    3 +
 drivers/net/wireless/ipw2x00/libipw_module.c  |    9 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c      |   49 ++--
 drivers/net/wireless/ipw2x00/libipw_tx.c      |   11 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c      |    4 +-
 drivers/net/wireless/libertas/cmd.c           |    2 +
 drivers/net/wireless/libertas/cmdresp.c       |    2 +
 drivers/net/wireless/libertas/if_cs.c         |   14 +-
 drivers/net/wireless/libertas/if_sdio.c       |    6 +-
 drivers/net/wireless/libertas/if_spi.c        |    4 +-
 drivers/net/wireless/libertas/if_usb.c        |    4 +-
 drivers/net/wireless/libertas/tx.c            |    3 +
 drivers/net/wireless/libertas_tf/cmd.c        |   12 +-
 drivers/net/wireless/libertas_tf/deb_defs.h   |  105 ++++--
 drivers/net/wireless/libertas_tf/if_usb.c     |    2 +-
 drivers/net/wireless/libertas_tf/main.c       |   14 +-
 drivers/net/wireless/mac80211_hwsim.c         |   61 ++--
 drivers/net/wireless/mwl8k.c                  |   53 ++--
 drivers/net/wireless/orinoco/airport.c        |   28 +-
 drivers/net/wireless/orinoco/cfg.c            |    9 +-
 drivers/net/wireless/orinoco/hermes.c         |   71 ++--
 drivers/net/wireless/orinoco/hw.c             |   79 ++---
 drivers/net/wireless/orinoco/main.c           |  194 +++++------
 drivers/net/wireless/orinoco/mic.c            |   13 +-
 drivers/net/wireless/orinoco/orinoco.h        |   13 +-
 drivers/net/wireless/orinoco/orinoco_cs.c     |   11 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c |   40 ++--
 drivers/net/wireless/orinoco/orinoco_pci.c    |   23 +-
 drivers/net/wireless/orinoco/orinoco_pci.h    |    6 +-
 drivers/net/wireless/orinoco/orinoco_plx.c    |   40 ++--
 drivers/net/wireless/orinoco/orinoco_tmd.c    |   25 +-
 drivers/net/wireless/orinoco/orinoco_usb.c    |  145 ++++-----
 drivers/net/wireless/orinoco/scan.c           |   16 +-
 drivers/net/wireless/orinoco/spectrum_cs.c    |    6 +-
 drivers/net/wireless/orinoco/wext.c           |   28 +-
 drivers/net/wireless/p54/fwio.c               |    6 +-
 drivers/net/wireless/p54/p54spi.c             |    4 +-
 drivers/net/wireless/prism54/isl_ioctl.c      |   69 ++--
 drivers/net/wireless/prism54/islpci_dev.c     |   57 ++--
 drivers/net/wireless/prism54/islpci_eth.c     |   25 +-
 drivers/net/wireless/prism54/islpci_hotplug.c |   34 +-
 drivers/net/wireless/prism54/islpci_mgt.c     |   75 ++---
 drivers/net/wireless/prism54/islpci_mgt.h     |    9 +-
 drivers/net/wireless/prism54/oid_mgt.c        |   23 +-
 drivers/net/wireless/ray_cs.c                 |  147 ++++-----
 drivers/net/wireless/rtl818x/rtl8180/dev.c    |   35 +--
 drivers/net/wireless/rtl818x/rtl8187/dev.c    |   15 +-
 drivers/net/wireless/rtl818x/rtl8187/leds.c   |    6 +-
 drivers/net/wireless/rtl818x/rtl8187/rfkill.c |    9 +-
 drivers/net/wireless/ti/wl1251/acx.c          |  151 +++++-----
 drivers/net/wireless/ti/wl1251/boot.c         |   51 ++--
 drivers/net/wireless/ti/wl1251/cmd.c          |   76 +++---
 drivers/net/wireless/ti/wl1251/init.c         |   16 +-
 drivers/net/wireless/ti/wl1251/io.c           |   27 +-
 drivers/net/wireless/ti/wl1251/main.c         |  103 +++---
 drivers/net/wireless/ti/wl1251/ps.c           |   16 +-
 drivers/net/wireless/ti/wl1251/rx.c           |    8 +-
 drivers/net/wireless/ti/wl1251/sdio.c         |   20 +-
 drivers/net/wireless/ti/wl1251/spi.c          |   20 +-
 drivers/net/wireless/ti/wl1251/tx.c           |   21 +-
 drivers/net/wireless/ti/wl1251/wl1251.h       |   20 +-
 drivers/net/wireless/ti/wl12xx/acx.c          |    2 +-
 drivers/net/wireless/ti/wl12xx/cmd.c          |   18 +-
 drivers/net/wireless/ti/wl12xx/main.c         |   39 ++-
 drivers/net/wireless/ti/wl18xx/acx.c          |   12 +-
 drivers/net/wireless/ti/wl18xx/main.c         |   54 ++--
 drivers/net/wireless/ti/wl18xx/tx.c           |   10 +-
 drivers/net/wireless/ti/wlcore/acx.c          |  229 +++++++-------
 drivers/net/wireless/ti/wlcore/boot.c         |   56 ++--
 drivers/net/wireless/ti/wlcore/cmd.c          |  164 +++++-----
 drivers/net/wireless/ti/wlcore/debug.h        |   22 +-
 drivers/net/wireless/ti/wlcore/debugfs.c      |   42 ++--
 drivers/net/wireless/ti/wlcore/event.c        |   16 +-
 drivers/net/wireless/ti/wlcore/main.c         |  281 ++++++++--------
 drivers/net/wireless/ti/wlcore/ps.c           |   34 +-
 drivers/net/wireless/ti/wlcore/rx.c           |   33 +-
 drivers/net/wireless/ti/wlcore/scan.c         |   68 ++--
 drivers/net/wireless/ti/wlcore/sdio.c         |    3 +-
 drivers/net/wireless/ti/wlcore/testmode.c     |   16 +-
 drivers/net/wireless/ti/wlcore/tx.c           |   23 +-
 drivers/net/wireless/wl3501_cs.c              |   80 +++---
 drivers/net/wireless/zd1211rw/zd_usb.c        |   13 +-
 115 files changed, 2579 insertions(+), 2795 deletions(-)

-- 
1.7.8.111.gad25c.dirty
