From: Jeff Garzik <jeff@garzik.org>
Subject: What's in netdev-2.6.git? (and, netdev rebased)
Date: Sat, 28 Apr 2007 11:49:02 -0400
Message-ID: <20070428154902.GA12530@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39757 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbXD1PtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:49:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is what is queued for Linus, for sending upstream tomorrow
(most likely).

Wireless guys, in particular, I would appreciate a quick verify and
retest, to make sure a rebase merge went correctly.

As of this moment, I just rebased netdev (something I try to
do infrequently).  There are now only three branches of note at
netdev-2.6.git, and only one content branch:

	upstream	Queued for 2.6.22 upstream

	master		Vanilla upstream
	ALL		Queued for public testing (-mm uses this)

Branch 'ALL' is currently equivalent to 'upstream'.


(shortlog follows diffstat)

 Documentation/DocBook/kernel-api.tmpl          |    6 +
 Documentation/networking/bcm43xx.txt           |   97 +-
 MAINTAINERS                                    |   20 +-
 arch/mips/mips-boards/sim/Makefile             |    3 +-
 arch/mips/mips-boards/sim/sim_platform.c       |   35 +
 arch/powerpc/sysdev/qe_lib/ucc_fast.c          |    3 +
 crypto/michael_mic.c                           |    4 +-
 drivers/net/3c509.c                            |    1 -
 drivers/net/Kconfig                            |   15 +-
 drivers/net/Makefile                           |    2 +-
 drivers/net/chelsio/Makefile                   |    4 +-
 drivers/net/chelsio/common.h                   |    6 +-
 drivers/net/chelsio/cphy.h                     |   16 +-
 drivers/net/chelsio/gmac.h                     |   10 +-
 drivers/net/chelsio/ixf1010.c                  |  505 -----
 drivers/net/chelsio/mac.c                      |    2 +-
 drivers/net/chelsio/mv88e1xxx.c                |    8 +-
 drivers/net/chelsio/mv88x201x.c                |    8 +-
 drivers/net/chelsio/my3126.c                   |    8 +-
 drivers/net/chelsio/pm3393.c                   |    8 +-
 drivers/net/chelsio/subr.c                     |  199 ++-
 drivers/net/chelsio/vsc7326.c                  |    2 +-
 drivers/net/chelsio/vsc8244.c                  |  367 ----
 drivers/net/chelsio/vsc8244_reg.h              |  172 --
 drivers/net/e100.c                             |  159 +-
 drivers/net/e1000/e1000.h                      |    3 -
 drivers/net/e1000/e1000_ethtool.c              |   34 +-
 drivers/net/e1000/e1000_main.c                 |   45 +-
 drivers/net/e1000/e1000_param.c                |    4 +-
 drivers/net/eexpress.c                         |    9 +-
 drivers/net/ehea/ehea.h                        |   42 +-
 drivers/net/ehea/ehea_ethtool.c                |  115 +-
 drivers/net/ehea/ehea_main.c                   |  940 +++++---
 drivers/net/ehea/ehea_phyp.c                   |    6 +-
 drivers/net/ehea/ehea_phyp.h                   |    6 +-
 drivers/net/ehea/ehea_qmr.c                    |  184 ++-
 drivers/net/ehea/ehea_qmr.h                    |   16 +-
 drivers/net/hamradio/baycom_ser_fdx.c          |   13 +-
 drivers/net/ibmveth.c                          |   10 +-
 drivers/net/ixgb/ixgb.h                        |    3 -
 drivers/net/ixgb/ixgb_ethtool.c                |    4 +-
 drivers/net/ixgb/ixgb_main.c                   |    4 +-
 drivers/net/ixgb/ixgb_param.c                  |    8 +-
 drivers/net/mii.c                              |   57 +
 drivers/net/mipsnet.c                          |   53 +-
 drivers/net/mv643xx_eth.c                      |   59 +-
 drivers/net/mv643xx_eth.h                      |    4 -
 drivers/net/netxen/netxen_nic.h                |  189 +-
 drivers/net/netxen/netxen_nic_ethtool.c        |  212 ++-
 drivers/net/netxen/netxen_nic_hdr.h            |   12 +
 drivers/net/netxen/netxen_nic_hw.c             |  401 +++-
 drivers/net/netxen/netxen_nic_hw.h             |   85 +-
 drivers/net/netxen/netxen_nic_init.c           |  130 +-
 drivers/net/netxen/netxen_nic_isr.c            |  101 +-
 drivers/net/netxen/netxen_nic_main.c           |  769 ++++---
 drivers/net/netxen/netxen_nic_niu.c            |  168 +-
 drivers/net/netxen/netxen_nic_phan_reg.h       |  134 +-
 drivers/net/pcnet32.c                          |  159 +-
 drivers/net/phy/mdio_bus.c                     |   19 +-
 drivers/net/phy/phy.c                          |  194 ++-
 drivers/net/phy/phy_device.c                   |  114 +-
 drivers/net/qla3xxx.c                          |  371 +++-
 drivers/net/qla3xxx.h                          |   33 +-
 drivers/net/s2io-regs.h                        |    2 +-
 drivers/net/s2io.c                             |   78 +-
 drivers/net/s2io.h                             |    8 +-
 drivers/net/sb1250-mac.c                       |  294 ++-
 drivers/net/sgiseeq.c                          |   28 +-
 drivers/net/sk98lin/skge.c                     |   20 +-
 drivers/net/skfp/h/lnkstat.h                   |   84 -
 drivers/net/skge.c                             |   30 +-
 drivers/net/skge.h                             |   10 +-
 drivers/net/smc911x.c                          |    2 +-
 drivers/net/tc35815.c                          | 2554 ++++++++++++++++------
 drivers/net/tulip/dmfe.c                       |  118 +-
 drivers/net/tulip/interrupt.c                  |    4 +-
 drivers/net/tulip/media.c                      |   40 +-
 drivers/net/tulip/tulip.h                      |    9 +-
 drivers/net/tulip/tulip_core.c                 |    6 +-
 drivers/net/tulip/winbond-840.c                |    2 +-
 drivers/net/ucc_geth.c                         |  946 +++-----
 drivers/net/ucc_geth.h                         |  114 +-
 drivers/net/ucc_geth_mii.c                     |  279 +++
 drivers/net/ucc_geth_mii.h                     |  100 +
 drivers/net/ucc_geth_phy.c                     |  785 -------
 drivers/net/ucc_geth_phy.h                     |  217 --
 drivers/net/wan/hdlc_cisco.c                   |   29 +-
 drivers/net/wan/hdlc_fr.c                      |   18 +-
 drivers/net/wireless/Kconfig                   |   13 +
 drivers/net/wireless/Makefile                  |    1 +
 drivers/net/wireless/README                    |   25 -
 drivers/net/wireless/airo.c                    |   70 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h         |    3 +
 drivers/net/wireless/bcm43xx/bcm43xx_ethtool.c |    4 +-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c    |    4 +-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c     |   23 +-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.h     |    4 +
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c   |  196 ++-
 drivers/net/wireless/hostap/hostap_ap.c        |    4 +-
 drivers/net/wireless/hostap/hostap_common.h    |    4 +-
 drivers/net/wireless/hostap/hostap_cs.c        |    9 +-
 drivers/net/wireless/hostap/hostap_hw.c        |    4 +-
 drivers/net/wireless/hostap/hostap_main.c      |    4 +-
 drivers/net/wireless/hostap/hostap_pci.c       |    2 +-
 drivers/net/wireless/hostap/hostap_plx.c       |    2 +-
 drivers/net/wireless/ipw2100.c                 |    4 +-
 drivers/net/wireless/ipw2200.c                 |   47 +
 drivers/net/wireless/libertas/11d.c            |  754 +++++++
 drivers/net/wireless/libertas/11d.h            |  105 +
 drivers/net/wireless/libertas/LICENSE          |   16 +
 drivers/net/wireless/libertas/Makefile         |   21 +
 drivers/net/wireless/libertas/README           | 1044 +++++++++
 drivers/net/wireless/libertas/assoc.c          |  588 +++++
 drivers/net/wireless/libertas/assoc.h          |   30 +
 drivers/net/wireless/libertas/cmd.c            | 1958 +++++++++++++++++
 drivers/net/wireless/libertas/cmdresp.c        | 1031 +++++++++
 drivers/net/wireless/libertas/debugfs.c        | 1935 +++++++++++++++++
 drivers/net/wireless/libertas/debugfs.h        |    6 +
 drivers/net/wireless/libertas/decl.h           |   83 +
 drivers/net/wireless/libertas/defs.h           |  369 ++++
 drivers/net/wireless/libertas/dev.h            |  403 ++++
 drivers/net/wireless/libertas/ethtool.c        |  184 ++
 drivers/net/wireless/libertas/fw.c             |  361 +++
 drivers/net/wireless/libertas/fw.h             |   13 +
 drivers/net/wireless/libertas/host.h           |  338 +++
 drivers/net/wireless/libertas/hostcmd.h        |  693 ++++++
 drivers/net/wireless/libertas/if_bootcmd.c     |   38 +
 drivers/net/wireless/libertas/if_usb.c         |  952 ++++++++
 drivers/net/wireless/libertas/if_usb.h         |  109 +
 drivers/net/wireless/libertas/ioctl.c          | 2500 +++++++++++++++++++++
 drivers/net/wireless/libertas/join.c           | 1055 +++++++++
 drivers/net/wireless/libertas/join.h           |   64 +
 drivers/net/wireless/libertas/main.c           | 1258 +++++++++++
 drivers/net/wireless/libertas/radiotap.h       |   57 +
 drivers/net/wireless/libertas/rx.c             |  459 ++++
 drivers/net/wireless/libertas/sbi.h            |   40 +
 drivers/net/wireless/libertas/scan.c           | 2044 +++++++++++++++++
 drivers/net/wireless/libertas/scan.h           |  216 ++
 drivers/net/wireless/libertas/thread.h         |   52 +
 drivers/net/wireless/libertas/tx.c             |  285 +++
 drivers/net/wireless/libertas/types.h          |  289 +++
 drivers/net/wireless/libertas/version.h        |    8 +
 drivers/net/wireless/libertas/wext.c           | 2769 ++++++++++++++++++++++++
 drivers/net/wireless/libertas/wext.h           |  147 ++
 drivers/net/wireless/todo.txt                  |   15 -
 drivers/net/wireless/zd1211rw/zd_chip.c        |   47 +-
 drivers/net/wireless/zd1211rw/zd_chip.h        |    1 +
 drivers/net/wireless/zd1211rw/zd_mac.c         |   23 +-
 drivers/net/wireless/zd1211rw/zd_rf.c          |   18 +-
 drivers/net/wireless/zd1211rw/zd_rf.h          |   11 +-
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c   |   91 +-
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c  |  317 +++-
 drivers/net/wireless/zd1211rw/zd_rf_rf2959.c   |    4 +-
 drivers/net/wireless/zd1211rw/zd_usb.c         |   24 +-
 include/asm-powerpc/ucc_fast.h                 |    3 +
 include/linux/fsl_devices.h                    |   39 -
 include/linux/hdlc.h                           |    3 +-
 include/linux/pci_ids.h                        |    2 +
 include/linux/phy.h                            |    1 +
 include/linux/wireless.h                       |    2 +-
 include/net/ieee80211.h                        |    4 +-
 include/net/ieee80211_crypt.h                  |    4 +-
 include/net/ieee80211_radiotap.h               |   77 +-
 net/ieee80211/ieee80211_crypt.c                |    2 +-
 net/ieee80211/ieee80211_crypt_ccmp.c           |    4 +-
 net/ieee80211/ieee80211_crypt_tkip.c           |    6 +-
 net/ieee80211/ieee80211_crypt_wep.c            |    2 +-
 net/ieee80211/ieee80211_module.c               |    5 +-
 net/ieee80211/ieee80211_rx.c                   |    4 +-
 net/ieee80211/ieee80211_wx.c                   |    4 +-
 170 files changed, 29413 insertions(+), 6144 deletions(-)
 create mode 100644 arch/mips/mips-boards/sim/sim_platform.c
 delete mode 100644 drivers/net/chelsio/ixf1010.c
 delete mode 100644 drivers/net/chelsio/vsc8244.c
 delete mode 100644 drivers/net/chelsio/vsc8244_reg.h
 delete mode 100644 drivers/net/skfp/h/lnkstat.h
 create mode 100644 drivers/net/ucc_geth_mii.c
 create mode 100644 drivers/net/ucc_geth_mii.h
 delete mode 100644 drivers/net/ucc_geth_phy.c
 delete mode 100644 drivers/net/ucc_geth_phy.h
 delete mode 100644 drivers/net/wireless/README
 create mode 100644 drivers/net/wireless/libertas/11d.c
 create mode 100644 drivers/net/wireless/libertas/11d.h
 create mode 100644 drivers/net/wireless/libertas/LICENSE
 create mode 100644 drivers/net/wireless/libertas/Makefile
 create mode 100644 drivers/net/wireless/libertas/README
 create mode 100644 drivers/net/wireless/libertas/assoc.c
 create mode 100644 drivers/net/wireless/libertas/assoc.h
 create mode 100644 drivers/net/wireless/libertas/cmd.c
 create mode 100644 drivers/net/wireless/libertas/cmdresp.c
 create mode 100644 drivers/net/wireless/libertas/debugfs.c
 create mode 100644 drivers/net/wireless/libertas/debugfs.h
 create mode 100644 drivers/net/wireless/libertas/decl.h
 create mode 100644 drivers/net/wireless/libertas/defs.h
 create mode 100644 drivers/net/wireless/libertas/dev.h
 create mode 100644 drivers/net/wireless/libertas/ethtool.c
 create mode 100644 drivers/net/wireless/libertas/fw.c
 create mode 100644 drivers/net/wireless/libertas/fw.h
 create mode 100644 drivers/net/wireless/libertas/host.h
 create mode 100644 drivers/net/wireless/libertas/hostcmd.h
 create mode 100644 drivers/net/wireless/libertas/if_bootcmd.c
 create mode 100644 drivers/net/wireless/libertas/if_usb.c
 create mode 100644 drivers/net/wireless/libertas/if_usb.h
 create mode 100644 drivers/net/wireless/libertas/ioctl.c
 create mode 100644 drivers/net/wireless/libertas/join.c
 create mode 100644 drivers/net/wireless/libertas/join.h
 create mode 100644 drivers/net/wireless/libertas/main.c
 create mode 100644 drivers/net/wireless/libertas/radiotap.h
 create mode 100644 drivers/net/wireless/libertas/rx.c
 create mode 100644 drivers/net/wireless/libertas/sbi.h
 create mode 100644 drivers/net/wireless/libertas/scan.c
 create mode 100644 drivers/net/wireless/libertas/scan.h
 create mode 100644 drivers/net/wireless/libertas/thread.h
 create mode 100644 drivers/net/wireless/libertas/tx.c
 create mode 100644 drivers/net/wireless/libertas/types.h
 create mode 100644 drivers/net/wireless/libertas/version.h
 create mode 100644 drivers/net/wireless/libertas/wext.c
 create mode 100644 drivers/net/wireless/libertas/wext.h
 delete mode 100644 drivers/net/wireless/todo.txt

Adrian Bunk (3):
      make drivers/net/s2io.c:vlan_strip_flag static
      drivers/net/qla3xxx.c: make 2 functions static
      make drivers/net/qla3xxx.c:PHY_DEVICES[] static

Ahmed S. Darwish (2):
      e1000: Use ARRAY_SIZE macro when appropriate
      ixgb: Use ARRAY_SIZE macro when appropriate.

Andrew Morton (1):
      ipw2200: fix ieee80211_get_geo typo

Arjan van de Ven (1):
      user of the jiffies rounding code: e1000

Atsushi Nemoto (3):
      tc35815 driver update (take 2)
      tc35815: Fix an usage of streaming DMA API.
      tc35815: Zap changelog from source code

Auke Kok (1):
      e1000: list e1000-devel mailing list in MAINTAINERS

Daniel Drake (10):
      zd1211rw: Use compare_ether_addr()
      zd1211rw: Add AL2230S RF support
      zd1211rw: More device IDs
      zd1211rw: Mark some data const
      zd1211rw: Don't handle broken frames in monitor mode
      zd1211rw: Add another ID for Linksys WUSBF54G
      zd1211rw: Remove invalid CR write during ZD1211 phy reset
      zd1211rw: rework band edge patching
      zd1211rw: Add AL7230B RF support for ZD1211B
      zd1211rw: Add ID for ZyXEL AG-220

Deepak Saxena (1):
      Netpoll support for Sibyte MAC

Dmitriy Monakhov (1):
      sk98lin: handle pci_enable_device() return value in skge_resume()

Don Fry (2):
      pcnet32: only allocate init_block dma consistent
      pcnet32: change to use netdev_priv

Folkert van Heusden (1):
      baycom_ser_fdx: also allow i/o ports >= 0x1000 and enhanced failure logging

Gabriel Paubert (1):
      mv643xx_eth: make eth_port_uc_addr_{get,set}() calls symmetric

Jan-Bernd Themann (5):
      ehea: dynamic add / remove port
      ehea: NAPI multi queue TX/RX path for SMP
      ehea: fix for dynamic lpar support
      ehea: code cleanup
      ehea: removing unused functionality

Jean Delvare (1):
      strlcpy is smart enough

Jesse Brandeburg (2):
      e100: allow bad MAC address when running with invalid eeprom csum
      e100: Optionally use I/O mode only to access register space

John W. Linville (2):
      wireless: remove obsolete text files
      libertas: fix build breakage from netdev class_device -> device

Jouni Malinen (2):
      hostap: Add D-Link DWL-650 Rev. P1 product id
      Update my email address from jkmaline@cc.hut.fi to j@w1.fi

Kim Phillips (3):
      phylib: add RGMII-ID interface mode definition
      ucc_geth: migrate ucc_geth to phylib
      ucc_geth: version 1.1

Krzysztof Halasa (1):
      Generic HDLC sparse annotations

Ladislav Michl (1):
      Add support for Seeq 8003 on Challenge S Mezz board.

Larry Finger (5):
      bcm43xx: Update Documentation/bcm43xx.txt
      bcm43xx:Eliminate some 'G Mode Enable' magic numbers
      bcm43xx: Change initialization for 2050 radios
      ieee80211-crypt: Make some TKIP and CCMP error logging conditional
      ieee80211: add missing global needed by IEEE80211_DEBUG_XXXX

Marcelo Tosatti (1):
      Marvell Libertas 8388 802.11b/g USB driver

Marcin Juszkiewicz (1):
      hostap_cs: support ADLINK 345 CF

Mark Mason (1):
      add NAPI support to sb1250-mac.c

Maxim Levitsky (2):
      dmfe: add support for suspend/resume
      dmfe: add support for Wake on lan

Michael Barkowski (1):
      ucc_geth: Fix interrupt coalescing size and alignment

Michael Ellerman (1):
      Fix sparse errors in drivers/net/ibmveth.c

Michael Reiss (2):
      ucc_geth: NAPI-related bug fixes
      ucc_geth: Implement Transmit on Demand support

Michal Schmidt (2):
      airo: Don't check for NULL before kfree()
      airo: Make /sys/bus/pci/drivers/airo/{,un}bind work

Milind Arun Choudhary (2):
      e1000: ROUND_UP macro cleanup in drivers/net/e1000
      ixgb: ROUND_UP macro cleanup in drivers/net/ixgb

Mithlesh Thukral (7):
      NetXen: Use multiple PCI functions
      NetXen: Removal of redundant argument passing
      NetXen: Multi PCI support for Quad cards
      NetXen: Removal of redundant macros
      NetXen: Port swap feature for multi port cards
      NetXen: Fixes for Power PC architecture
      NetXen: Fix for vmalloc issues

Nicu Ioan Petru (1):
      ucc_geth: fixes for ucc_geth_memclean

Pavel Roskin (3):
      hostap: use offsetof() instead of own equivalent
      sparse-annotate radiotap header
      Remove comment about IEEE80211_RADIOTAP_FCS

Ralf Baechle (1):
      MIPSnet: Modernize use platform_device API.

Ramkrishna Vepa (3):
      S2IO: Save/Restore unused buffer mappings in 2/3 buffer mode
      S2io: Remove unused variables
      S2io: Change of driver maintainers

Randy Dunlap (2):
      phy layer: add kernel-doc + DocBook
      mii: add kernel-doc notation

Robert P. J. Day (2):
      remove unused header file: drivers/net/skfp/h/lnkstat.h
      3C509: Remove unnecessary include of <linux/pm_legacy.h>

Ron Mercer (3):
      qla3xxx: Add ethtool get_pauseparam for improved bonding support.
      qla3xxx: Adding support for the Agere PHY (ET1011C)
      qla3xxx: Bumping driver version number to v2.03.00-k4

Sam Ravnborg (1):
      bcm43xx: do not rebuild when kernel version changes

Scott Feldman (1):
      [netdrvr e100] experiment with doing RX in a similar manner to eepro100

Shan Lu (1):
      network: add the missing phy_device speed information to phy_mii_ioctl

Shani (1):
      Patch:replace with time_after in drivers/net/eexpress.c

Shani Moideen (1):
      [netdrvr] eexpress: minor corrections

Stephen Hemminger (7):
      chelsio: remove unused code for 1G boards
      chelsio: use C99 style initialization
      chelsio: use const for virtual functions
      skge: ignore unused error interrupts
      skge: transmit locking improvements
      skge: rearrange fields
      skge: version 1.11

Thibaut VARENE (1):
      TULIP: Natsemi dp83840a PHY fix

Thomas Klein (2):
      ehea: fix for sysfs entries
      ehea: fix for dlpar support

Tony Breeds (1):
      libertas: use standard kernel macros

Ulrich Kunitz (1):
      zd1211rw: changed GFP_NOFS to GFP_KERNEL

Valerie Henson (3):
      TULIP: Fix for 64-bit MIPS
      Fix tulip SytemError typo
      Rev tulip version

Vitaly Wool (1):
      smc911x: fix compilation breakage wjen debug is on

Yan Burman (1):
      e1000: Use kcalloc()

Zhu Yi (1):
      ipw2200: add channels sysfs entry

