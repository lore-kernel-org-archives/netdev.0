From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Wed, 7 Feb 2007 19:29:59 -0500
Message-ID: <20070208002959.GA29961@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33194 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422832AbXBHAaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 19:30:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Just sent this upstream...

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upst=
ream-linus

to receive the following updates:

 Documentation/feature-removal-schedule.txt    |    7 +
 MAINTAINERS                                   |   18 +-
 drivers/net/3c59x.c                           |    3 +-
 drivers/net/Kconfig                           |   65 +-
 drivers/net/Makefile                          |    6 +-
 drivers/net/Space.c                           |    4 -
 drivers/net/amd8111e.c                        |    3 +-
 drivers/net/b44.c                             |    8 +-
 drivers/net/b44.h                             |   10 +-
 drivers/net/bmac.c                            |   20 +-
 drivers/net/bnx2.c                            |   13 +-
 drivers/net/bonding/bond_main.c               |   23 +-
 drivers/net/bonding/bond_sysfs.c              |   15 +
 drivers/net/bonding/bonding.h                 |    9 +-
 drivers/net/chelsio/common.h                  |    2 +-
 drivers/net/chelsio/cpl5_cmd.h                |   18 +-
 drivers/net/chelsio/cxgb2.c                   |  149 +-
 drivers/net/chelsio/elmer0.h                  |   40 +-
 drivers/net/chelsio/espi.c                    |   44 +-
 drivers/net/chelsio/fpga_defs.h               |    6 +-
 drivers/net/chelsio/gmac.h                    |   11 +-
 drivers/net/chelsio/ixf1010.c                 |  100 +-
 drivers/net/chelsio/mv88e1xxx.c               |   27 +-
 drivers/net/chelsio/my3126.c                  |   16 +-
 drivers/net/chelsio/pm3393.c                  |   91 +-
 drivers/net/chelsio/sge.c                     |  328 ++--
 drivers/net/chelsio/subr.c                    |   89 +-
 drivers/net/chelsio/tp.c                      |   62 +-
 drivers/net/chelsio/vsc7326.c                 |  139 +-
 drivers/net/chelsio/vsc7326_reg.h             |  139 +-
 drivers/net/chelsio/vsc8244.c                 |   41 +-
 drivers/net/cxgb3/Makefile                    |    8 +
 drivers/net/cxgb3/adapter.h                   |  279 ++
 drivers/net/cxgb3/ael1002.c                   |  251 ++
 drivers/net/cxgb3/common.h                    |  729 ++++++
 drivers/net/cxgb3/cxgb3_ctl_defs.h            |  164 ++
 drivers/net/cxgb3/cxgb3_defs.h                |   99 +
 drivers/net/cxgb3/cxgb3_ioctl.h               |  185 ++
 drivers/net/cxgb3/cxgb3_main.c                | 2515 +++++++++++++++++=
+
 drivers/net/cxgb3/cxgb3_offload.c             | 1222 +++++++++
 drivers/net/cxgb3/cxgb3_offload.h             |  193 ++
 drivers/net/cxgb3/firmware_exports.h          |  177 ++
 drivers/net/cxgb3/l2t.c                       |  450 ++++
 drivers/net/cxgb3/l2t.h                       |  143 ++
 drivers/net/cxgb3/mc5.c                       |  473 ++++
 drivers/net/cxgb3/regs.h                      | 2195 ++++++++++++++++
 drivers/net/cxgb3/sge.c                       | 2681 +++++++++++++++++=
+++
 drivers/net/cxgb3/sge_defs.h                  |  251 ++
 drivers/net/cxgb3/t3_cpl.h                    | 1444 +++++++++++
 drivers/net/cxgb3/t3_hw.c                     | 3375 +++++++++++++++++=
++++++++
 drivers/net/cxgb3/t3cdev.h                    |   73 +
 drivers/net/cxgb3/version.h                   |   39 +
 drivers/net/cxgb3/vsc8211.c                   |  228 ++
 drivers/net/cxgb3/xgmac.c                     |  409 +++
 drivers/net/declance.c                        |  164 +-
 drivers/net/e1000/e1000.h                     |    7 -
 drivers/net/e1000/e1000_ethtool.c             |    6 -
 drivers/net/e1000/e1000_main.c                |  128 +-
 drivers/net/e1000/e1000_osdep.h               |    4 +-
 drivers/net/e1000/e1000_param.c               |   15 +-
 drivers/net/forcedeth.c                       | 1342 +++++++----
 drivers/net/hp100.c                           |    2 +-
 drivers/net/ixgb/ixgb.h                       |    2 -
 drivers/net/ixgb/ixgb_ethtool.c               |    6 -
 drivers/net/ixgb/ixgb_main.c                  |    4 -
 drivers/net/macb.c                            |   25 +-
 drivers/net/macb.h                            |    8 +-
 drivers/net/mace.c                            |   16 +-
 drivers/net/macmace.c                         |   18 +-
 drivers/net/macsonic.c                        |    6 +-
 drivers/net/myri10ge/myri10ge.c               |   10 -
 drivers/net/netxen/netxen_nic.h               |   17 +-
 drivers/net/netxen/netxen_nic_ethtool.c       |   96 +-
 drivers/net/netxen/netxen_nic_init.c          |  279 ++-
 drivers/net/oaknet.c                          |  666 -----
 drivers/net/pasemi_mac.c                      | 1019 ++++++++
 drivers/net/pasemi_mac.h                      |  460 ++++
 drivers/net/qla3xxx.c                         |  363 +++-
 drivers/net/qla3xxx.h                         |   88 +-
 drivers/net/s2io-regs.h                       |    7 +-
 drivers/net/s2io.c                            | 1178 +++++-----
 drivers/net/s2io.h                            |  223 +-
 drivers/net/sc92031.c                         | 1620 ++++++++++++
 drivers/net/sk_mca.c                          | 1216 ---------
 drivers/net/sk_mca.h                          |  170 --
 drivers/net/skfp/can.c                        |   83 -
 drivers/net/skfp/drvfbi.c                     |   24 +-
 drivers/net/skfp/fplustm.c                    |    4 +-
 drivers/net/skfp/smt.c                        |   10 +-
 drivers/net/skge.c                            |  235 ++-
 drivers/net/skge.h                            |    2 +
 drivers/net/sky2.c                            |  543 +++--
 drivers/net/sky2.h                            |   85 +-
 drivers/net/spider_net.c                      |  313 ++--
 drivers/net/spider_net.h                      |   20 +-
 drivers/net/spider_net_ethtool.c              |    4 +-
 drivers/net/tg3.c                             |   32 -
 drivers/net/ucc_geth.c                        |   23 +-
 drivers/net/wan/Kconfig                       |   24 +-
 drivers/net/wan/Makefile                      |    1 +
 drivers/net/wan/hdlc.c                        |    3 +-
 drivers/net/wan/pc300too.c                    |  565 +++++
 drivers/net/wan/z85230.c                      |   14 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h        |    7 +-
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c   |   11 +-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |   36 +-
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c  |    2 +
 drivers/net/wireless/bcm43xx/bcm43xx_radio.h  |   16 +
 drivers/net/wireless/ipw2200.c                |    4 +-
 drivers/net/wireless/orinoco.c                |    2 +-
 drivers/net/wireless/prism54/islpci_dev.c     |   13 +
 drivers/net/wireless/prism54/islpci_dev.h     |    4 +
 drivers/net/wireless/prism54/islpci_hotplug.c |    3 -
 drivers/net/wireless/zd1211rw/zd_chip.c       |  126 +-
 drivers/net/wireless/zd1211rw/zd_chip.h       |  158 +-
 drivers/net/wireless/zd1211rw/zd_def.h        |    2 +
 drivers/net/wireless/zd1211rw/zd_ieee80211.h  |    1 -
 drivers/net/wireless/zd1211rw/zd_rf.h         |    2 -
 drivers/net/wireless/zd1211rw/zd_types.h      |   71 -
 drivers/net/wireless/zd1211rw/zd_usb.c        |  128 +-
 drivers/net/wireless/zd1211rw/zd_usb.h        |    6 +-
 drivers/usb/net/asix.c                        |    4 +
 drivers/usb/net/pegasus.h                     |    4 +-
 include/linux/pci_ids.h                       |    2 +
 net/ieee80211/softmac/ieee80211softmac_wx.c   |    6 +
 125 files changed, 25584 insertions(+), 5263 deletions(-)
 create mode 100644 drivers/net/cxgb3/Makefile
 create mode 100644 drivers/net/cxgb3/adapter.h
 create mode 100644 drivers/net/cxgb3/ael1002.c
 create mode 100644 drivers/net/cxgb3/common.h
 create mode 100644 drivers/net/cxgb3/cxgb3_ctl_defs.h
 create mode 100644 drivers/net/cxgb3/cxgb3_defs.h
 create mode 100644 drivers/net/cxgb3/cxgb3_ioctl.h
 create mode 100644 drivers/net/cxgb3/cxgb3_main.c
 create mode 100644 drivers/net/cxgb3/cxgb3_offload.c
 create mode 100644 drivers/net/cxgb3/cxgb3_offload.h
 create mode 100644 drivers/net/cxgb3/firmware_exports.h
 create mode 100644 drivers/net/cxgb3/l2t.c
 create mode 100644 drivers/net/cxgb3/l2t.h
 create mode 100644 drivers/net/cxgb3/mc5.c
 create mode 100644 drivers/net/cxgb3/regs.h
 create mode 100644 drivers/net/cxgb3/sge.c
 create mode 100644 drivers/net/cxgb3/sge_defs.h
 create mode 100644 drivers/net/cxgb3/t3_cpl.h
 create mode 100644 drivers/net/cxgb3/t3_hw.c
 create mode 100644 drivers/net/cxgb3/t3cdev.h
 create mode 100644 drivers/net/cxgb3/version.h
 create mode 100644 drivers/net/cxgb3/vsc8211.c
 create mode 100644 drivers/net/cxgb3/xgmac.c
 delete mode 100644 drivers/net/oaknet.c
 create mode 100644 drivers/net/pasemi_mac.c
 create mode 100644 drivers/net/pasemi_mac.h
 mode change 100644 =3D> 100755 drivers/net/qla3xxx.c
 mode change 100644 =3D> 100755 drivers/net/qla3xxx.h
 create mode 100644 drivers/net/sc92031.c
 delete mode 100644 drivers/net/sk_mca.c
 delete mode 100644 drivers/net/sk_mca.h
 delete mode 100644 drivers/net/skfp/can.c
 create mode 100644 drivers/net/wan/pc300too.c
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_types.h

Adrian Bunk (5):
      remove the broken SKMC driver
      make hdlc_setup() static again
      remove the broken OAKNET driver
      bonding.h: "extern inline" -> "static inline"
      remove one remaining "#define BCM_TSO 1"

Ahmed S. Darwish (1):
      UCC Ether driver: kmalloc casting cleanups

Akinobu Mita (1):
      net: use bitrev8

Al Viro (1):
      b44 endian annotations

Alan Cox (1):
      z85230: spinlock logic

Amit S. Kale (2):
      NetXen: Firmware crb init changes.
      NetXen: Added ethtool support for user level tools.

Andrew Morton (1):
      git-netdev-all: chelsio fix

Andrew Victor (1):
      AT91: MACB support

Arjan van de Ven (1):
      remove NETIF_F_TSO ifdefery

Auke Kok (3):
      e1000: clean up debug output defines
      e1000: display flow control of link status at link up
      e1000: update version to 7.3.20-k2

Ayaz Abdulla (12):
      forcedeth: dma access
      forcedeth: ring access
      forcedeth: tx locking
      forcedeth: rx skb recycle
      forcedeth: optimized routines
      forcedeth: tx limiting
      forcedeth: tx data path optimization
      forcedeth: rx data path optimization
      forcedeth: irq data path optimization
      forcedeth: tx max work
      forcedeth: statistics supported
      forcedeth: statistics optimization

Bruce Allan (1):
      e1000: clear ip csum info from context descriptor

Cesar Eduardo Barros (1):
      driver for Silan SC92031 netdev

Daniel Drake (6):
      zd1211rw: Generic HMAC initialization
      zd1211rw: 2 new ZD1211B device ID's
      zd1211rw: Consistency for address space constants
      zd1211rw: Remove addressing abstraction
      zd1211rw: Add ID for Linksys WUSBF54G
      zd1211rw: Add ID for ZyXEL ZyAIR G-220 v2

Divy Le Ray (10):
      Add support for the latest 1G/10G Chelsio adapter, T3.
      cxgb3 - FW versioning
      cxgb3 - bind qsets on multiport adapter
      cxgb3 - remove SW Tx credits coalescing
      cxgb3 - bogus status error string
      cxgb3 - Clean up HW init routine
      cxgb3 - white space to tabs
      cxgb3 - Remove BUG_ON from t3b_intr_napi
      cxgb3 - Add <linux/mutex.h>
      cxgb3 - Add dual licensing

=46rancois Romieu (7):
      chelsio: move return, break and continue statements on their own =
line
      chelsio: the return statement is not a function
      chelsio: spaces, tabs and friends
      chelsio: useless curly braces
      chelsio: useless test in cxgb2::remove_one
      chelsio: misc cleanups in sge
      chelsio: tabulate the update of the statistic counters

Hennerich, Michael (1):
      fix unaligned exception in /drivers/net/wireless/orinoco.c

Jay Cliburn (1):
      maintainers: add atl1 maintainers

Jay Vosburgh (4):
      bonding: fix device name allocation error
      bonding: fix error check in sysfs creation
      bonding: modify sysfs support to permit multiple loads
      bonding: update version

Jesse Brandeburg (4):
      e1000: simplify case handling gigabit at half duplex
      e1000: Fix MSI only interrupt handler routine
      e1000: fix NAPI performance on 4-port adapters
      e1000: tune our dynamic itr transmit packet accounting

Jiri Kosina (2):
      NET-3c59x: turn local_save_flags() + local_irq_disable() into loc=
al_irq_save()
      NET: turn local_save_flags() + local_irq_disable() into local_irq=
_save()

John W. Linville (1):
      softmac: avoid assert in ieee80211softmac_wx_get_rate

Kai Engert (1):
      prism54: add ethtool -i interface

Krzysztof Halasa (1):
      PC300too alternative WAN driver

Larry Finger (1):
      bcm43xx: Interrogate hardware-enable switch and update LEDs

Linas Vepstas (14):
      Spidernet DMA coalescing
      Spidernet add net_ratelimit to suppress long output
      Spidernet remove rxramfull tasklet
      Spidernet cleanup un-needed API
      Spidernet RX skb mem leak
      Spidernet another skb mem leak
      Spidernet Cleanup return codes
      Spidernet RX Refill
      Spidernet Remove unused variable
      Spidernet RX Chain tail
      Spidernet Memory barrier
      Spidernet Avoid possible RX chain corruption
      Spidernet RX Debugging printout
      Spidernet: Rework RX linked list

Maciej W. Rozycki (1):
      mips: declance: Driver model for the PMAD-A

Michael Buesch (1):
      Update Prism54 MAINTAINERS entry

Olof Johansson (1):
      PA Semi PWRficient Ethernet driver

Ralf Baechle (1):
      s2io: De-typedef driver.

Richard Knutsson (1):
      hp100: convert pci_module_init() to pci_register_driver()

Robert P. J. Day (1):
      Remove unused kernel config option DLCI_COUNT

Ron Mercer (1):
      qla3xxx: Add support for Qlogic 4032 chip.

shemminger@linux-foundation.org (3):
      sky2: version 1.11.1
      sky2: software rx/tx stats
      sky2: handle network device allocation failure

Sivakumar Subramani (4):
      s2io: Making LRO and UFO as module loadable parameter.
      S2IO: Fixes for reset and link handling.
      s2io: Fixes in updating skb->truesize and code cleanup.
      s2io: Removed enabling of some of the unused interrupts.

Stephen Hemminger (15):
      sky2: better power state management
      chelsio: NAPI speed improvement
      chelsio: more rx speedup
      skge: handle zero address at open
      skge: use dev_printk
      skge: WOL support
      skge: version 1.10
      sky2: add Wake On Lan support
      sky2: use dev_err for error reports
      sky2: TSO support for EC_U
      sky2: safer transmit timeout
      sky2: Yukon Extreme support
      sky2: add new chip ids
      sky2: version 1.12
      sk98lin: planned removal

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (2):
      ASIX: Add IO-DATA ETG-US2 Support.
      PEGASUS: Fix typo in Corega products.

Zhu Yi (1):
      ipw2200: add iwconfig rts/frag auto support


