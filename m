From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10] drivers/net organize Ethernet drivers (4th series)
Date: Fri, 12 Aug 2011 00:32:54 -0700
Message-ID: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58632 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab1HLHdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 03:33:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the fourth of seven 10 patch series to move the Ethernet
drivers into drivers/net/ethernet/

The following are changes since commit 5ff2241dd42ade03572753f9ed7743719b47c474:
  spider_net: fix compile issue introduced by driver move
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (10):
  ewrk3/tulip: Move the DEC - Tulip drivers
  ioc3-eth/meth: Move the SGI drivers
  seeq: Move the SEEQ drivers
  pch_gbe: Move the OKI Semiconductor driver
  skge/sky2/mv643xx/pxa168: Move the Marvell Ethernet drivers
  via-*: Move the VIA drivers
  eth16i: Move the Allied Telesis/Fujitsu drivers
  freescale: Move the Freescale drivers
  ks8*/ksz8*: Move the Micrel drivers
  toshiba: Move the Toshiba drivers

 MAINTAINERS                                        |   28 +-
 drivers/net/Kconfig                                |  371 --------------------
 drivers/net/Makefile                               |   44 ---
 drivers/net/arm/Kconfig                            |   15 -
 drivers/net/arm/Makefile                           |    2 -
 drivers/net/ethernet/Kconfig                       |   10 +
 drivers/net/ethernet/Makefile                      |   10 +
 drivers/net/ethernet/dec/Kconfig                   |   36 ++
 drivers/net/ethernet/dec/Makefile                  |    6 +
 drivers/net/{ => ethernet/dec}/ewrk3.c             |    0
 drivers/net/{ => ethernet/dec}/ewrk3.h             |    0
 drivers/net/{ => ethernet/dec}/tulip/21142.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/Kconfig       |   20 +-
 drivers/net/{ => ethernet/dec}/tulip/Makefile      |    0
 drivers/net/{ => ethernet/dec}/tulip/de2104x.c     |    0
 drivers/net/{ => ethernet/dec}/tulip/de4x5.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/de4x5.h       |    0
 drivers/net/{ => ethernet/dec}/tulip/dmfe.c        |    0
 drivers/net/{ => ethernet/dec}/tulip/eeprom.c      |    0
 drivers/net/{ => ethernet/dec}/tulip/interrupt.c   |    0
 drivers/net/{ => ethernet/dec}/tulip/media.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/pnic.c        |    0
 drivers/net/{ => ethernet/dec}/tulip/pnic2.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/timer.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/tulip.h       |    0
 drivers/net/{ => ethernet/dec}/tulip/tulip_core.c  |    0
 drivers/net/{ => ethernet/dec}/tulip/uli526x.c     |    0
 drivers/net/{ => ethernet/dec}/tulip/winbond-840.c |    0
 drivers/net/{ => ethernet/dec}/tulip/xircom_cb.c   |    0
 drivers/net/ethernet/freescale/Kconfig             |   88 +++++
 drivers/net/ethernet/freescale/Makefile            |   18 +
 drivers/net/{ => ethernet/freescale}/fec.c         |    0
 drivers/net/{ => ethernet/freescale}/fec.h         |    0
 drivers/net/{ => ethernet/freescale}/fec_mpc52xx.c |    0
 drivers/net/{ => ethernet/freescale}/fec_mpc52xx.h |    0
 .../net/{ => ethernet/freescale}/fec_mpc52xx_phy.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/Kconfig   |    2 +-
 .../net/{ => ethernet/freescale}/fs_enet/Makefile  |    0
 drivers/net/{ => ethernet/freescale}/fs_enet/fec.h |    0
 .../freescale}/fs_enet/fs_enet-main.c              |    0
 .../net/{ => ethernet/freescale}/fs_enet/fs_enet.h |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-fcc.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-fec.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-scc.c |    0
 .../{ => ethernet/freescale}/fs_enet/mii-bitbang.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mii-fec.c |    0
 drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.c |    0
 drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.h |    0
 drivers/net/{ => ethernet/freescale}/gianfar.c     |    0
 drivers/net/{ => ethernet/freescale}/gianfar.h     |    0
 .../net/{ => ethernet/freescale}/gianfar_ethtool.c |    0
 drivers/net/{ => ethernet/freescale}/gianfar_ptp.c |    0
 .../net/{ => ethernet/freescale}/gianfar_sysfs.c   |    0
 drivers/net/{ => ethernet/freescale}/ucc_geth.c    |    0
 drivers/net/{ => ethernet/freescale}/ucc_geth.h    |    0
 .../{ => ethernet/freescale}/ucc_geth_ethtool.c    |    0
 drivers/net/ethernet/fujitsu/Kconfig               |   53 +++
 drivers/net/ethernet/fujitsu/Makefile              |    7 +
 drivers/net/{ => ethernet/fujitsu}/at1700.c        |    0
 drivers/net/{ => ethernet/fujitsu}/eth16i.c        |    0
 .../net/{pcmcia => ethernet/fujitsu}/fmvj18x_cs.c  |    0
 drivers/net/ethernet/marvell/Kconfig               |  110 ++++++
 drivers/net/ethernet/marvell/Makefile              |    8 +
 drivers/net/{ => ethernet/marvell}/mv643xx_eth.c   |    0
 drivers/net/{ => ethernet/marvell}/pxa168_eth.c    |    0
 drivers/net/{ => ethernet/marvell}/skge.c          |    0
 drivers/net/{ => ethernet/marvell}/skge.h          |    0
 drivers/net/{ => ethernet/marvell}/sky2.c          |    0
 drivers/net/{ => ethernet/marvell}/sky2.h          |    0
 drivers/net/ethernet/micrel/Kconfig                |   64 ++++
 drivers/net/ethernet/micrel/Makefile               |    9 +
 drivers/net/{arm => ethernet/micrel}/ks8695net.c   |    0
 drivers/net/{arm => ethernet/micrel}/ks8695net.h   |    0
 drivers/net/{ => ethernet/micrel}/ks8842.c         |    0
 drivers/net/{ => ethernet/micrel}/ks8851.c         |    0
 drivers/net/{ => ethernet/micrel}/ks8851.h         |    0
 drivers/net/{ => ethernet/micrel}/ks8851_mll.c     |    0
 drivers/net/{ => ethernet/micrel}/ksz884x.c        |    0
 drivers/net/ethernet/oki-semi/Kconfig              |   22 ++
 drivers/net/ethernet/oki-semi/Makefile             |    5 +
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |   20 +
 .../net/{ => ethernet/oki-semi}/pch_gbe/Makefile   |    0
 .../net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe.h  |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.c  |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.h  |    0
 .../oki-semi}/pch_gbe/pch_gbe_ethtool.c            |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_main.c |    0
 .../oki-semi}/pch_gbe/pch_gbe_param.c              |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.c  |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.h  |    0
 drivers/net/ethernet/seeq/Kconfig                  |   45 +++
 drivers/net/ethernet/seeq/Makefile                 |    7 +
 drivers/net/{arm => ethernet/seeq}/ether3.c        |    0
 drivers/net/{arm => ethernet/seeq}/ether3.h        |    0
 drivers/net/{ => ethernet/seeq}/seeq8005.c         |    0
 drivers/net/{ => ethernet/seeq}/seeq8005.h         |    0
 drivers/net/{ => ethernet/seeq}/sgiseeq.c          |    0
 drivers/net/{ => ethernet/seeq}/sgiseeq.h          |    0
 drivers/net/ethernet/sgi/Kconfig                   |   34 ++
 drivers/net/ethernet/sgi/Makefile                  |    6 +
 drivers/net/{ => ethernet/sgi}/ioc3-eth.c          |    0
 drivers/net/{ => ethernet/sgi}/meth.c              |    0
 drivers/net/{ => ethernet/sgi}/meth.h              |    0
 drivers/net/ethernet/toshiba/Kconfig               |   56 +++
 drivers/net/ethernet/toshiba/Makefile              |   10 +
 drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.c |    0
 drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.h |    0
 .../{ => ethernet/toshiba}/ps3_gelic_wireless.c    |    0
 .../{ => ethernet/toshiba}/ps3_gelic_wireless.h    |    0
 drivers/net/{ => ethernet/toshiba}/spider_net.c    |    0
 drivers/net/{ => ethernet/toshiba}/spider_net.h    |    0
 .../{ => ethernet/toshiba}/spider_net_ethtool.c    |    0
 drivers/net/{ => ethernet/toshiba}/tc35815.c       |    0
 drivers/net/ethernet/via/Kconfig                   |   56 +++
 drivers/net/ethernet/via/Makefile                  |    6 +
 drivers/net/{ => ethernet/via}/via-rhine.c         |    0
 drivers/net/{ => ethernet/via}/via-velocity.c      |    0
 drivers/net/{ => ethernet/via}/via-velocity.h      |    0
 drivers/net/pcmcia/Kconfig                         |   10 -
 drivers/net/pcmcia/Makefile                        |    1 -
 120 files changed, 711 insertions(+), 468 deletions(-)
 create mode 100644 drivers/net/ethernet/dec/Kconfig
 create mode 100644 drivers/net/ethernet/dec/Makefile
 rename drivers/net/{ => ethernet/dec}/ewrk3.c (100%)
 rename drivers/net/{ => ethernet/dec}/ewrk3.h (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/21142.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/Kconfig (96%)
 rename drivers/net/{ => ethernet/dec}/tulip/Makefile (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/de2104x.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/de4x5.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/de4x5.h (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/dmfe.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/eeprom.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/interrupt.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/media.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/pnic.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/pnic2.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/timer.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/tulip.h (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/tulip_core.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/uli526x.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/winbond-840.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/xircom_cb.c (100%)
 create mode 100644 drivers/net/ethernet/freescale/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/Makefile
 rename drivers/net/{ => ethernet/freescale}/fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fec.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fec_mpc52xx.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fec_mpc52xx.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fec_mpc52xx_phy.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/Kconfig (91%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/Makefile (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fec.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fs_enet-main.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fs_enet.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-fcc.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-scc.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mii-bitbang.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mii-fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.h (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar.h (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_ethtool.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_ptp.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_sysfs.c (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth.c (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth.h (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth_ethtool.c (100%)
 create mode 100644 drivers/net/ethernet/fujitsu/Kconfig
 create mode 100644 drivers/net/ethernet/fujitsu/Makefile
 rename drivers/net/{ => ethernet/fujitsu}/at1700.c (100%)
 rename drivers/net/{ => ethernet/fujitsu}/eth16i.c (100%)
 rename drivers/net/{pcmcia => ethernet/fujitsu}/fmvj18x_cs.c (100%)
 create mode 100644 drivers/net/ethernet/marvell/Kconfig
 create mode 100644 drivers/net/ethernet/marvell/Makefile
 rename drivers/net/{ => ethernet/marvell}/mv643xx_eth.c (100%)
 rename drivers/net/{ => ethernet/marvell}/pxa168_eth.c (100%)
 rename drivers/net/{ => ethernet/marvell}/skge.c (100%)
 rename drivers/net/{ => ethernet/marvell}/skge.h (100%)
 rename drivers/net/{ => ethernet/marvell}/sky2.c (100%)
 rename drivers/net/{ => ethernet/marvell}/sky2.h (100%)
 create mode 100644 drivers/net/ethernet/micrel/Kconfig
 create mode 100644 drivers/net/ethernet/micrel/Makefile
 rename drivers/net/{arm => ethernet/micrel}/ks8695net.c (100%)
 rename drivers/net/{arm => ethernet/micrel}/ks8695net.h (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8842.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.h (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851_mll.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ksz884x.c (100%)
 create mode 100644 drivers/net/ethernet/oki-semi/Kconfig
 create mode 100644 drivers/net/ethernet/oki-semi/Makefile
 create mode 100644 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/Makefile (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe.h (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.h (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_ethtool.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_main.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_param.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.h (100%)
 create mode 100644 drivers/net/ethernet/seeq/Kconfig
 create mode 100644 drivers/net/ethernet/seeq/Makefile
 rename drivers/net/{arm => ethernet/seeq}/ether3.c (100%)
 rename drivers/net/{arm => ethernet/seeq}/ether3.h (100%)
 rename drivers/net/{ => ethernet/seeq}/seeq8005.c (100%)
 rename drivers/net/{ => ethernet/seeq}/seeq8005.h (100%)
 rename drivers/net/{ => ethernet/seeq}/sgiseeq.c (100%)
 rename drivers/net/{ => ethernet/seeq}/sgiseeq.h (100%)
 create mode 100644 drivers/net/ethernet/sgi/Kconfig
 create mode 100644 drivers/net/ethernet/sgi/Makefile
 rename drivers/net/{ => ethernet/sgi}/ioc3-eth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.h (100%)
 create mode 100644 drivers/net/ethernet/toshiba/Kconfig
 create mode 100644 drivers/net/ethernet/toshiba/Makefile
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.h (100%)
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_wireless.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_wireless.h (100%)
 rename drivers/net/{ => ethernet/toshiba}/spider_net.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/spider_net.h (100%)
 rename drivers/net/{ => ethernet/toshiba}/spider_net_ethtool.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/tc35815.c (100%)
 create mode 100644 drivers/net/ethernet/via/Kconfig
 create mode 100644 drivers/net/ethernet/via/Makefile
 rename drivers/net/{ => ethernet/via}/via-rhine.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.h (100%)

-- 
1.7.6

