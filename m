From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12] drivers/net organize Ethernet drivers (7th series)
Date: Sat, 13 Aug 2011 00:56:24 -0700
Message-ID: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39635 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912Ab1HMH4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 03:56:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the seventh of seven 10 patch series (although this series is 12
patches) to move the Ethernet drivers into drivers/net/ethernet/.

There is still a bit of cleanup left (FDDI, PPP, SLIP, etc), which will
be coming shortly and small in comparison to the Ethernet driver move.
  
The following are changes since commit 9bba23b0ae933a143f8ea89e59c6becf0c1c1d1e:
  starfire: Move the Adaptec driver
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (12):
  hp100: Move the HP driver
  dnet: Move the Dave Ethernet driver
  ethoc: Move the Avionic driver
  greth: Move the Aeroflex Gaisler driver
  enc28j60: Move the Microchip driver
  dm9000: Move the Davicom driver
  netx: Move the netx driver
  sh_eth: Move the Renesas SuperH driver
  xircom: Move the Xircom driver
  tile: Move the Tilera driver
  acenic: Move the Alteon driver
  drivers/net: Kconfig and Makefile cleanup

 MAINTAINERS                                        |    6 +-
 drivers/net/Kconfig                                |  238 ---
 drivers/net/Makefile                               |   14 -
 drivers/net/ethernet/3com/Kconfig                  |   27 -
 drivers/net/ethernet/3com/Makefile                 |    1 -
 drivers/net/ethernet/Kconfig                       |   48 +
 drivers/net/ethernet/Makefile                      |   11 +
 drivers/net/ethernet/aeroflex/Kconfig              |   11 +
 drivers/net/ethernet/aeroflex/Makefile             |    5 +
 drivers/net/{ => ethernet/aeroflex}/greth.c        |    0
 drivers/net/{ => ethernet/aeroflex}/greth.h        |    0
 drivers/net/ethernet/alteon/Kconfig                |   47 +
 drivers/net/ethernet/alteon/Makefile               |    5 +
 drivers/net/ethernet/{3com => alteon}/acenic.c     |    0
 drivers/net/ethernet/{3com => alteon}/acenic.h     |    0
 drivers/net/ethernet/davicom/Kconfig               |   31 +
 drivers/net/ethernet/davicom/Makefile              |    5 +
 drivers/net/{ => ethernet/davicom}/dm9000.c        |    0
 drivers/net/{ => ethernet/davicom}/dm9000.h        |    0
 drivers/net/{ => ethernet}/dnet.c                  |    0
 drivers/net/{ => ethernet}/dnet.h                  |    0
 drivers/net/{ => ethernet}/ethoc.c                 |    0
 drivers/net/ethernet/hp/Kconfig                    |   31 +
 drivers/net/ethernet/hp/Makefile                   |    5 +
 drivers/net/{ => ethernet/hp}/hp100.c              |    0
 drivers/net/{ => ethernet/hp}/hp100.h              |    0
 drivers/net/ethernet/microchip/Kconfig             |   37 +
 drivers/net/ethernet/microchip/Makefile            |    5 +
 drivers/net/{ => ethernet/microchip}/enc28j60.c    |    0
 drivers/net/{ => ethernet/microchip}/enc28j60_hw.h |    0
 drivers/net/{ => ethernet}/netx-eth.c              |    0
 drivers/net/ethernet/renesas/Kconfig               |   18 +
 drivers/net/ethernet/renesas/Makefile              |    5 +
 drivers/net/{ => ethernet/renesas}/sh_eth.c        |    0
 drivers/net/{ => ethernet/renesas}/sh_eth.h        |    0
 drivers/net/ethernet/tile/Kconfig                  |   15 +
 drivers/net/{ => ethernet}/tile/Makefile           |    0
 drivers/net/{ => ethernet}/tile/tilepro.c          |    0
 drivers/net/ethernet/xircom/Kconfig                |   30 +
 drivers/net/ethernet/xircom/Makefile               |    5 +
 .../net/{pcmcia => ethernet/xircom}/xirc2ps_cs.c   |    0
 drivers/net/pci-skeleton.c                         | 1923 --------------------
 drivers/net/pcmcia/Kconfig                         |    9 -
 drivers/net/pcmcia/Makefile                        |    1 -
 44 files changed, 317 insertions(+), 2216 deletions(-)
 create mode 100644 drivers/net/ethernet/aeroflex/Kconfig
 create mode 100644 drivers/net/ethernet/aeroflex/Makefile
 rename drivers/net/{ => ethernet/aeroflex}/greth.c (100%)
 rename drivers/net/{ => ethernet/aeroflex}/greth.h (100%)
 create mode 100644 drivers/net/ethernet/alteon/Kconfig
 create mode 100644 drivers/net/ethernet/alteon/Makefile
 rename drivers/net/ethernet/{3com => alteon}/acenic.c (100%)
 rename drivers/net/ethernet/{3com => alteon}/acenic.h (100%)
 create mode 100644 drivers/net/ethernet/davicom/Kconfig
 create mode 100644 drivers/net/ethernet/davicom/Makefile
 rename drivers/net/{ => ethernet/davicom}/dm9000.c (100%)
 rename drivers/net/{ => ethernet/davicom}/dm9000.h (100%)
 rename drivers/net/{ => ethernet}/dnet.c (100%)
 rename drivers/net/{ => ethernet}/dnet.h (100%)
 rename drivers/net/{ => ethernet}/ethoc.c (100%)
 create mode 100644 drivers/net/ethernet/hp/Kconfig
 create mode 100644 drivers/net/ethernet/hp/Makefile
 rename drivers/net/{ => ethernet/hp}/hp100.c (100%)
 rename drivers/net/{ => ethernet/hp}/hp100.h (100%)
 create mode 100644 drivers/net/ethernet/microchip/Kconfig
 create mode 100644 drivers/net/ethernet/microchip/Makefile
 rename drivers/net/{ => ethernet/microchip}/enc28j60.c (100%)
 rename drivers/net/{ => ethernet/microchip}/enc28j60_hw.h (100%)
 rename drivers/net/{ => ethernet}/netx-eth.c (100%)
 create mode 100644 drivers/net/ethernet/renesas/Kconfig
 create mode 100644 drivers/net/ethernet/renesas/Makefile
 rename drivers/net/{ => ethernet/renesas}/sh_eth.c (100%)
 rename drivers/net/{ => ethernet/renesas}/sh_eth.h (100%)
 create mode 100644 drivers/net/ethernet/tile/Kconfig
 rename drivers/net/{ => ethernet}/tile/Makefile (100%)
 rename drivers/net/{ => ethernet}/tile/tilepro.c (100%)
 create mode 100644 drivers/net/ethernet/xircom/Kconfig
 create mode 100644 drivers/net/ethernet/xircom/Makefile
 rename drivers/net/{pcmcia => ethernet/xircom}/xirc2ps_cs.c (100%)
 delete mode 100644 drivers/net/pci-skeleton.c

-- 
1.7.6

