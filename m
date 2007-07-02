From: Jeff Garzik <jeff@garzik.org>
Subject: [info] What's in netdev-2.6.git?
Date: Mon, 2 Jul 2007 11:08:26 -0400
Message-ID: <20070702150826.GA10610@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:48944 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbXGBPI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 11:08:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is what is currently queued for 2.6.23.  There are a few patches
in my mbox not yet applied to the git tree, but this is most of them.

The following is found in the 'upstream' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

Akinobu Mita (1):
      softmac: use list_for_each_entry

Bill Nottingham (1):
      drivers/net: fix comparisons of unsigned < 0

Daniel Drake (4):
      zd1211rw: Add ID for ZyXEL G-200v2
      zd1211rw: Extend RF layer
      zd1211rw: Add UW2453 RF support
      zd1211rw: Make CCK gain patching conditional on RF type

David Brownell (1):
      usbnet whitespace fixes

David S. Miller (1):
      r8169: kill eth_copy_and_sum()

Divy Le Ray (3):
      cxgb3 - sge page management
      cxgb3 - Firmware update
      cxgb3 - TP SRAM update

Francois Romieu (17):
      r8169: de-obfuscate modulo arithmetic
      r8169: add hooks for per-device hw_start handler
      r8169: add helpers for per-device hw_start handler
      r8169: populate the hw_start handler for the 8168
      r8169: populate the hw_start handler for the 8110
      r8169: prettify mac_version
      r8169: merge with version 6.001.00 of Realtek's r8169 driver
      r8169: merge with version 8.001.00 of Realtek's r8168 driver
      r8169: confusion between hardware and IP header alignment
      r8169: small 8101 comment
      r8169: remove the media option
      r8169: cleanup
      r8169: add bit description for the TxPoll register
      r8169: align the IP header when there is no DMA constraint
      r8169: display some extra debug information during startup
      r8169: mac address change support
      r8169: perform RX config change after mac filtering

Geert Uytterhoeven (1):
      acenic: SET_NETDEV_DEV is always there these days

Ivo van Doorn (2):
      Add 93cx6 eeprom library
      eeprom_93cx6: Add comment for 1us delay after pulse

Jan Engelhardt (1):
      Use menuconfig objects II - netdev (general+100mbit)

Jan-Bernd Themann (1):
      ehea: Whitespace cleanup

Jeff Garzik (2):
      Merge branch 'upstream-fixes' into upstream
      Merge branch 'upstream-fixes' into upstream

John W. Linville (2):
      eeprom_93cx6: shorten pulse timing to match spec
      rtl8187: add header blocks and indicate origin of magic values

Jouni Malinen (1):
      hostap: Remove driver version number

Kapil Juneja (2):
      gianfar: add support for SGMII
      phylib: m88e1111: enable SGMII mode

Komuro (1):
      PCMCIA-NETDEV : add new ID of lan&modem multifunction card

Larry Finger (1):
      bcm43xx: Fix deviation from specifications in set_baseband_attenuation

Linas Vepstas (10):
      s2io: add PCI error recovery support
      s2io: add PCI error recovery support
      spidernet: beautify error messages
      spidernet: enhance the dump routine
      spidernet: invalidate unused pointer.
      spidernet: service TX later.
      spidernet: move a block of code around
      spidernet: fix misnamed flag
      spidernet: driver docmentation
      spidernet: Replace literal with const

Matthias Kaehlcke (1):
      hostap: Use list_for_each_entry

Michael Barkowski (1):
      phylib: add the ICPlus IP175C PHY driver

Michael Wu (1):
      Add rtl8187 wireless driver

Olof Johansson (1):
      pasemi_mac: Fix TX interrupt threshold

Pavel Roskin (1):
      hostap: Suppress broadcast if no stations are associated

Richard Knutsson (2):
      8139cp: Convert to generic boolean
      tulip: Convert to generic boolean

Rolf Eike Beer (1):
      r8169: add endianess annotations to [RT]xDesc

Stephen Hemminger (14):
      b44: timer power saving
      b44: tx bounce sizing.
      b44: packet offset is constant
      b44: use netdev_alloc_skb
      qla3xxx: cleanup checksum offload code
      sky2: avoid reserved regions on ethtool reg dump
      sky2: Add PCI device specfic register 4 & 5
      sky2: rename BMU register
      sky2: enable clocks before probe
      sky2: GPIO register
      sky2: Yukon Extreme (88e8071) support.
      sky2: version 1.15
      r8169: use netdev_alloc_skb
      r8169: Rx path update

Thomas Bogendoerfer (2):
      Extract chip specific code out of lasi_82596.c
      Ethernet driver for EISA only SNI RM200/RM400 machines

Yoichi Yuasa (1):
      add return value check of request_irq()

 Documentation/networking/spider_net.txt         |  204 +++
 MAINTAINERS                                     |   10 
 drivers/misc/Kconfig                            |    5 
 drivers/misc/Makefile                           |    1 
 drivers/misc/eeprom_93cx6.c                     |  241 +++
 drivers/net/8139cp.c                            |   11 
 drivers/net/Kconfig                             |  172 +-
 drivers/net/Makefile                            |    1 
 drivers/net/acenic.c                            |    4 
 drivers/net/arm/Kconfig                         |   12 
 drivers/net/b44.c                               |   56 
 drivers/net/b44.h                               |    2 
 drivers/net/cxgb3/adapter.h                     |   38 
 drivers/net/cxgb3/common.h                      |   28 
 drivers/net/cxgb3/cxgb3_main.c                  |   43 
 drivers/net/cxgb3/regs.h                        |   11 
 drivers/net/cxgb3/sge.c                         |  423 +++---
 drivers/net/cxgb3/t3_hw.c                       |  128 +-
 drivers/net/cxgb3/version.h                     |    2 
 drivers/net/ehea/ehea.h                         |   14 
 drivers/net/ehea/ehea_hw.h                      |   24 
 drivers/net/ehea/ehea_main.c                    |   32 
 drivers/net/ehea/ehea_qmr.c                     |   56 
 drivers/net/fec_8xx/Kconfig                     |    2 
 drivers/net/fs_enet/Kconfig                     |    2 
 drivers/net/gianfar.c                           |   27 
 drivers/net/gianfar.h                           |    6 
 drivers/net/gianfar_mii.c                       |   55 
 drivers/net/lasi_82596.c                        | 1460 ------------------------
 drivers/net/lib82596.c                          | 1434 +++++++++++++++++++++++
 drivers/net/mlx4/qp.c                           |    3 
 drivers/net/netxen/netxen_nic_niu.c             |    6 
 drivers/net/pasemi_mac.c                        |    2 
 drivers/net/pcmcia/3c589_cs.c                   |    2 
 drivers/net/pcmcia/axnet_cs.c                   |    7 
 drivers/net/pcmcia/fmvj18x_cs.c                 |   23 
 drivers/net/pcmcia/pcnet_cs.c                   |   10 
 drivers/net/phy/Kconfig                         |    5 
 drivers/net/phy/Makefile                        |    1 
 drivers/net/phy/icplus.c                        |  134 ++
 drivers/net/phy/marvell.c                       |   16 
 drivers/net/qla3xxx.c                           |   33 
 drivers/net/r8169.c                             |  944 ++++++++-------
 drivers/net/s2io.c                              |  116 +
 drivers/net/s2io.h                              |    6 
 drivers/net/sky2.c                              |  224 ++-
 drivers/net/sky2.h                              |  163 ++
 drivers/net/sni_82596.c                         |  185 +++
 drivers/net/spider_net.c                        |  184 ++-
 drivers/net/spider_net.h                        |   21 
 drivers/net/tulip/Kconfig                       |   27 
 drivers/net/tulip/de2104x.c                     |    1 
 drivers/net/tulip/de4x5.c                       |   98 -
 drivers/net/tulip/de4x5.h                       |    9 
 drivers/net/usb/usbnet.c                        |   76 -
 drivers/net/usb/usbnet.h                        |   10 
 drivers/net/wireless/Kconfig                    |   12 
 drivers/net/wireless/Makefile                   |    3 
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c      |    2 
 drivers/net/wireless/hostap/hostap_ap.c         |   34 
 drivers/net/wireless/hostap/hostap_config.h     |    2 
 drivers/net/wireless/hostap/hostap_cs.c         |    4 
 drivers/net/wireless/hostap/hostap_ioctl.c      |    2 
 drivers/net/wireless/hostap/hostap_main.c       |    1 
 drivers/net/wireless/hostap/hostap_pci.c        |    5 
 drivers/net/wireless/hostap/hostap_plx.c        |    5 
 drivers/net/wireless/rtl8187.h                  |  145 ++
 drivers/net/wireless/rtl8187_dev.c              |  731 ++++++++++++
 drivers/net/wireless/rtl8187_rtl8225.c          |  745 ++++++++++++
 drivers/net/wireless/rtl8187_rtl8225.h          |   44 
 drivers/net/wireless/rtl818x.h                  |  226 +++
 drivers/net/wireless/zd1211rw/Makefile          |    2 
 drivers/net/wireless/zd1211rw/zd_chip.c         |    5 
 drivers/net/wireless/zd1211rw/zd_chip.h         |    3 
 drivers/net/wireless/zd1211rw/zd_rf.c           |   21 
 drivers/net/wireless/zd1211rw/zd_rf.h           |   28 
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c    |    1 
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c   |    1 
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c    |  534 ++++++++
 drivers/net/wireless/zd1211rw/zd_usb.c          |    1 
 drivers/serial/serial_cs.c                      |    4 
 include/linux/eeprom_93cx6.h                    |   72 +
 include/pcmcia/ciscode.h                        |    2 
 net/ieee80211/softmac/ieee80211softmac_module.c |   32 
 84 files changed, 6794 insertions(+), 2683 deletions(-)
