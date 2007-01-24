From: Jeff Garzik <jeff@garzik.org>
Subject: What's in netdev-2.6.git
Date: Wed, 24 Jan 2007 02:27:52 -0500
Message-ID: <20070124072752.GA32453@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:55424 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933173AbXAXH1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 02:27:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the stuff queued for 2.6.21 in netdev-2.6.git#upstream.

Nothing earthshakingly notable.  A couple new drivers, a couple removed
drivers, a bunch of driver updates.

Adrian Bunk (4):
      remove the broken SKMC driver
      make hdlc_setup() static again
      remove the broken OAKNET driver
      bonding.h: "extern inline" -> "static inline"

Akinobu Mita (1):
      net: use bitrev8

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

Divy Le Ray (1):
      Add support for the latest 1G/10G Chelsio adapter, T3.

Francois Romieu (7):
      chelsio: move return, break and continue statements on their own line
      chelsio: the return statement is not a function
      chelsio: spaces, tabs and friends
      chelsio: useless curly braces
      chelsio: useless test in cxgb2::remove_one
      chelsio: misc cleanups in sge
      chelsio: tabulate the update of the statistic counters

Jay Vosburgh (4):
      bonding: fix device name allocation error
      bonding: fix error check in sysfs creation
      bonding: modify sysfs support to permit multiple loads
      bonding: update version

Jeff Garzik (3):
      Merge branch 'upstream-fixes' into upstream
      Merge branch 'master-e1000' of git://lost.foo-projects.org/~ahkok/git/netdev-2.6 into upstream
      Merge branch 'upstream-fixes' into upstream

Jesse Brandeburg (4):
      e1000: simplify case handling gigabit at half duplex
      e1000: Fix MSI only interrupt handler routine
      e1000: fix NAPI performance on 4-port adapters
      e1000: tune our dynamic itr transmit packet accounting

John W. Linville (1):
      softmac: avoid assert in ieee80211softmac_wx_get_rate

Kai Engert (1):
      prism54: add ethtool -i interface

Larry Finger (1):
      bcm43xx: Interrogate hardware-enable switch and update LEDs

Linas Vepstas (13):
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

Michael Buesch (1):
      Update Prism54 MAINTAINERS entry

Ron Mercer (1):
      qla3xxx: Add support for Qlogic 4032 chip.

Stephen Hemminger (3):
      sky2: better power state management
      chelsio: NAPI speed improvement
      chelsio: more rx speedup

Zhu Yi (1):
      ipw2200: add iwconfig rts/frag auto support

 MAINTAINERS                                   |    2 
 drivers/net/Kconfig                           |   56 
 drivers/net/Makefile                          |    5 
 drivers/net/Space.c                           |    4 
 drivers/net/bmac.c                            |   20 
 drivers/net/bnx2.c                            |   12 
 drivers/net/bonding/bond_main.c               |   23 
 drivers/net/bonding/bond_sysfs.c              |   15 
 drivers/net/bonding/bonding.h                 |    9 
 drivers/net/chelsio/common.h                  |    2 
 drivers/net/chelsio/cpl5_cmd.h                |   18 
 drivers/net/chelsio/cxgb2.c                   |  149 -
 drivers/net/chelsio/elmer0.h                  |   40 
 drivers/net/chelsio/espi.c                    |   44 
 drivers/net/chelsio/fpga_defs.h               |    6 
 drivers/net/chelsio/gmac.h                    |   11 
 drivers/net/chelsio/ixf1010.c                 |  100 
 drivers/net/chelsio/mv88e1xxx.c               |   27 
 drivers/net/chelsio/my3126.c                  |   16 
 drivers/net/chelsio/pm3393.c                  |   91 
 drivers/net/chelsio/sge.c                     |  328 +-
 drivers/net/chelsio/subr.c                    |   89 
 drivers/net/chelsio/tp.c                      |   62 
 drivers/net/chelsio/vsc7326.c                 |  139 -
 drivers/net/chelsio/vsc7326_reg.h             |  139 -
 drivers/net/chelsio/vsc8244.c                 |   41 
 drivers/net/cxgb3/Makefile                    |    8 
 drivers/net/cxgb3/adapter.h                   |  255 +
 drivers/net/cxgb3/ael1002.c                   |  231 +
 drivers/net/cxgb3/common.h                    |  709 +++++
 drivers/net/cxgb3/cxgb3_ctl_defs.h            |  142 +
 drivers/net/cxgb3/cxgb3_defs.h                |   99 
 drivers/net/cxgb3/cxgb3_ioctl.h               |  165 +
 drivers/net/cxgb3/cxgb3_main.c                | 2474 +++++++++++++++++++
 drivers/net/cxgb3/cxgb3_offload.c             | 1222 +++++++++
 drivers/net/cxgb3/cxgb3_offload.h             |  193 +
 drivers/net/cxgb3/firmware_exports.h          |  144 +
 drivers/net/cxgb3/l2t.c                       |  450 +++
 drivers/net/cxgb3/l2t.h                       |  143 +
 drivers/net/cxgb3/mc5.c                       |  453 +++
 drivers/net/cxgb3/regs.h                      | 2195 +++++++++++++++++
 drivers/net/cxgb3/sge.c                       | 2702 ++++++++++++++++++++
 drivers/net/cxgb3/sge_defs.h                  |  251 +
 drivers/net/cxgb3/t3_cpl.h                    | 1426 +++++++++++
 drivers/net/cxgb3/t3_hw.c                     | 3354 ++++++++++++++++++++++++++
 drivers/net/cxgb3/t3cdev.h                    |   72 
 drivers/net/cxgb3/version.h                   |   24 
 drivers/net/cxgb3/vsc8211.c                   |  208 +
 drivers/net/cxgb3/xgmac.c                     |  389 +++
 drivers/net/e1000/e1000.h                     |    7 
 drivers/net/e1000/e1000_ethtool.c             |    6 
 drivers/net/e1000/e1000_main.c                |  128 
 drivers/net/e1000/e1000_osdep.h               |    4 
 drivers/net/e1000/e1000_param.c               |   15 
 drivers/net/forcedeth.c                       | 1342 ++++++----
 drivers/net/ixgb/ixgb.h                       |    2 
 drivers/net/ixgb/ixgb_ethtool.c               |    6 
 drivers/net/ixgb/ixgb_main.c                  |    4 
 drivers/net/mace.c                            |   16 
 drivers/net/macmace.c                         |   18 
 drivers/net/macsonic.c                        |    6 
 drivers/net/myri10ge/myri10ge.c               |   10 
 drivers/net/oaknet.c                          |  666 -----
 drivers/net/qla3xxx.c                         |  363 ++
 drivers/net/qla3xxx.h                         |   88 
 drivers/net/s2io.c                            |    8 
 drivers/net/sc92031.c                         | 1620 ++++++++++++
 drivers/net/sk_mca.c                          | 1216 ---------
 drivers/net/sk_mca.h                          |  170 -
 drivers/net/skfp/can.c                        |   83 
 drivers/net/skfp/drvfbi.c                     |   24 
 drivers/net/skfp/fplustm.c                    |    4 
 drivers/net/skfp/smt.c                        |   10 
 drivers/net/sky2.c                            |  140 -
 drivers/net/sky2.h                            |    1 
 drivers/net/spider_net.c                      |  311 +-
 drivers/net/spider_net.h                      |   20 
 drivers/net/spider_net_ethtool.c              |    4 
 drivers/net/tg3.c                             |   32 
 drivers/net/wan/hdlc.c                        |    3 
 drivers/net/wireless/bcm43xx/bcm43xx.h        |    7 
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c   |   11 
 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |   36 
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c  |    2 
 drivers/net/wireless/bcm43xx/bcm43xx_radio.h  |   16 
 drivers/net/wireless/ipw2200.c                |    4 
 drivers/net/wireless/prism54/islpci_dev.c     |   13 
 drivers/net/wireless/prism54/islpci_dev.h     |    4 
 drivers/net/wireless/prism54/islpci_hotplug.c |    3 
 drivers/net/wireless/zd1211rw/zd_chip.c       |  126 
 drivers/net/wireless/zd1211rw/zd_chip.h       |  158 -
 drivers/net/wireless/zd1211rw/zd_def.h        |    2 
 drivers/net/wireless/zd1211rw/zd_ieee80211.h  |    1 
 drivers/net/wireless/zd1211rw/zd_rf.h         |    2 
 drivers/net/wireless/zd1211rw/zd_types.h      |   71 
 drivers/net/wireless/zd1211rw/zd_usb.c        |  128 
 drivers/net/wireless/zd1211rw/zd_usb.h        |    6 
 net/ieee80211/softmac/ieee80211softmac_wx.c   |    6 
 98 files changed, 21481 insertions(+), 4199 deletions(-)
