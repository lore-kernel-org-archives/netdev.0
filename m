From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-dev updated 2007-01-25
Date: Thu, 25 Jan 2007 21:43:17 -0500
Message-ID: <20070126024317.GJ10282@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3484 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030718AbXAZDIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 22:08:11 -0500
Received: from ra.tuxdriver.com (ra.tuxdriver.com [127.0.0.1])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id l0Q37wBE009320
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 25 Jan 2007 22:08:03 -0500
Received: (from uucp@localhost)
	by ra.tuxdriver.com (8.13.7/8.13.6/Submit) with UUCP id l0Q2jPZ6008907
	for netdev@vger.kernel.org; Thu, 25 Jan 2007 21:45:25 -0500
Received: from linville-t43.mobile (linville-t43.mobile [127.0.0.1])
	by linville-t43.mobile (8.13.8/8.13.8) with ESMTP id l0Q2hH8a009487
	for <netdev@vger.kernel.org>; Thu, 25 Jan 2007 21:43:17 -0500
Received: (from linville@localhost)
	by linville-t43.mobile (8.13.8/8.13.8/Submit) id l0Q2hHc0009486
	for netdev@vger.kernel.org; Thu, 25 Jan 2007 21:43:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit a4893aa0bb61c7bbced8fcdea874cb8d0e1d3a8d:
  John W. Linville (1):
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

Gertjan van Wingerde (1):
      d80211: Select CRYPTO_ECB when enabler d80211.

Ivo van Doorn (4):
      eeprom_93cx6
      rt2x00 should use generic eeprom_93cx6
      crc-itu-t
      rt2x00 should use generic crc-itu-t

Jan Kiszka (1):
      d80211: Fix inconsistent sta_lock usage

John W. Linville (2):
      Merge http://bu3sch.de/git/wireless-dev
      Merge git://git.kernel.org/.../jbenc/dscape

Michael Buesch (47):
      bcm43xx-d80211: Add some PHY register definitions.
      bcm43xx-d80211: Move ILT stuff to OFDM table stuff
      bcm43xx-d80211: Remove PHY OFDM routing bit, if we are on A-PHY.
      bcm43xx-d80211: Merge new LO-control code.
      bcm43xx-d80211: Fix compilation: Missing files for LO and VSTACK.
      bcm43xx-d80211: Rename struct bcm43xx_phyinfo to struct bcm43xx_phy
      bcm43xx-d80211: merge struct bcm43xx_radioinfo into struct bcm43xx_phy
      bcm43xx-d80211: Merge all "radio" stuff into phy.c
      Merge branch 'master' of git://kernel.org/.../linville/wireless-dev
      bcm43xx-d80211: Drain TXstatus queue before enabling IRQs.
      bcm43xx-d80211: Fix antenna selection for TX and RX.
      bcm43xx-d80211: Fix bogus LO validation failure.
      bcm43xx-d80211: Remove netpoll and ethtool stuff.
      Merge branch 'master' of git://kernel.org/.../linville/wireless-dev
      Merge branch 'master' of git://kernel.org/.../linville/wireless-dev
      Merge branch 'master' of git://kernel.org/.../linville/wireless-dev
      Merge branch 'master' of git://zeus2.kernel.org/.../linville/wireless-dev
      Remove obsolete SSB driver library.
      Implement new SSB subsystem.
      bcm43xx-d80211: Port driver to the new SSB subsystem.
      bcm43xx-d80211: Fix LO feedthrough measurement.
      ssb: Fix dependencies. MIPS core must depend on MIPS platform.
      ssb: Fix typo. SSB_PCICORE_SBTOPCI1_CFG1 does not exist.
      ssb, bcm43xx-d80211: Move DMA translation logic to ssb.
      bcm43xx-d80211: Remove bogus call to refresh_templates in add_interface.
      ssb, bcm43xx-d80211: Add function to set DMA mask on SSB.
      ssb: Fix busnumber assignment. Must assign it before scanning the bus.
      ssb: Allow disabling of all PCI related stuff.
      ssb: PCMCIA-hostbus support.
      bcm43xx-d80211: Support for PCMCIA devices.
      bcm43xx-d80211: re-add chipid printk
      bcm43xx-d80211: Remove leds_exit() call in detach stage.
      bcm43xx-d80211: Get rid of "PHY-connected" semantics.
      bcm43xx-d80211: Fix wrong register write in lo_measure_feedthrough().
      bcm43xx-d80211: Fix error return codes.
      bcm43xx-d80211: Various cleanups all over the code.
      bcm43xx-d80211: Fix semantical errors in LO measure setup.
      bcm43xx-d80211: gphy init: Some cleanups and some bugfixes.
      ssb: Add missing include to delay.h in ssb/pcmcia.c
      ssb, usb: Implement SSB based Broadcom USB OHCI driver.
      ssb: PCIcore hostmode fixes.
      ssb: export ssb_clockspeed()
      ssb: add PM config register definitions
      ssb: b44 related fixes.
      bcm43xx-d80211: Fix initial LO Calibration.
      bcm43xx-d80211: Fix loopback gain calculation.
      bcm43xx-d80211: Fix DMA TX skb doublefree

Michael Wu (2):
      d80211: Only free WEP crypto ciphers when they have been allocated correctly.
      d80211: Fix __ieee80211_if_del on live interfaces

Pavel Roskin (1):
      bcm43xx_d80211: Fix major memory corruption bug

 drivers/Kconfig                                    |    2 +
 drivers/Makefile                                   |    1 +
 drivers/misc/Kconfig                               |    4 -
 drivers/misc/Makefile                              |    1 -
 drivers/misc/ssb.c                                 | 1074 -----
 drivers/net/wireless/d80211/bcm43xx/Kconfig        |   40 +-
 drivers/net/wireless/d80211/bcm43xx/Makefile       |   11 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |  441 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c  |   72 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h  |   16 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |  197 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.h  |   48 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ilt.c  |  337 --
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ilt.h  |   32 -
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c |   89 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.h |   12 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_lo.c   | 1060 +++++
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_lo.h   |   91 +
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c | 3972 +++++++---------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h |   40 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pci.c  |  147 +
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pci.h  |   38 +
 .../net/wireless/d80211/bcm43xx/bcm43xx_pcmcia.c   |  155 +
 .../net/wireless/d80211/bcm43xx/bcm43xx_pcmcia.h   |   35 +
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c  | 5010 +++++++++++++-------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.h  |  326 ++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c  |  111 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h  |   34 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_power.c    |  307 +--
 .../net/wireless/d80211/bcm43xx/bcm43xx_power.h    |   25 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_radio.c    | 2033 --------
 .../net/wireless/d80211/bcm43xx/bcm43xx_radio.h    |  100 -
 .../net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c    |   66 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_sysfs.h    |    6 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_tables.c   |  376 ++
 .../net/wireless/d80211/bcm43xx/bcm43xx_tables.h   |   28 +
 .../net/wireless/d80211/bcm43xx/bcm43xx_vstack.c   |  202 +
 .../net/wireless/d80211/bcm43xx/bcm43xx_vstack.h   |   83 +
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |  215 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h |   83 +-
 drivers/net/wireless/d80211/rt2x00/Kconfig         |   17 -
 drivers/net/wireless/d80211/rt2x00/Makefile        |    2 -
 drivers/net/wireless/d80211/rt2x00/crc-itu-t.c     |   66 -
 drivers/net/wireless/d80211/rt2x00/crc-itu-t.h     |   27 -
 drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.c  |  189 -
 drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.h  |   90 -
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |    4 +-
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |    2 +-
 drivers/ssb/Kconfig                                |   93 +
 drivers/ssb/Makefile                               |   14 +
 drivers/ssb/core.c                                 |  805 ++++
 drivers/ssb/driver_chipcommon/chipcommon.c         |  403 ++
 drivers/ssb/driver_mips/mips.c                     |  258 +
 drivers/ssb/driver_pci/pcicore.c                   |  485 ++
 drivers/ssb/pci.c                                  |  480 ++
 drivers/ssb/pcmcia.c                               |  256 +
 drivers/ssb/scan.c                                 |  373 ++
 drivers/ssb/ssb_private.h                          |  143 +
 drivers/usb/host/Kconfig                           |   10 +
 drivers/usb/host/ohci-hcd.c                        |    5 +
 drivers/usb/host/ohci-ssb.c                        |  193 +
 include/linux/crc-itu-t.h                          |   27 +
 include/linux/eeprom_93cx6.h                       |   77 +
 include/linux/ssb.h                                |  617 ---
 include/linux/ssb/ssb.h                            |  358 ++
 include/linux/ssb/ssb_driver_chipcommon.h          |  387 ++
 include/linux/ssb/ssb_driver_extif.h               |  163 +
 include/linux/ssb/ssb_driver_mips.h                |   47 +
 include/linux/ssb/ssb_driver_pci.h                 |  108 +
 include/linux/ssb/ssb_regs.h                       |  293 ++
 lib/Kconfig                                        |   16 +
 lib/Makefile                                       |    3 +
 lib/crc-itu-t.c                                    |   64 +
 lib/eeprom_93cx6.c                                 |  343 ++
 net/d80211/Kconfig                                 |    1 +
 net/d80211/ieee80211.c                             |    4 +-
 net/d80211/ieee80211_i.h                           |   30 +-
 net/d80211/ieee80211_iface.c                       |    4 -
 net/d80211/ieee80211_ioctl.c                       |    4 +-
 net/d80211/sta_info.c                              |    2 +-
 82 files changed, 13769 insertions(+), 9618 deletions(-)
 delete mode 100644 drivers/misc/ssb.c
 delete mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ilt.c
 delete mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ilt.h
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_lo.c
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_lo.h
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pci.c
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pci.h
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pcmcia.c
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pcmcia.h
 delete mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
 delete mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.h
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_tables.c
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_tables.h
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_vstack.c
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_vstack.h
 delete mode 100644 drivers/net/wireless/d80211/rt2x00/crc-itu-t.c
 delete mode 100644 drivers/net/wireless/d80211/rt2x00/crc-itu-t.h
 delete mode 100644 drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.c
 delete mode 100644 drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.h
 create mode 100644 drivers/ssb/Kconfig
 create mode 100644 drivers/ssb/Makefile
 create mode 100644 drivers/ssb/core.c
 create mode 100644 drivers/ssb/driver_chipcommon/chipcommon.c
 create mode 100644 drivers/ssb/driver_mips/mips.c
 create mode 100644 drivers/ssb/driver_pci/pcicore.c
 create mode 100644 drivers/ssb/pci.c
 create mode 100644 drivers/ssb/pcmcia.c
 create mode 100644 drivers/ssb/scan.c
 create mode 100644 drivers/ssb/ssb_private.h
 create mode 100644 drivers/usb/host/ohci-ssb.c
 create mode 100644 include/linux/crc-itu-t.h
 create mode 100644 include/linux/eeprom_93cx6.h
 delete mode 100644 include/linux/ssb.h
 create mode 100644 include/linux/ssb/ssb.h
 create mode 100644 include/linux/ssb/ssb_driver_chipcommon.h
 create mode 100644 include/linux/ssb/ssb_driver_extif.h
 create mode 100644 include/linux/ssb/ssb_driver_mips.h
 create mode 100644 include/linux/ssb/ssb_driver_pci.h
 create mode 100644 include/linux/ssb/ssb_regs.h
 create mode 100644 lib/crc-itu-t.c
 create mode 100644 lib/eeprom_93cx6.c

Omnibus patch is too big for netdev, even when bzip2'ed...
-- 
John W. Linville
linville@tuxdriver.com
