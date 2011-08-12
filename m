From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10] drivers/net organize Ethernet drivers (6th series)
Date: Fri, 12 Aug 2011 12:45:34 -0700
Message-ID: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63200 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180Ab1HLTpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 15:45:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the sixth of seven 10 patch series to move the Ethernet
drivers into drivers/net/ethernet/
  
The following are changes since commit b13ad8f498793dc582b7f42f27b8f44490bd608d:
  xilinx/ll_temac: Move the Xilinx drivers
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (10):
  ipg: Move the IC Plus driver
  korina: Move the IDT driver
  mipsnet: Move the MIPS driver
  lantiq: Move the Lantiq SoC driver
  bfin_mac: Move the Analog Devices Inc driver
  macb: Move the Atmel driver
  r6040: Move the RDC driver
  fealnx: Move the Myson driver
  forcedeth: Move the NVIDIA nForce driver
  starfire: Move the Adaptec driver

 MAINTAINERS                                        |   10 +-
 drivers/net/Kconfig                                |  140 --------------------
 drivers/net/Makefile                               |   12 --
 drivers/net/arm/Kconfig                            |   12 --
 drivers/net/arm/Makefile                           |    6 -
 drivers/net/ethernet/Kconfig                       |   38 ++++++
 drivers/net/ethernet/Makefile                      |   10 ++
 drivers/net/ethernet/adaptec/Kconfig               |   34 +++++
 drivers/net/ethernet/adaptec/Makefile              |    5 +
 drivers/net/{ => ethernet/adaptec}/starfire.c      |    0
 drivers/net/ethernet/adi/Kconfig                   |   68 ++++++++++
 drivers/net/ethernet/adi/Makefile                  |    5 +
 drivers/net/{ => ethernet/adi}/bfin_mac.c          |    0
 drivers/net/{ => ethernet/adi}/bfin_mac.h          |    0
 drivers/net/ethernet/cadence/Kconfig               |   44 ++++++
 drivers/net/ethernet/cadence/Makefile              |    6 +
 drivers/net/{arm => ethernet/cadence}/at91_ether.c |    0
 drivers/net/{arm => ethernet/cadence}/at91_ether.h |    0
 drivers/net/{ => ethernet/cadence}/macb.c          |    0
 drivers/net/{ => ethernet/cadence}/macb.h          |    0
 drivers/net/{ => ethernet}/fealnx.c                |    0
 drivers/net/ethernet/icplus/Kconfig                |   13 ++
 drivers/net/ethernet/icplus/Makefile               |    5 +
 drivers/net/{ => ethernet/icplus}/ipg.c            |    0
 drivers/net/{ => ethernet/icplus}/ipg.h            |    0
 drivers/net/{ => ethernet}/korina.c                |    0
 drivers/net/{ => ethernet}/lantiq_etop.c           |    0
 drivers/net/{ => ethernet}/mipsnet.c               |    0
 drivers/net/ethernet/nvidia/Kconfig                |   31 +++++
 drivers/net/ethernet/nvidia/Makefile               |    5 +
 drivers/net/{ => ethernet/nvidia}/forcedeth.c      |    0
 drivers/net/ethernet/rdc/Kconfig                   |   33 +++++
 drivers/net/ethernet/rdc/Makefile                  |    5 +
 drivers/net/{ => ethernet/rdc}/r6040.c             |    0
 34 files changed, 307 insertions(+), 175 deletions(-)
 delete mode 100644 drivers/net/arm/Kconfig
 delete mode 100644 drivers/net/arm/Makefile
 create mode 100644 drivers/net/ethernet/adaptec/Kconfig
 create mode 100644 drivers/net/ethernet/adaptec/Makefile
 rename drivers/net/{ => ethernet/adaptec}/starfire.c (100%)
 create mode 100644 drivers/net/ethernet/adi/Kconfig
 create mode 100644 drivers/net/ethernet/adi/Makefile
 rename drivers/net/{ => ethernet/adi}/bfin_mac.c (100%)
 rename drivers/net/{ => ethernet/adi}/bfin_mac.h (100%)
 create mode 100644 drivers/net/ethernet/cadence/Kconfig
 create mode 100644 drivers/net/ethernet/cadence/Makefile
 rename drivers/net/{arm => ethernet/cadence}/at91_ether.c (100%)
 rename drivers/net/{arm => ethernet/cadence}/at91_ether.h (100%)
 rename drivers/net/{ => ethernet/cadence}/macb.c (100%)
 rename drivers/net/{ => ethernet/cadence}/macb.h (100%)
 rename drivers/net/{ => ethernet}/fealnx.c (100%)
 create mode 100644 drivers/net/ethernet/icplus/Kconfig
 create mode 100644 drivers/net/ethernet/icplus/Makefile
 rename drivers/net/{ => ethernet/icplus}/ipg.c (100%)
 rename drivers/net/{ => ethernet/icplus}/ipg.h (100%)
 rename drivers/net/{ => ethernet}/korina.c (100%)
 rename drivers/net/{ => ethernet}/lantiq_etop.c (100%)
 rename drivers/net/{ => ethernet}/mipsnet.c (100%)
 create mode 100644 drivers/net/ethernet/nvidia/Kconfig
 create mode 100644 drivers/net/ethernet/nvidia/Makefile
 rename drivers/net/{ => ethernet/nvidia}/forcedeth.c (100%)
 create mode 100644 drivers/net/ethernet/rdc/Kconfig
 create mode 100644 drivers/net/ethernet/rdc/Makefile
 rename drivers/net/{ => ethernet/rdc}/r6040.c (100%)

-- 
1.7.6

