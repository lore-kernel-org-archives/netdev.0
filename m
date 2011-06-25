From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 00/72] Organize/Move of the Ethernet drivers in drivers/net/
Date: Sat, 25 Jun 2011 06:58:11 -0700
Message-ID: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46933 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab1FYN72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is the first attempt to organize the drivers/net
directory.  This process was started a year ago, and the emphasis was
on making the drivers/net/ easier to maintain and to group similar
drivers into the appropriate sub-directory.

The next steps are to move all the FIDDI drivers into drivers/net/fiddi,
and like so.  In addition, look at splitting the PS3 driver so that the
wireless portion can be moved into /drivers/net/wireless.

The following are changes since commit c6af9c406ceb3434281cf230938453931dcbab75:
  net: wimax: Remove of unused 'rfkill_input' pointer
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (72):
  drivers/net/ethernet: Add ethernet dir and config option
  3c*/acenic/typhoon: Move 3Com Ethernet drivers
  amd8111e/pcnet32/*lance/mvme147: Move AMD chipset drivers
  8390: Move the 8390 related drivers
  broadcom: Move the Broadcom drivers
  chelsio: Move the Chelsio drivers
  intel: Move the Intel wired LAN drivers
  qlogic: Move the QLogic drivers
  smc: Move the SMC drivers
  ni5*/ni65: Move the Racal-Interlan (Micom) drivers
  cassini/niu/sun*: Move the Sun drivers
  sfc: Move the Solarflare drivers
  be2net: Move the Emulex driver
  bna: Move the Brocade driver
  mlx4: Move the Mellanox driver
  myri*: Move the Myricom drivers
  s2io/vxge: Move the Exar drivers
  ehea/ibm*: Move the IBM drivers
  enic: Move the Cisco driver
  pasemic_mac*: Move the PA Semi driver
  tehuti: Move the Tehuti driver
  stmmac: Move the STMicroelectronics driver
  bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple) drivers
  *sonic/natsemi/ns83829: Move the National Semi-conductor drivers
  smsc*/smc911x: Move the SMSC drivers
  arm: Move the ARM/ACORN drivers
  ftgmac100/ftmac100: Move the Faraday drivers
  8139*/atp/r8169: Move the Realtek drivers
  de6*/dl2k: Move the D-Link drivers
  atl*: Move the Atheros drivers
  tulip: Move the tulip drivers
  ioc3-eth/meth/sgiseeq: Move the SGI drivers
  pch_gbe: Move the OKI driver
  skge/sky2: Move the SysKonnect Ethernet drivers
  via-*: Move the VIA drivers
  eepro/eexpress/eth16i/ewrk3/lp486e/seeq8005/znet: Move the ISA
    drivers
  fsl_*/gianfar*/ucc_*: Move the Freescale drivers
  ks8*/ksz8*: Move the Micrel drivers
  mv643xx/pxa168: Move the Marvell drivers
  spider_net: Move the spider_net (IBM) driver
  sis*: Move the Silicon Integrated Systems (SiS) drivers
  82586.c/fec*: Move the Motorola drivers
  a2065/ariadne: Move the a2065/ariadne drivers
  s6gmac/tsi108_eth: Move the s6gmac/tsi108_eth drivers
  tlan/cpmac: Move the TI drivers
  ixp2000: Move the Radisys driver
  hamachi/yellowfin: Move the packet engine drivers
  octeon: Move the Cavium driver
  jme: Move the JME driver
  xilinx/ll_temac: Move the Xilinx drivers
  ipg: Move the IC Plus driver
  ps3_gelic*: Move the Sony (PS3) drivers
  korina: Move the IDT driver
  au1000_eth/mipsnet/tc35815: Move the MIPS drivers
  bfin_mac: Move the Blackfin driver
  macb: Move the Atmel driver
  sc92031: Move the Silan driver
  sundance: Move the sundance driver
  r6040: Move the RDC driver
  fealnx: Move the Myson driver
  forcedeth: Move the NVIDIA nForce driver
  starfire: Move the starfire driver
  hp100/depca: Move the HP and Digital drivers
  at1700: Move the Allied Telesis driver
  dnet: Move the Dave Ethernet driver
  ethoc: Move the Avionic driver
  greth: Move the Aeroflex Gaisler driver
  enc28j60: Move the enc28j60 driver
  dm9000: Move the Davicom driver
  netx: Move the netx driver
  sh_eth: Move the Renesas SuperH driver
  drivers/net: Kconfig and Makefile cleanup

 MAINTAINERS                                        |  153 +-
 drivers/infiniband/hw/cxgb3/Makefile               |    2 +-
 drivers/infiniband/hw/cxgb4/Makefile               |    2 +-
 drivers/net/Kconfig                                | 2738 +-------------------
 drivers/net/Makefile                               |  233 +--
 drivers/net/arm/Kconfig                            |   74 -
 drivers/net/benet/Kconfig                          |    6 -
 drivers/net/{ => ethernet/3com}/3c501.c            |    0
 drivers/net/{ => ethernet/3com}/3c501.h            |    0
 drivers/net/{ => ethernet/3com}/3c503.c            |    0
 drivers/net/{ => ethernet/3com}/3c503.h            |    0
 drivers/net/{ => ethernet/3com}/3c505.c            |    0
 drivers/net/{ => ethernet/3com}/3c505.h            |    0
 drivers/net/{ => ethernet/3com}/3c507.c            |    0
 drivers/net/{ => ethernet/3com}/3c509.c            |    0
 drivers/net/{ => ethernet/3com}/3c515.c            |    0
 drivers/net/{ => ethernet/3com}/3c523.c            |    0
 drivers/net/{ => ethernet/3com}/3c523.h            |    0
 drivers/net/{ => ethernet/3com}/3c527.c            |    0
 drivers/net/{ => ethernet/3com}/3c527.h            |    0
 drivers/net/{pcmcia => ethernet/3com}/3c574_cs.c   |    0
 drivers/net/{pcmcia => ethernet/3com}/3c589_cs.c   |    0
 drivers/net/{ => ethernet/3com}/3c59x.c            |    0
 drivers/net/ethernet/3com/Kconfig                  |  200 ++
 drivers/net/ethernet/3com/Makefile                 |   17 +
 drivers/net/{ => ethernet/3com}/acenic.c           |    0
 drivers/net/{ => ethernet/3com}/acenic.h           |    0
 drivers/net/{ => ethernet/3com}/typhoon.c          |    0
 drivers/net/{ => ethernet/3com}/typhoon.h          |    0
 drivers/net/{ => ethernet/8390}/8390.c             |    0
 drivers/net/{ => ethernet/8390}/8390.h             |    0
 drivers/net/{ => ethernet/8390}/8390p.c            |    0
 drivers/net/ethernet/8390/Kconfig                  |  312 +++
 drivers/net/ethernet/8390/Makefile                 |   27 +
 drivers/net/{ => ethernet/8390}/ac3200.c           |    0
 drivers/net/{ => ethernet/8390}/apne.c             |    0
 drivers/net/{ => ethernet/8390}/ax88796.c          |    0
 drivers/net/{pcmcia => ethernet/8390}/axnet_cs.c   |    2 +-
 drivers/net/{ => ethernet/8390}/e2100.c            |    0
 drivers/net/{ => ethernet/8390}/es3210.c           |    0
 drivers/net/{ => ethernet/8390}/hp-plus.c          |    0
 drivers/net/{ => ethernet/8390}/hp.c               |    0
 drivers/net/{ => ethernet/8390}/hydra.c            |    0
 drivers/net/{ => ethernet/8390}/lib8390.c          |    0
 drivers/net/{ => ethernet/8390}/lne390.c           |    0
 drivers/net/{ => ethernet/8390}/mac8390.c          |    0
 drivers/net/{ => ethernet/8390}/ne-h8300.c         |    0
 drivers/net/{ => ethernet/8390}/ne.c               |    0
 drivers/net/{ => ethernet/8390}/ne2.c              |    0
 drivers/net/{ => ethernet/8390}/ne2k-pci.c         |    0
 drivers/net/{ => ethernet/8390}/ne3210.c           |    0
 drivers/net/{pcmcia => ethernet/8390}/pcnet_cs.c   |    2 +-
 drivers/net/{ => ethernet/8390}/smc-mca.c          |    0
 drivers/net/{ => ethernet/8390}/smc-ultra.c        |    0
 drivers/net/{ => ethernet/8390}/smc-ultra32.c      |    0
 drivers/net/{ => ethernet/8390}/stnic.c            |    0
 drivers/net/{ => ethernet/8390}/wd.c               |    0
 drivers/net/{ => ethernet/8390}/zorro8390.c        |    0
 drivers/net/ethernet/Kconfig                       |  324 +++
 drivers/net/ethernet/Makefile                      |   76 +
 drivers/net/{ => ethernet}/a2065.c                 |    0
 drivers/net/{ => ethernet}/a2065.h                 |    0
 drivers/net/ethernet/aeroflex/Kconfig              |   11 +
 drivers/net/ethernet/aeroflex/Makefile             |    5 +
 drivers/net/{ => ethernet/aeroflex}/greth.c        |    0
 drivers/net/{ => ethernet/aeroflex}/greth.h        |    0
 drivers/net/{ => ethernet/amd}/7990.c              |    0
 drivers/net/{ => ethernet/amd}/7990.h              |    0
 drivers/net/ethernet/amd/Kconfig                   |  115 +
 drivers/net/ethernet/amd/Makefile                  |   13 +
 drivers/net/{ => ethernet/amd}/amd8111e.c          |    0
 drivers/net/{ => ethernet/amd}/amd8111e.h          |    0
 drivers/net/{ => ethernet/amd}/atarilance.c        |    0
 drivers/net/{ => ethernet/amd}/declance.c          |    0
 drivers/net/{ => ethernet/amd}/hplance.c           |    0
 drivers/net/{ => ethernet/amd}/hplance.h           |    0
 drivers/net/{ => ethernet/amd}/lance.c             |    0
 drivers/net/{ => ethernet/amd}/mvme147.c           |    0
 drivers/net/{ => ethernet/amd}/pcnet32.c           |    0
 drivers/net/{ => ethernet/amd}/sun3lance.c         |    0
 drivers/net/{ => ethernet/amd}/sunlance.c          |    0
 drivers/net/ethernet/apple/Kconfig                 |   92 +
 drivers/net/ethernet/apple/Makefile                |    9 +
 drivers/net/{ => ethernet/apple}/bmac.c            |    0
 drivers/net/{ => ethernet/apple}/bmac.h            |    0
 drivers/net/{ => ethernet/apple}/cs89x0.c          |    0
 drivers/net/{ => ethernet/apple}/cs89x0.h          |    0
 drivers/net/{ => ethernet/apple}/mac89x0.c         |    0
 drivers/net/{ => ethernet/apple}/mace.c            |    0
 drivers/net/{ => ethernet/apple}/mace.h            |    0
 drivers/net/{ => ethernet/apple}/macmace.c         |    0
 drivers/net/{ => ethernet}/ariadne.c               |    0
 drivers/net/{ => ethernet}/ariadne.h               |    0
 drivers/net/ethernet/arm/Kconfig                   |  120 +
 drivers/net/{ => ethernet}/arm/Makefile            |    4 +-
 drivers/net/{ => ethernet}/arm/am79c961a.c         |    0
 drivers/net/{ => ethernet}/arm/am79c961a.h         |    0
 drivers/net/{ => ethernet}/arm/at91_ether.c        |    0
 drivers/net/{ => ethernet}/arm/at91_ether.h        |    0
 drivers/net/{ => ethernet/arm}/davinci_cpdma.c     |    0
 drivers/net/{ => ethernet/arm}/davinci_cpdma.h     |    0
 drivers/net/{ => ethernet/arm}/davinci_emac.c      |    0
 drivers/net/{ => ethernet/arm}/davinci_mdio.c      |    0
 drivers/net/{ => ethernet}/arm/ep93xx_eth.c        |    0
 drivers/net/{ => ethernet}/arm/ether1.c            |    0
 drivers/net/{ => ethernet}/arm/ether1.h            |    0
 drivers/net/{ => ethernet}/arm/ether3.c            |    0
 drivers/net/{ => ethernet}/arm/ether3.h            |    0
 drivers/net/{ => ethernet}/arm/etherh.c            |    0
 drivers/net/{ => ethernet}/arm/ixp4xx_eth.c        |    0
 drivers/net/{ => ethernet}/arm/ks8695net.c         |    0
 drivers/net/{ => ethernet}/arm/ks8695net.h         |    0
 drivers/net/{ => ethernet}/arm/w90p910_ether.c     |    0
 drivers/net/{ => ethernet}/at1700.c                |    0
 drivers/net/ethernet/atheros/Kconfig               |   61 +
 drivers/net/ethernet/atheros/Makefile              |    8 +
 drivers/net/{ => ethernet/atheros}/atl1c/Makefile  |    0
 drivers/net/{ => ethernet/atheros}/atl1c/atl1c.h   |    0
 .../{ => ethernet/atheros}/atl1c/atl1c_ethtool.c   |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_hw.c    |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_hw.h    |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_main.c  |    0
 drivers/net/{ => ethernet/atheros}/atl1e/Makefile  |    0
 drivers/net/{ => ethernet/atheros}/atl1e/atl1e.h   |    0
 .../{ => ethernet/atheros}/atl1e/atl1e_ethtool.c   |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_hw.c    |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_hw.h    |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_main.c  |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_param.c |    0
 drivers/net/{ => ethernet/atheros}/atlx/Makefile   |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl1.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl1.h     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl2.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl2.h     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atlx.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atlx.h     |    0
 drivers/net/ethernet/atmel/Kconfig                 |   32 +
 drivers/net/ethernet/atmel/Makefile                |    5 +
 drivers/net/{ => ethernet/atmel}/macb.c            |    0
 drivers/net/{ => ethernet/atmel}/macb.h            |    0
 drivers/net/ethernet/blackfin/Kconfig              |   65 +
 drivers/net/ethernet/blackfin/Makefile             |    5 +
 drivers/net/{ => ethernet/blackfin}/bfin_mac.c     |    0
 drivers/net/{ => ethernet/blackfin}/bfin_mac.h     |    0
 drivers/net/ethernet/broadcom/Kconfig              |  114 +
 drivers/net/ethernet/broadcom/Makefile             |   11 +
 drivers/net/{ => ethernet/broadcom}/b44.c          |    0
 drivers/net/{ => ethernet/broadcom}/b44.h          |    0
 drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.c |    0
 drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.h |    0
 drivers/net/{ => ethernet/broadcom}/bnx2.c         |    0
 drivers/net/{ => ethernet/broadcom}/bnx2.h         |    0
 drivers/net/{ => ethernet/broadcom}/bnx2_fw.h      |    0
 drivers/net/{ => ethernet/broadcom}/bnx2x/Makefile |    0
 drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.c  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.c  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_dump.h |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_ethtool.c  |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_fw_defs.h  |    0
 .../broadcom}/bnx2x/bnx2x_fw_file_hdr.h            |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_hsi.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_init.h |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_init_ops.h |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.c |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.h |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_main.c |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_reg.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.c   |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.h   |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_stats.c    |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_stats.h    |    0
 drivers/net/{ => ethernet/broadcom}/cnic.c         |    4 +-
 drivers/net/{ => ethernet/broadcom}/cnic.h         |    0
 drivers/net/{ => ethernet/broadcom}/cnic_defs.h    |    0
 drivers/net/{ => ethernet/broadcom}/cnic_if.h      |    0
 drivers/net/{ => ethernet/broadcom}/sb1250-mac.c   |    0
 drivers/net/{ => ethernet/broadcom}/tg3.c          |    0
 drivers/net/{ => ethernet/broadcom}/tg3.h          |    0
 drivers/net/ethernet/brocade/Kconfig               |   18 +
 drivers/net/ethernet/brocade/Makefile              |    5 +
 drivers/net/ethernet/brocade/bna/Kconfig           |   17 +
 drivers/net/{ => ethernet/brocade}/bna/Makefile    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_cee.c   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_cee.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_defs.h  |    0
 .../net/{ => ethernet/brocade}/bna/bfa_defs_cna.h  |    0
 .../{ => ethernet/brocade}/bna/bfa_defs_mfg_comm.h |    0
 .../{ => ethernet/brocade}/bna/bfa_defs_status.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.c   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.h   |    0
 .../net/{ => ethernet/brocade}/bna/bfa_ioc_ct.c    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_sm.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_wc.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_cna.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_ctreg.h |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_ll.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bna.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_ctrl.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_hw.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_txrx.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_types.h |    0
 drivers/net/{ => ethernet/brocade}/bna/bnad.c      |    0
 drivers/net/{ => ethernet/brocade}/bna/bnad.h      |    0
 .../net/{ => ethernet/brocade}/bna/bnad_ethtool.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/cna.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/cna_fwimg.c |    0
 drivers/net/ethernet/chelsio/Kconfig               |  102 +
 drivers/net/ethernet/chelsio/Makefile              |    8 +
 .../{chelsio => ethernet/chelsio/cxgb}/Makefile    |    0
 .../{chelsio => ethernet/chelsio/cxgb}/common.h    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/cphy.h  |    0
 .../{chelsio => ethernet/chelsio/cxgb}/cpl5_cmd.h  |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/cxgb2.c |    0
 .../{chelsio => ethernet/chelsio/cxgb}/elmer0.h    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/espi.c  |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/espi.h  |    0
 .../{chelsio => ethernet/chelsio/cxgb}/fpga_defs.h |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/gmac.h  |    0
 .../{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.c |    0
 .../{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.h |    0
 .../{chelsio => ethernet/chelsio/cxgb}/mv88x201x.c |    0
 .../{chelsio => ethernet/chelsio/cxgb}/my3126.c    |    0
 .../{chelsio => ethernet/chelsio/cxgb}/pm3393.c    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/regs.h  |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/sge.c   |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/sge.h   |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/subr.c  |    0
 .../chelsio/cxgb}/suni1x10gexp_regs.h              |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/tp.c    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/tp.h    |    0
 .../{chelsio => ethernet/chelsio/cxgb}/vsc7326.c   |    0
 .../chelsio/cxgb}/vsc7326_reg.h                    |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/Makefile  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/adapter.h |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/ael1002.c |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/aq100x.c  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/common.h  |    0
 .../{ => ethernet/chelsio}/cxgb3/cxgb3_ctl_defs.h  |    0
 .../net/{ => ethernet/chelsio}/cxgb3/cxgb3_defs.h  |    0
 .../net/{ => ethernet/chelsio}/cxgb3/cxgb3_ioctl.h |    0
 .../net/{ => ethernet/chelsio}/cxgb3/cxgb3_main.c  |    0
 .../{ => ethernet/chelsio}/cxgb3/cxgb3_offload.c   |    0
 .../{ => ethernet/chelsio}/cxgb3/cxgb3_offload.h   |    0
 .../chelsio}/cxgb3/firmware_exports.h              |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.h     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/mc5.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/regs.h    |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/sge.c     |    0
 .../net/{ => ethernet/chelsio}/cxgb3/sge_defs.h    |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/t3_cpl.h  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/t3_hw.c   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/t3cdev.h  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/version.h |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/vsc8211.c |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/xgmac.c   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/Makefile  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4.h   |    0
 .../net/{ => ethernet/chelsio}/cxgb4/cxgb4_main.c  |    0
 .../net/{ => ethernet/chelsio}/cxgb4/cxgb4_uld.h   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.h     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/sge.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.c   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.h   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_msg.h  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_regs.h |    0
 .../net/{ => ethernet/chelsio}/cxgb4/t4fw_api.h    |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/Makefile    |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/adapter.h   |    0
 .../{ => ethernet/chelsio}/cxgb4vf/cxgb4vf_main.c  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4vf/sge.c   |    0
 .../{ => ethernet/chelsio}/cxgb4vf/t4vf_common.h   |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/t4vf_defs.h |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/t4vf_hw.c   |    0
 drivers/net/ethernet/cisco/Kconfig                 |   18 +
 drivers/net/ethernet/cisco/Makefile                |    5 +
 drivers/net/ethernet/cisco/enic/Kconfig            |    9 +
 drivers/net/{ => ethernet/cisco}/enic/Makefile     |    0
 drivers/net/{ => ethernet/cisco}/enic/cq_desc.h    |    0
 .../net/{ => ethernet/cisco}/enic/cq_enet_desc.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic.h       |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_dev.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_dev.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_main.c  |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_pp.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_pp.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_res.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_res.h   |    0
 .../net/{ => ethernet/cisco}/enic/rq_enet_desc.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_cq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_cq.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_dev.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_dev.h   |    0
 .../net/{ => ethernet/cisco}/enic/vnic_devcmd.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_enet.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_intr.c  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_intr.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_nic.h   |    0
 .../net/{ => ethernet/cisco}/enic/vnic_resource.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rq.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rss.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_stats.h |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_vic.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_vic.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_wq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_wq.h    |    0
 .../net/{ => ethernet/cisco}/enic/wq_enet_desc.h   |    0
 drivers/net/ethernet/davicom/Kconfig               |   31 +
 drivers/net/ethernet/davicom/Makefile              |    5 +
 drivers/net/{ => ethernet/davicom}/dm9000.c        |    0
 drivers/net/{ => ethernet/davicom}/dm9000.h        |    0
 drivers/net/{ => ethernet}/depca.c                 |    0
 drivers/net/{ => ethernet}/depca.h                 |    0
 drivers/net/ethernet/dlink/Kconfig                 |   60 +
 drivers/net/ethernet/dlink/Makefile                |    7 +
 drivers/net/{ => ethernet/dlink}/de600.c           |    0
 drivers/net/{ => ethernet/dlink}/de600.h           |    0
 drivers/net/{ => ethernet/dlink}/de620.c           |    0
 drivers/net/{ => ethernet/dlink}/de620.h           |    0
 drivers/net/{ => ethernet/dlink}/dl2k.c            |    0
 drivers/net/{ => ethernet/dlink}/dl2k.h            |    0
 drivers/net/{ => ethernet}/dnet.c                  |    0
 drivers/net/{ => ethernet}/dnet.h                  |    0
 drivers/net/ethernet/emulex/Kconfig                |   18 +
 drivers/net/ethernet/emulex/Makefile               |    5 +
 drivers/net/ethernet/emulex/benet/Kconfig          |    6 +
 drivers/net/{ => ethernet/emulex}/benet/Makefile   |    0
 drivers/net/{ => ethernet/emulex}/benet/be.h       |    0
 drivers/net/{ => ethernet/emulex}/benet/be_cmds.c  |    0
 drivers/net/{ => ethernet/emulex}/benet/be_cmds.h  |    0
 .../net/{ => ethernet/emulex}/benet/be_ethtool.c   |    0
 drivers/net/{ => ethernet/emulex}/benet/be_hw.h    |    0
 drivers/net/{ => ethernet/emulex}/benet/be_main.c  |    0
 drivers/net/{ => ethernet}/enc28j60.c              |    0
 drivers/net/{ => ethernet}/enc28j60_hw.h           |    0
 drivers/net/{ => ethernet}/ethoc.c                 |    0
 drivers/net/ethernet/faraday/Kconfig               |   34 +
 drivers/net/ethernet/faraday/Makefile              |    6 +
 drivers/net/{ => ethernet/faraday}/ftgmac100.c     |    0
 drivers/net/{ => ethernet/faraday}/ftgmac100.h     |    0
 drivers/net/{ => ethernet/faraday}/ftmac100.c      |    0
 drivers/net/{ => ethernet/faraday}/ftmac100.h      |    0
 drivers/net/{ => ethernet}/fealnx.c                |    0
 drivers/net/{ => ethernet}/forcedeth.c             |    0
 drivers/net/ethernet/freescale/Kconfig             |   48 +
 drivers/net/ethernet/freescale/Makefile            |   13 +
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
 drivers/net/{ => ethernet}/hp100.c                 |    0
 drivers/net/{ => ethernet}/hp100.h                 |    0
 drivers/net/ethernet/ibm/Kconfig                   |   62 +
 drivers/net/ethernet/ibm/Makefile                  |   10 +
 drivers/net/{ => ethernet/ibm}/ehea/Makefile       |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea.h         |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h      |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c     |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h     |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/Kconfig |    2 +-
 .../net/{ => ethernet/ibm}/ibm_newemac/Makefile    |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/core.c  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/core.h  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.c |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.h |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/emac.h  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.c   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.h   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.c   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.h   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.c |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.h |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.c   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.h   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.c  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.h  |    0
 drivers/net/{ => ethernet/ibm}/ibmlana.c           |    0
 drivers/net/{ => ethernet/ibm}/ibmlana.h           |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.c           |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.h           |    0
 drivers/net/{ => ethernet/ibm}/spider_net.c        |    0
 drivers/net/{ => ethernet/ibm}/spider_net.h        |    2 +-
 .../net/{ => ethernet/ibm}/spider_net_ethtool.c    |    0
 drivers/net/ethernet/icplus/Kconfig                |   13 +
 drivers/net/ethernet/icplus/Makefile               |    5 +
 drivers/net/{ => ethernet/icplus}/ipg.c            |    0
 drivers/net/{ => ethernet/icplus}/ipg.h            |    0
 drivers/net/ethernet/intel/Kconfig                 |  216 ++
 drivers/net/ethernet/intel/Makefile                |   12 +
 drivers/net/{ => ethernet/intel}/e100.c            |    0
 drivers/net/{ => ethernet/intel}/e1000/Makefile    |    0
 drivers/net/{ => ethernet/intel}/e1000/e1000.h     |    0
 .../net/{ => ethernet/intel}/e1000/e1000_ethtool.c |    0
 drivers/net/{ => ethernet/intel}/e1000/e1000_hw.c  |    0
 drivers/net/{ => ethernet/intel}/e1000/e1000_hw.h  |    0
 .../net/{ => ethernet/intel}/e1000/e1000_main.c    |    0
 .../net/{ => ethernet/intel}/e1000/e1000_osdep.h   |    0
 .../net/{ => ethernet/intel}/e1000/e1000_param.c   |    0
 .../intel/e1000e/80003es2lan.c}                    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/82571.c    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/Makefile   |    4 +-
 drivers/net/{ => ethernet/intel}/e1000e/defines.h  |    0
 .../e1000.h => ethernet/intel/e1000e/e1000e.h}     |    0
 .../intel/e1000e/e1000e_main.c}                    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/ethtool.c  |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/hw.h       |    0
 drivers/net/{ => ethernet/intel}/e1000e/ich8lan.c  |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/lib.c      |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/param.c    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/phy.c      |    2 +-
 drivers/net/{ => ethernet/intel}/igb/Makefile      |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_82575.c |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_82575.h |    0
 .../net/{ => ethernet/intel}/igb/e1000_defines.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_hw.h    |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mac.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mac.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mbx.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mbx.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_nvm.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_nvm.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_phy.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_phy.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_regs.h  |    0
 drivers/net/{ => ethernet/intel}/igb/igb.h         |    0
 drivers/net/{ => ethernet/intel}/igb/igb_ethtool.c |    0
 drivers/net/{ => ethernet/intel}/igb/igb_main.c    |    0
 drivers/net/{ => ethernet/intel}/igbvf/Makefile    |    0
 drivers/net/{ => ethernet/intel}/igbvf/defines.h   |    0
 drivers/net/{ => ethernet/intel}/igbvf/ethtool.c   |    0
 drivers/net/{ => ethernet/intel}/igbvf/igbvf.h     |    0
 drivers/net/{ => ethernet/intel}/igbvf/mbx.c       |    0
 drivers/net/{ => ethernet/intel}/igbvf/mbx.h       |    0
 drivers/net/{ => ethernet/intel}/igbvf/netdev.c    |    0
 drivers/net/{ => ethernet/intel}/igbvf/regs.h      |    0
 drivers/net/{ => ethernet/intel}/igbvf/vf.c        |    0
 drivers/net/{ => ethernet/intel}/igbvf/vf.h        |    0
 drivers/net/{ => ethernet/intel}/ixgb/Makefile     |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb.h       |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.c    |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.h    |    0
 .../net/{ => ethernet/intel}/ixgb/ixgb_ethtool.c   |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.c    |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.h    |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_ids.h   |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_main.c  |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_osdep.h |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_param.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/Makefile    |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe.h     |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_82598.c   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_82599.c   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_common.c  |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_common.h  |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.h |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.c   |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.h   |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.c   |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.h   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_nl.c  |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_ethtool.c |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.c    |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.h    |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_main.c    |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.h |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.h |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.c   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.h   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_type.h    |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_x540.c    |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/Makefile  |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/defines.h |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/ethtool.c |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/ixgbevf.h |    0
 .../{ => ethernet/intel}/ixgbevf/ixgbevf_main.c    |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/mbx.c     |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/mbx.h     |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/regs.h    |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/vf.c      |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/vf.h      |    0
 drivers/net/ethernet/isa/Kconfig                   |  101 +
 drivers/net/ethernet/isa/Makefile                  |   11 +
 drivers/net/{ => ethernet/isa}/eepro.c             |    0
 drivers/net/{ => ethernet/isa}/eexpress.c          |    0
 drivers/net/{ => ethernet/isa}/eexpress.h          |    0
 drivers/net/{ => ethernet/isa}/eth16i.c            |    0
 drivers/net/{ => ethernet/isa}/ewrk3.c             |    0
 drivers/net/{ => ethernet/isa}/ewrk3.h             |    0
 drivers/net/{ => ethernet/isa}/lp486e.c            |    0
 drivers/net/{ => ethernet/isa}/seeq8005.c          |    0
 drivers/net/{ => ethernet/isa}/seeq8005.h          |    0
 drivers/net/{ => ethernet/isa}/znet.c              |    0
 drivers/net/{ => ethernet}/jme.c                   |    0
 drivers/net/{ => ethernet}/jme.h                   |    0
 drivers/net/{ => ethernet}/korina.c                |    0
 drivers/net/ethernet/marvell/Kconfig               |   40 +
 drivers/net/ethernet/marvell/Makefile              |    6 +
 drivers/net/{ => ethernet/marvell}/mv643xx_eth.c   |    0
 drivers/net/{ => ethernet/marvell}/pxa168_eth.c    |    0
 drivers/net/ethernet/mellanox/Kconfig              |   18 +
 drivers/net/ethernet/mellanox/Makefile             |    5 +
 drivers/net/ethernet/mellanox/mlx4/Kconfig         |   27 +
 drivers/net/{ => ethernet/mellanox}/mlx4/Makefile  |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/alloc.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/catas.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/cmd.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/cq.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_cq.c   |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_ethtool.c  |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_main.c |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_netdev.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_port.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_port.h |    0
 .../{ => ethernet/mellanox}/mlx4/en_resources.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_rx.c   |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_selftest.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_tx.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/eq.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/fw.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/fw.h      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/icm.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/icm.h     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/intf.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/main.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mcg.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mlx4.h    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mlx4_en.h |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mr.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/pd.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/port.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/profile.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/qp.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/reset.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/sense.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/srq.c     |    0
 drivers/net/ethernet/micrel/Kconfig                |   51 +
 drivers/net/ethernet/micrel/Makefile               |    8 +
 drivers/net/{ => ethernet/micrel}/ks8842.c         |    0
 drivers/net/{ => ethernet/micrel}/ks8851.c         |    0
 drivers/net/{ => ethernet/micrel}/ks8851.h         |    0
 drivers/net/{ => ethernet/micrel}/ks8851_mll.c     |    0
 drivers/net/{ => ethernet/micrel}/ksz884x.c        |    0
 drivers/net/ethernet/mips/Kconfig                  |   61 +
 drivers/net/ethernet/mips/Makefile                 |   10 +
 drivers/net/{ => ethernet/mips}/au1000_eth.c       |    0
 drivers/net/{ => ethernet/mips}/au1000_eth.h       |    0
 drivers/net/{ => ethernet/mips}/lasi_82596.c       |    0
 drivers/net/{ => ethernet/mips}/mipsnet.c          |    0
 drivers/net/{ => ethernet/mips}/sni_82596.c        |    0
 drivers/net/{ => ethernet/mips}/tc35815.c          |    0
 drivers/net/{ => ethernet/motorola}/82596.c        |    0
 drivers/net/ethernet/motorola/Kconfig              |   88 +
 drivers/net/ethernet/motorola/Makefile             |   13 +
 drivers/net/{ => ethernet/motorola}/fec.c          |    0
 drivers/net/{ => ethernet/motorola}/fec.h          |    0
 drivers/net/{ => ethernet/motorola}/fec_mpc52xx.c  |    0
 drivers/net/{ => ethernet/motorola}/fec_mpc52xx.h  |    0
 .../net/{ => ethernet/motorola}/fec_mpc52xx_phy.c  |    0
 drivers/net/ethernet/myricom/Kconfig               |   42 +
 drivers/net/ethernet/myricom/Makefile              |    5 +
 .../net/{ => ethernet/myricom}/myri10ge/Makefile   |    0
 .../net/{ => ethernet/myricom}/myri10ge/myri10ge.c |    0
 .../{ => ethernet/myricom}/myri10ge/myri10ge_mcp.h |    0
 .../myricom}/myri10ge/myri10ge_mcp_gen_header.h    |    0
 drivers/net/ethernet/natsemi/Kconfig               |   63 +
 drivers/net/ethernet/natsemi/Makefile              |    9 +
 drivers/net/{ => ethernet/natsemi}/jazzsonic.c     |    0
 drivers/net/{ => ethernet/natsemi}/macsonic.c      |    0
 drivers/net/{ => ethernet/natsemi}/natsemi.c       |    0
 drivers/net/{ => ethernet/natsemi}/ns83820.c       |    0
 drivers/net/{ => ethernet/natsemi}/sonic.c         |    0
 drivers/net/{ => ethernet/natsemi}/sonic.h         |    0
 drivers/net/{ => ethernet/natsemi}/xtsonic.c       |    0
 drivers/net/ethernet/neterion/Kconfig              |   50 +
 drivers/net/ethernet/neterion/Makefile             |    6 +
 drivers/net/{ => ethernet/neterion}/s2io-regs.h    |    0
 drivers/net/{ => ethernet/neterion}/s2io.c         |    0
 drivers/net/{ => ethernet/neterion}/s2io.h         |    0
 drivers/net/{ => ethernet/neterion}/vxge/Makefile  |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-config.c |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-config.h |    0
 .../{ => ethernet/neterion}/vxge/vxge-ethtool.c    |    0
 .../{ => ethernet/neterion}/vxge/vxge-ethtool.h    |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-main.c   |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-main.h   |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-reg.h    |    0
 .../{ => ethernet/neterion}/vxge/vxge-traffic.c    |    0
 .../{ => ethernet/neterion}/vxge/vxge-traffic.h    |    0
 .../{ => ethernet/neterion}/vxge/vxge-version.h    |    0
 drivers/net/{ => ethernet}/netx-eth.c              |    0
 drivers/net/{ => ethernet}/octeon/Kconfig          |    0
 drivers/net/{ => ethernet}/octeon/Makefile         |    0
 drivers/net/{ => ethernet}/octeon/octeon_mgmt.c    |    0
 drivers/net/ethernet/oki/Kconfig                   |   18 +
 drivers/net/ethernet/oki/Makefile                  |    5 +
 drivers/net/ethernet/oki/pch_gbe/Kconfig           |   20 +
 drivers/net/{ => ethernet/oki}/pch_gbe/Makefile    |    0
 drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe.h   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.c   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.h   |    0
 .../{ => ethernet/oki}/pch_gbe/pch_gbe_ethtool.c   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_main.c  |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_param.c |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.c   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.h   |    0
 drivers/net/ethernet/packetengines/Kconfig         |   42 +
 drivers/net/ethernet/packetengines/Makefile        |    6 +
 drivers/net/{ => ethernet/packetengines}/hamachi.c |    0
 .../net/{ => ethernet/packetengines}/yellowfin.c   |    0
 drivers/net/{ => ethernet}/pasemi_mac.c            |    0
 drivers/net/{ => ethernet}/pasemi_mac.h            |    0
 drivers/net/{ => ethernet}/pasemi_mac_ethtool.c    |    0
 drivers/net/ethernet/qlogic/Kconfig                |   49 +
 drivers/net/ethernet/qlogic/Makefile               |    8 +
 drivers/net/{ => ethernet/qlogic}/netxen/Makefile  |    0
 .../net/{ => ethernet/qlogic}/netxen/netxen_nic.h  |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_ctx.c  |    0
 .../qlogic}/netxen/netxen_nic_ethtool.c            |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_hdr.h  |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_hw.c   |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_hw.h   |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_init.c |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_main.c |    0
 drivers/net/{ => ethernet/qlogic}/qla3xxx.c        |    0
 drivers/net/{ => ethernet/qlogic}/qla3xxx.h        |    0
 drivers/net/{ => ethernet/qlogic}/qlcnic/Makefile  |    0
 drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic.h  |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_ctx.c  |    0
 .../{ => ethernet/qlogic}/qlcnic/qlcnic_ethtool.c  |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_hdr.h  |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_hw.c   |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_init.c |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_main.c |    0
 drivers/net/{ => ethernet/qlogic}/qlge/Makefile    |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge.h      |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge_dbg.c  |    0
 .../net/{ => ethernet/qlogic}/qlge/qlge_ethtool.c  |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge_main.c |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge_mpi.c  |    0
 drivers/net/{ => ethernet}/r6040.c                 |    0
 drivers/net/ethernet/racal/Kconfig                 |   50 +
 drivers/net/ethernet/racal/Makefile                |    7 +
 drivers/net/{ => ethernet/racal}/ni5010.c          |    0
 drivers/net/{ => ethernet/racal}/ni5010.h          |    0
 drivers/net/{ => ethernet/racal}/ni52.c            |    0
 drivers/net/{ => ethernet/racal}/ni52.h            |    0
 drivers/net/{ => ethernet/racal}/ni65.c            |    0
 drivers/net/{ => ethernet/racal}/ni65.h            |    0
 drivers/net/ethernet/radisys/Kconfig               |   16 +
 drivers/net/ethernet/radisys/Makefile              |    5 +
 drivers/net/{ => ethernet/radisys}/ixp2000/Kconfig |    2 +-
 .../net/{ => ethernet/radisys}/ixp2000/Makefile    |    0
 drivers/net/{ => ethernet/radisys}/ixp2000/caleb.c |    0
 drivers/net/{ => ethernet/radisys}/ixp2000/caleb.h |    0
 .../net/{ => ethernet/radisys}/ixp2000/enp2611.c   |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400-msf.c   |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400-msf.h   |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400_rx.uc   |    0
 .../radisys}/ixp2000/ixp2400_rx.ucode              |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400_tx.uc   |    0
 .../radisys}/ixp2000/ixp2400_tx.ucode              |    0
 .../net/{ => ethernet/radisys}/ixp2000/ixpdev.c    |    0
 .../net/{ => ethernet/radisys}/ixp2000/ixpdev.h    |    0
 .../{ => ethernet/radisys}/ixp2000/ixpdev_priv.h   |    0
 .../net/{ => ethernet/radisys}/ixp2000/pm3386.c    |    0
 .../net/{ => ethernet/radisys}/ixp2000/pm3386.h    |    0
 drivers/net/{ => ethernet/realtek}/8139cp.c        |    0
 drivers/net/{ => ethernet/realtek}/8139too.c       |    0
 drivers/net/ethernet/realtek/Kconfig               |  110 +
 drivers/net/ethernet/realtek/Makefile              |    8 +
 drivers/net/{ => ethernet/realtek}/atp.c           |    0
 drivers/net/{ => ethernet/realtek}/atp.h           |    0
 drivers/net/{ => ethernet/realtek}/r8169.c         |    0
 drivers/net/ethernet/renesas/Kconfig               |   18 +
 drivers/net/ethernet/renesas/Makefile              |    5 +
 drivers/net/{ => ethernet/renesas}/sh_eth.c        |    0
 drivers/net/{ => ethernet/renesas}/sh_eth.h        |    0
 drivers/net/{ => ethernet}/s6gmac.c                |    0
 drivers/net/{ => ethernet}/sc92031.c               |    0
 drivers/net/{ => ethernet}/sfc/Kconfig             |    0
 drivers/net/{ => ethernet}/sfc/Makefile            |    0
 drivers/net/{ => ethernet}/sfc/bitfield.h          |    0
 drivers/net/{ => ethernet}/sfc/efx.c               |    0
 drivers/net/{ => ethernet}/sfc/efx.h               |    0
 drivers/net/{ => ethernet}/sfc/enum.h              |    0
 drivers/net/{ => ethernet}/sfc/ethtool.c           |    0
 drivers/net/{ => ethernet}/sfc/falcon.c            |    0
 drivers/net/{ => ethernet}/sfc/falcon_boards.c     |    0
 drivers/net/{ => ethernet}/sfc/falcon_xmac.c       |    0
 drivers/net/{ => ethernet}/sfc/filter.c            |    0
 drivers/net/{ => ethernet}/sfc/filter.h            |    0
 drivers/net/{ => ethernet}/sfc/io.h                |    0
 drivers/net/{ => ethernet}/sfc/mac.h               |    0
 drivers/net/{ => ethernet}/sfc/mcdi.c              |    0
 drivers/net/{ => ethernet}/sfc/mcdi.h              |    0
 drivers/net/{ => ethernet}/sfc/mcdi_mac.c          |    0
 drivers/net/{ => ethernet}/sfc/mcdi_pcol.h         |    0
 drivers/net/{ => ethernet}/sfc/mcdi_phy.c          |    0
 drivers/net/{ => ethernet}/sfc/mdio_10g.c          |    0
 drivers/net/{ => ethernet}/sfc/mdio_10g.h          |    0
 drivers/net/{ => ethernet}/sfc/mtd.c               |    0
 drivers/net/{ => ethernet}/sfc/net_driver.h        |    0
 drivers/net/{ => ethernet}/sfc/nic.c               |    0
 drivers/net/{ => ethernet}/sfc/nic.h               |    0
 drivers/net/{ => ethernet}/sfc/phy.h               |    0
 drivers/net/{ => ethernet}/sfc/qt202x_phy.c        |    0
 drivers/net/{ => ethernet}/sfc/regs.h              |    0
 drivers/net/{ => ethernet}/sfc/rx.c                |    0
 drivers/net/{ => ethernet}/sfc/selftest.c          |    0
 drivers/net/{ => ethernet}/sfc/selftest.h          |    0
 drivers/net/{ => ethernet}/sfc/siena.c             |    0
 drivers/net/{ => ethernet}/sfc/spi.h               |    0
 drivers/net/{ => ethernet}/sfc/tenxpress.c         |    0
 drivers/net/{ => ethernet}/sfc/tx.c                |    0
 drivers/net/{ => ethernet}/sfc/txc43128_phy.c      |    0
 drivers/net/{ => ethernet}/sfc/workarounds.h       |    0
 drivers/net/ethernet/sgi/Kconfig                   |   37 +
 drivers/net/ethernet/sgi/Makefile                  |    7 +
 drivers/net/{ => ethernet/sgi}/ioc3-eth.c          |    0
 drivers/net/{ => ethernet/sgi}/meth.c              |    0
 drivers/net/{ => ethernet/sgi}/meth.h              |    0
 drivers/net/{ => ethernet/sgi}/sgiseeq.c           |    0
 drivers/net/{ => ethernet/sgi}/sgiseeq.h           |    0
 drivers/net/ethernet/sis/Kconfig                   |   46 +
 drivers/net/ethernet/sis/Makefile                  |    6 +
 drivers/net/{ => ethernet/sis}/sis190.c            |    0
 drivers/net/{ => ethernet/sis}/sis900.c            |    0
 drivers/net/{ => ethernet/sis}/sis900.h            |    0
 drivers/net/ethernet/smc/Kconfig                   |   61 +
 drivers/net/ethernet/smc/Makefile                  |    7 +
 drivers/net/{ => ethernet/smc}/epic100.c           |    0
 drivers/net/{ => ethernet/smc}/smc9194.c           |    0
 drivers/net/{ => ethernet/smc}/smc9194.h           |    0
 drivers/net/{ => ethernet/smc}/smc91x.c            |    0
 drivers/net/{ => ethernet/smc}/smc91x.h            |    0
 drivers/net/ethernet/smsc/Kconfig                  |   71 +
 drivers/net/ethernet/smsc/Makefile                 |    7 +
 drivers/net/{ => ethernet/smsc}/smc911x.c          |    0
 drivers/net/{ => ethernet/smsc}/smc911x.h          |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.c         |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.h         |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.c         |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.h         |    0
 drivers/net/ethernet/sony/Kconfig                  |   38 +
 drivers/net/ethernet/sony/Makefile                 |    7 +
 drivers/net/{ => ethernet/sony}/ps3_gelic_net.c    |    0
 drivers/net/{ => ethernet/sony}/ps3_gelic_net.h    |    0
 .../net/{ => ethernet/sony}/ps3_gelic_wireless.c   |    0
 .../net/{ => ethernet/sony}/ps3_gelic_wireless.h   |    0
 drivers/net/{ => ethernet}/starfire.c              |    0
 drivers/net/ethernet/stmicro/Kconfig               |   18 +
 drivers/net/ethernet/stmicro/Makefile              |    5 +
 drivers/net/{ => ethernet/stmicro}/stmmac/Kconfig  |   14 +-
 drivers/net/{ => ethernet/stmicro}/stmmac/Makefile |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/common.h |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/descs.h  |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac100.h   |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac1000.h  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac1000_core.c |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac1000_dma.c  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac100_core.c  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac100_dma.c   |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac_dma.h  |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac_lib.c  |    0
 .../net/{ => ethernet/stmicro}/stmmac/enh_desc.c   |    0
 .../net/{ => ethernet/stmicro}/stmmac/norm_desc.c  |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/stmmac.h |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_ethtool.c |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_main.c    |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_mdio.c    |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_timer.c   |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_timer.h   |    0
 drivers/net/ethernet/sun/Kconfig                   |   91 +
 drivers/net/ethernet/sun/Makefile                  |   12 +
 drivers/net/{ => ethernet/sun}/cassini.c           |    0
 drivers/net/{ => ethernet/sun}/cassini.h           |    0
 drivers/net/{ => ethernet/sun}/niu.c               |    0
 drivers/net/{ => ethernet/sun}/niu.h               |    0
 drivers/net/{ => ethernet/sun}/sun3_82586.c        |    0
 drivers/net/{ => ethernet/sun}/sun3_82586.h        |    0
 drivers/net/{ => ethernet/sun}/sunbmac.c           |    0
 drivers/net/{ => ethernet/sun}/sunbmac.h           |    0
 drivers/net/{ => ethernet/sun}/sungem.c            |    0
 drivers/net/{ => ethernet/sun}/sungem.h            |    0
 drivers/net/{ => ethernet/sun}/sungem_phy.c        |    0
 drivers/net/{ => ethernet/sun}/sungem_phy.h        |    0
 drivers/net/{ => ethernet/sun}/sunhme.c            |    0
 drivers/net/{ => ethernet/sun}/sunhme.h            |    0
 drivers/net/{ => ethernet/sun}/sunqe.c             |    0
 drivers/net/{ => ethernet/sun}/sunqe.h             |    0
 drivers/net/{ => ethernet/sun}/sunvnet.c           |    0
 drivers/net/{ => ethernet/sun}/sunvnet.h           |    0
 drivers/net/{ => ethernet}/sundance.c              |    0
 drivers/net/ethernet/syskonnect/Kconfig            |   74 +
 drivers/net/ethernet/syskonnect/Makefile           |    6 +
 drivers/net/{ => ethernet/syskonnect}/skge.c       |    0
 drivers/net/{ => ethernet/syskonnect}/skge.h       |    0
 drivers/net/{ => ethernet/syskonnect}/sky2.c       |    0
 drivers/net/{ => ethernet/syskonnect}/sky2.h       |    0
 drivers/net/{ => ethernet}/tehuti.c                |    0
 drivers/net/{ => ethernet}/tehuti.h                |    0
 drivers/net/ethernet/ti/Kconfig                    |   41 +
 drivers/net/ethernet/ti/Makefile                   |    6 +
 drivers/net/{ => ethernet/ti}/cpmac.c              |    0
 drivers/net/{ => ethernet/ti}/tlan.c               |    0
 drivers/net/{ => ethernet/ti}/tlan.h               |    0
 drivers/net/{ => ethernet}/tsi108_eth.c            |    0
 drivers/net/{ => ethernet}/tsi108_eth.h            |    0
 drivers/net/{ => ethernet}/tulip/21142.c           |    0
 drivers/net/{ => ethernet}/tulip/Kconfig           |   34 +-
 drivers/net/{ => ethernet}/tulip/Makefile          |    0
 drivers/net/{ => ethernet}/tulip/de2104x.c         |    0
 drivers/net/{ => ethernet}/tulip/de4x5.c           |    0
 drivers/net/{ => ethernet}/tulip/de4x5.h           |    0
 drivers/net/{ => ethernet}/tulip/dmfe.c            |    0
 drivers/net/{ => ethernet}/tulip/eeprom.c          |    0
 drivers/net/{ => ethernet}/tulip/interrupt.c       |    0
 drivers/net/{ => ethernet}/tulip/media.c           |    0
 drivers/net/{ => ethernet}/tulip/pnic.c            |    0
 drivers/net/{ => ethernet}/tulip/pnic2.c           |    0
 drivers/net/{ => ethernet}/tulip/timer.c           |    0
 drivers/net/{ => ethernet}/tulip/tulip.h           |    0
 drivers/net/{ => ethernet}/tulip/tulip_core.c      |    0
 drivers/net/{ => ethernet}/tulip/uli526x.c         |    0
 drivers/net/{ => ethernet}/tulip/winbond-840.c     |    0
 drivers/net/{ => ethernet}/tulip/xircom_cb.c       |    0
 drivers/net/ethernet/via/Kconfig                   |   52 +
 drivers/net/ethernet/via/Makefile                  |    6 +
 drivers/net/{ => ethernet/via}/via-rhine.c         |    0
 drivers/net/{ => ethernet/via}/via-velocity.c      |    0
 drivers/net/{ => ethernet/via}/via-velocity.h      |    0
 drivers/net/ethernet/xilinx/Kconfig                |   31 +
 drivers/net/ethernet/xilinx/Makefile               |    7 +
 drivers/net/{ => ethernet/xilinx}/ll_temac.h       |    0
 drivers/net/{ => ethernet/xilinx}/ll_temac_main.c  |    0
 drivers/net/{ => ethernet/xilinx}/ll_temac_mdio.c  |    0
 .../net/{ => ethernet/xilinx}/xilinx_emaclite.c    |    0
 drivers/net/pcmcia/Kconfig                         |   39 -
 drivers/net/pcmcia/Makefile                        |    4 -
 drivers/scsi/bnx2fc/bnx2fc.h                       |    2 +-
 drivers/scsi/bnx2i/bnx2i.h                         |    2 +-
 drivers/scsi/cxgbi/cxgb3i/Kbuild                   |    2 +-
 drivers/scsi/cxgbi/cxgb4i/Kbuild                   |    2 +-
 872 files changed, 4096 insertions(+), 3223 deletions(-)
 delete mode 100644 drivers/net/arm/Kconfig
 delete mode 100644 drivers/net/benet/Kconfig
 rename drivers/net/{ => ethernet/3com}/3c501.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c501.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c503.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c503.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c505.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c505.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c507.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c509.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c515.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c523.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c523.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c527.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c527.h (100%)
 rename drivers/net/{pcmcia => ethernet/3com}/3c574_cs.c (100%)
 rename drivers/net/{pcmcia => ethernet/3com}/3c589_cs.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c59x.c (100%)
 create mode 100644 drivers/net/ethernet/3com/Kconfig
 create mode 100644 drivers/net/ethernet/3com/Makefile
 rename drivers/net/{ => ethernet/3com}/acenic.c (100%)
 rename drivers/net/{ => ethernet/3com}/acenic.h (100%)
 rename drivers/net/{ => ethernet/3com}/typhoon.c (100%)
 rename drivers/net/{ => ethernet/3com}/typhoon.h (100%)
 rename drivers/net/{ => ethernet/8390}/8390.c (100%)
 rename drivers/net/{ => ethernet/8390}/8390.h (100%)
 rename drivers/net/{ => ethernet/8390}/8390p.c (100%)
 create mode 100644 drivers/net/ethernet/8390/Kconfig
 create mode 100644 drivers/net/ethernet/8390/Makefile
 rename drivers/net/{ => ethernet/8390}/ac3200.c (100%)
 rename drivers/net/{ => ethernet/8390}/apne.c (100%)
 rename drivers/net/{ => ethernet/8390}/ax88796.c (100%)
 rename drivers/net/{pcmcia => ethernet/8390}/axnet_cs.c (99%)
 rename drivers/net/{ => ethernet/8390}/e2100.c (100%)
 rename drivers/net/{ => ethernet/8390}/es3210.c (100%)
 rename drivers/net/{ => ethernet/8390}/hp-plus.c (100%)
 rename drivers/net/{ => ethernet/8390}/hp.c (100%)
 rename drivers/net/{ => ethernet/8390}/hydra.c (100%)
 rename drivers/net/{ => ethernet/8390}/lib8390.c (100%)
 rename drivers/net/{ => ethernet/8390}/lne390.c (100%)
 rename drivers/net/{ => ethernet/8390}/mac8390.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne-h8300.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne2.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne2k-pci.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne3210.c (100%)
 rename drivers/net/{pcmcia => ethernet/8390}/pcnet_cs.c (99%)
 rename drivers/net/{ => ethernet/8390}/smc-mca.c (100%)
 rename drivers/net/{ => ethernet/8390}/smc-ultra.c (100%)
 rename drivers/net/{ => ethernet/8390}/smc-ultra32.c (100%)
 rename drivers/net/{ => ethernet/8390}/stnic.c (100%)
 rename drivers/net/{ => ethernet/8390}/wd.c (100%)
 rename drivers/net/{ => ethernet/8390}/zorro8390.c (100%)
 create mode 100644 drivers/net/ethernet/Kconfig
 create mode 100644 drivers/net/ethernet/Makefile
 rename drivers/net/{ => ethernet}/a2065.c (100%)
 rename drivers/net/{ => ethernet}/a2065.h (100%)
 create mode 100644 drivers/net/ethernet/aeroflex/Kconfig
 create mode 100644 drivers/net/ethernet/aeroflex/Makefile
 rename drivers/net/{ => ethernet/aeroflex}/greth.c (100%)
 rename drivers/net/{ => ethernet/aeroflex}/greth.h (100%)
 rename drivers/net/{ => ethernet/amd}/7990.c (100%)
 rename drivers/net/{ => ethernet/amd}/7990.h (100%)
 create mode 100644 drivers/net/ethernet/amd/Kconfig
 create mode 100644 drivers/net/ethernet/amd/Makefile
 rename drivers/net/{ => ethernet/amd}/amd8111e.c (100%)
 rename drivers/net/{ => ethernet/amd}/amd8111e.h (100%)
 rename drivers/net/{ => ethernet/amd}/atarilance.c (100%)
 rename drivers/net/{ => ethernet/amd}/declance.c (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.c (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.h (100%)
 rename drivers/net/{ => ethernet/amd}/lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/mvme147.c (100%)
 rename drivers/net/{ => ethernet/amd}/pcnet32.c (100%)
 rename drivers/net/{ => ethernet/amd}/sun3lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/sunlance.c (100%)
 create mode 100644 drivers/net/ethernet/apple/Kconfig
 create mode 100644 drivers/net/ethernet/apple/Makefile
 rename drivers/net/{ => ethernet/apple}/bmac.c (100%)
 rename drivers/net/{ => ethernet/apple}/bmac.h (100%)
 rename drivers/net/{ => ethernet/apple}/cs89x0.c (100%)
 rename drivers/net/{ => ethernet/apple}/cs89x0.h (100%)
 rename drivers/net/{ => ethernet/apple}/mac89x0.c (100%)
 rename drivers/net/{ => ethernet/apple}/mace.c (100%)
 rename drivers/net/{ => ethernet/apple}/mace.h (100%)
 rename drivers/net/{ => ethernet/apple}/macmace.c (100%)
 rename drivers/net/{ => ethernet}/ariadne.c (100%)
 rename drivers/net/{ => ethernet}/ariadne.h (100%)
 create mode 100644 drivers/net/ethernet/arm/Kconfig
 rename drivers/net/{ => ethernet}/arm/Makefile (74%)
 rename drivers/net/{ => ethernet}/arm/am79c961a.c (100%)
 rename drivers/net/{ => ethernet}/arm/am79c961a.h (100%)
 rename drivers/net/{ => ethernet}/arm/at91_ether.c (100%)
 rename drivers/net/{ => ethernet}/arm/at91_ether.h (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_cpdma.c (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_cpdma.h (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_emac.c (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_mdio.c (100%)
 rename drivers/net/{ => ethernet}/arm/ep93xx_eth.c (100%)
 rename drivers/net/{ => ethernet}/arm/ether1.c (100%)
 rename drivers/net/{ => ethernet}/arm/ether1.h (100%)
 rename drivers/net/{ => ethernet}/arm/ether3.c (100%)
 rename drivers/net/{ => ethernet}/arm/ether3.h (100%)
 rename drivers/net/{ => ethernet}/arm/etherh.c (100%)
 rename drivers/net/{ => ethernet}/arm/ixp4xx_eth.c (100%)
 rename drivers/net/{ => ethernet}/arm/ks8695net.c (100%)
 rename drivers/net/{ => ethernet}/arm/ks8695net.h (100%)
 rename drivers/net/{ => ethernet}/arm/w90p910_ether.c (100%)
 rename drivers/net/{ => ethernet}/at1700.c (100%)
 create mode 100644 drivers/net/ethernet/atheros/Kconfig
 create mode 100644 drivers/net/ethernet/atheros/Makefile
 rename drivers/net/{ => ethernet/atheros}/atl1c/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_ethtool.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_hw.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_hw.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_main.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_ethtool.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_hw.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_hw.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_main.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_param.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl1.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl1.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl2.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl2.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atlx.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atlx.h (100%)
 create mode 100644 drivers/net/ethernet/atmel/Kconfig
 create mode 100644 drivers/net/ethernet/atmel/Makefile
 rename drivers/net/{ => ethernet/atmel}/macb.c (100%)
 rename drivers/net/{ => ethernet/atmel}/macb.h (100%)
 create mode 100644 drivers/net/ethernet/blackfin/Kconfig
 create mode 100644 drivers/net/ethernet/blackfin/Makefile
 rename drivers/net/{ => ethernet/blackfin}/bfin_mac.c (100%)
 rename drivers/net/{ => ethernet/blackfin}/bfin_mac.h (100%)
 create mode 100644 drivers/net/ethernet/broadcom/Kconfig
 create mode 100644 drivers/net/ethernet/broadcom/Makefile
 rename drivers/net/{ => ethernet/broadcom}/b44.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/b44.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2_fw.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/Makefile (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_dump.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_ethtool.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_fw_defs.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_fw_file_hdr.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_hsi.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_init.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_init_ops.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_main.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_reg.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_stats.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_stats.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/cnic.c (99%)
 rename drivers/net/{ => ethernet/broadcom}/cnic.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/cnic_defs.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/cnic_if.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/sb1250-mac.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/tg3.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/tg3.h (100%)
 create mode 100644 drivers/net/ethernet/brocade/Kconfig
 create mode 100644 drivers/net/ethernet/brocade/Makefile
 create mode 100644 drivers/net/ethernet/brocade/bna/Kconfig
 rename drivers/net/{ => ethernet/brocade}/bna/Makefile (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_cee.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_cee.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_mfg_comm.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_status.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc_ct.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_sm.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_wc.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_ctreg.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_ll.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_ctrl.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_hw.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_txrx.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_types.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad_ethtool.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/cna_fwimg.c (100%)
 create mode 100644 drivers/net/ethernet/chelsio/Kconfig
 create mode 100644 drivers/net/ethernet/chelsio/Makefile
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/Makefile (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/common.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/cphy.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/cpl5_cmd.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/cxgb2.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/elmer0.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/espi.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/espi.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/fpga_defs.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/gmac.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/mv88x201x.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/my3126.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/pm3393.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/regs.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/sge.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/sge.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/subr.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/suni1x10gexp_regs.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/tp.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/tp.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/vsc7326.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/vsc7326_reg.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/Makefile (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/adapter.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/ael1002.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/aq100x.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/common.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_ctl_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_ioctl.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_main.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_offload.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_offload.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/firmware_exports.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/mc5.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/regs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/sge.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/sge_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/t3_cpl.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/t3_hw.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/t3cdev.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/version.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/vsc8211.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/xgmac.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/Makefile (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4_main.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4_uld.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/sge.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_msg.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_regs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4fw_api.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/Makefile (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/adapter.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/cxgb4vf_main.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/sge.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/t4vf_common.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/t4vf_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/t4vf_hw.c (100%)
 create mode 100644 drivers/net/ethernet/cisco/Kconfig
 create mode 100644 drivers/net/ethernet/cisco/Makefile
 create mode 100644 drivers/net/ethernet/cisco/enic/Kconfig
 rename drivers/net/{ => ethernet/cisco}/enic/Makefile (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/cq_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/cq_enet_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_dev.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_dev.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_main.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_pp.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_pp.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_res.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_res.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/rq_enet_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_cq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_cq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_dev.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_dev.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_devcmd.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_enet.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_intr.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_intr.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_nic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_resource.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rss.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_stats.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_vic.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_vic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_wq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_wq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/wq_enet_desc.h (100%)
 create mode 100644 drivers/net/ethernet/davicom/Kconfig
 create mode 100644 drivers/net/ethernet/davicom/Makefile
 rename drivers/net/{ => ethernet/davicom}/dm9000.c (100%)
 rename drivers/net/{ => ethernet/davicom}/dm9000.h (100%)
 rename drivers/net/{ => ethernet}/depca.c (100%)
 rename drivers/net/{ => ethernet}/depca.h (100%)
 create mode 100644 drivers/net/ethernet/dlink/Kconfig
 create mode 100644 drivers/net/ethernet/dlink/Makefile
 rename drivers/net/{ => ethernet/dlink}/de600.c (100%)
 rename drivers/net/{ => ethernet/dlink}/de600.h (100%)
 rename drivers/net/{ => ethernet/dlink}/de620.c (100%)
 rename drivers/net/{ => ethernet/dlink}/de620.h (100%)
 rename drivers/net/{ => ethernet/dlink}/dl2k.c (100%)
 rename drivers/net/{ => ethernet/dlink}/dl2k.h (100%)
 rename drivers/net/{ => ethernet}/dnet.c (100%)
 rename drivers/net/{ => ethernet}/dnet.h (100%)
 create mode 100644 drivers/net/ethernet/emulex/Kconfig
 create mode 100644 drivers/net/ethernet/emulex/Makefile
 create mode 100644 drivers/net/ethernet/emulex/benet/Kconfig
 rename drivers/net/{ => ethernet/emulex}/benet/Makefile (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_cmds.c (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_cmds.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_ethtool.c (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_hw.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_main.c (100%)
 rename drivers/net/{ => ethernet}/enc28j60.c (100%)
 rename drivers/net/{ => ethernet}/enc28j60_hw.h (100%)
 rename drivers/net/{ => ethernet}/ethoc.c (100%)
 create mode 100644 drivers/net/ethernet/faraday/Kconfig
 create mode 100644 drivers/net/ethernet/faraday/Makefile
 rename drivers/net/{ => ethernet/faraday}/ftgmac100.c (100%)
 rename drivers/net/{ => ethernet/faraday}/ftgmac100.h (100%)
 rename drivers/net/{ => ethernet/faraday}/ftmac100.c (100%)
 rename drivers/net/{ => ethernet/faraday}/ftmac100.h (100%)
 rename drivers/net/{ => ethernet}/fealnx.c (100%)
 rename drivers/net/{ => ethernet}/forcedeth.c (100%)
 create mode 100644 drivers/net/ethernet/freescale/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/Makefile
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
 rename drivers/net/{ => ethernet}/hp100.c (100%)
 rename drivers/net/{ => ethernet}/hp100.h (100%)
 create mode 100644 drivers/net/ethernet/ibm/Kconfig
 create mode 100644 drivers/net/ethernet/ibm/Makefile
 rename drivers/net/{ => ethernet/ibm}/ehea/Makefile (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/Kconfig (97%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/Makefile (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/core.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/core.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/emac.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmlana.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmlana.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.h (100%)
 rename drivers/net/{ => ethernet/ibm}/spider_net.c (100%)
 rename drivers/net/{ => ethernet/ibm}/spider_net.h (99%)
 rename drivers/net/{ => ethernet/ibm}/spider_net_ethtool.c (100%)
 create mode 100644 drivers/net/ethernet/icplus/Kconfig
 create mode 100644 drivers/net/ethernet/icplus/Makefile
 rename drivers/net/{ => ethernet/icplus}/ipg.c (100%)
 rename drivers/net/{ => ethernet/icplus}/ipg.h (100%)
 create mode 100644 drivers/net/ethernet/intel/Kconfig
 create mode 100644 drivers/net/ethernet/intel/Makefile
 rename drivers/net/{ => ethernet/intel}/e100.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_hw.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_osdep.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_param.c (100%)
 rename drivers/net/{e1000e/es2lan.c => ethernet/intel/e1000e/80003es2lan.c} (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/82571.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/Makefile (92%)
 rename drivers/net/{ => ethernet/intel}/e1000e/defines.h (100%)
 rename drivers/net/{e1000e/e1000.h => ethernet/intel/e1000e/e1000e.h} (100%)
 rename drivers/net/{e1000e/netdev.c => ethernet/intel/e1000e/e1000e_main.c} (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/ethtool.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/ich8lan.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/lib.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/param.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/phy.c (99%)
 rename drivers/net/{ => ethernet/intel}/igb/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_82575.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_82575.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_defines.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mac.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mac.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_nvm.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_nvm.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_phy.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_phy.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_regs.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/igb.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/igb_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/igb_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/defines.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/igbvf.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/netdev.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/regs.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/vf.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/vf.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ids.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_osdep.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_param.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_82598.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_82599.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_common.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_common.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_nl.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_type.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_x540.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/defines.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/ixgbevf.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/ixgbevf_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/regs.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/vf.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/vf.h (100%)
 create mode 100644 drivers/net/ethernet/isa/Kconfig
 create mode 100644 drivers/net/ethernet/isa/Makefile
 rename drivers/net/{ => ethernet/isa}/eepro.c (100%)
 rename drivers/net/{ => ethernet/isa}/eexpress.c (100%)
 rename drivers/net/{ => ethernet/isa}/eexpress.h (100%)
 rename drivers/net/{ => ethernet/isa}/eth16i.c (100%)
 rename drivers/net/{ => ethernet/isa}/ewrk3.c (100%)
 rename drivers/net/{ => ethernet/isa}/ewrk3.h (100%)
 rename drivers/net/{ => ethernet/isa}/lp486e.c (100%)
 rename drivers/net/{ => ethernet/isa}/seeq8005.c (100%)
 rename drivers/net/{ => ethernet/isa}/seeq8005.h (100%)
 rename drivers/net/{ => ethernet/isa}/znet.c (100%)
 rename drivers/net/{ => ethernet}/jme.c (100%)
 rename drivers/net/{ => ethernet}/jme.h (100%)
 rename drivers/net/{ => ethernet}/korina.c (100%)
 create mode 100644 drivers/net/ethernet/marvell/Kconfig
 create mode 100644 drivers/net/ethernet/marvell/Makefile
 rename drivers/net/{ => ethernet/marvell}/mv643xx_eth.c (100%)
 rename drivers/net/{ => ethernet/marvell}/pxa168_eth.c (100%)
 create mode 100644 drivers/net/ethernet/mellanox/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/Kconfig
 rename drivers/net/{ => ethernet/mellanox}/mlx4/Makefile (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/alloc.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/catas.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/cmd.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/cq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_cq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_ethtool.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_main.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_netdev.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_port.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_port.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_resources.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_rx.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_selftest.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_tx.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/eq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/fw.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/fw.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/icm.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/icm.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/intf.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/main.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mcg.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mlx4.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mlx4_en.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mr.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/pd.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/port.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/profile.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/qp.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/reset.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/sense.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/srq.c (100%)
 create mode 100644 drivers/net/ethernet/micrel/Kconfig
 create mode 100644 drivers/net/ethernet/micrel/Makefile
 rename drivers/net/{ => ethernet/micrel}/ks8842.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.h (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851_mll.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ksz884x.c (100%)
 create mode 100644 drivers/net/ethernet/mips/Kconfig
 create mode 100644 drivers/net/ethernet/mips/Makefile
 rename drivers/net/{ => ethernet/mips}/au1000_eth.c (100%)
 rename drivers/net/{ => ethernet/mips}/au1000_eth.h (100%)
 rename drivers/net/{ => ethernet/mips}/lasi_82596.c (100%)
 rename drivers/net/{ => ethernet/mips}/mipsnet.c (100%)
 rename drivers/net/{ => ethernet/mips}/sni_82596.c (100%)
 rename drivers/net/{ => ethernet/mips}/tc35815.c (100%)
 rename drivers/net/{ => ethernet/motorola}/82596.c (100%)
 create mode 100644 drivers/net/ethernet/motorola/Kconfig
 create mode 100644 drivers/net/ethernet/motorola/Makefile
 rename drivers/net/{ => ethernet/motorola}/fec.c (100%)
 rename drivers/net/{ => ethernet/motorola}/fec.h (100%)
 rename drivers/net/{ => ethernet/motorola}/fec_mpc52xx.c (100%)
 rename drivers/net/{ => ethernet/motorola}/fec_mpc52xx.h (100%)
 rename drivers/net/{ => ethernet/motorola}/fec_mpc52xx_phy.c (100%)
 create mode 100644 drivers/net/ethernet/myricom/Kconfig
 create mode 100644 drivers/net/ethernet/myricom/Makefile
 rename drivers/net/{ => ethernet/myricom}/myri10ge/Makefile (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge.c (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge_mcp.h (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge_mcp_gen_header.h (100%)
 create mode 100644 drivers/net/ethernet/natsemi/Kconfig
 create mode 100644 drivers/net/ethernet/natsemi/Makefile
 rename drivers/net/{ => ethernet/natsemi}/jazzsonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/macsonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/natsemi.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/ns83820.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/sonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/sonic.h (100%)
 rename drivers/net/{ => ethernet/natsemi}/xtsonic.c (100%)
 create mode 100644 drivers/net/ethernet/neterion/Kconfig
 create mode 100644 drivers/net/ethernet/neterion/Makefile
 rename drivers/net/{ => ethernet/neterion}/s2io-regs.h (100%)
 rename drivers/net/{ => ethernet/neterion}/s2io.c (100%)
 rename drivers/net/{ => ethernet/neterion}/s2io.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/Makefile (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-config.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-config.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-ethtool.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-ethtool.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-main.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-main.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-reg.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-traffic.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-traffic.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-version.h (100%)
 rename drivers/net/{ => ethernet}/netx-eth.c (100%)
 rename drivers/net/{ => ethernet}/octeon/Kconfig (100%)
 rename drivers/net/{ => ethernet}/octeon/Makefile (100%)
 rename drivers/net/{ => ethernet}/octeon/octeon_mgmt.c (100%)
 create mode 100644 drivers/net/ethernet/oki/Kconfig
 create mode 100644 drivers/net/ethernet/oki/Makefile
 create mode 100644 drivers/net/ethernet/oki/pch_gbe/Kconfig
 rename drivers/net/{ => ethernet/oki}/pch_gbe/Makefile (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe.h (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.h (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_ethtool.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_main.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_param.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.h (100%)
 create mode 100644 drivers/net/ethernet/packetengines/Kconfig
 create mode 100644 drivers/net/ethernet/packetengines/Makefile
 rename drivers/net/{ => ethernet/packetengines}/hamachi.c (100%)
 rename drivers/net/{ => ethernet/packetengines}/yellowfin.c (100%)
 rename drivers/net/{ => ethernet}/pasemi_mac.c (100%)
 rename drivers/net/{ => ethernet}/pasemi_mac.h (100%)
 rename drivers/net/{ => ethernet}/pasemi_mac_ethtool.c (100%)
 create mode 100644 drivers/net/ethernet/qlogic/Kconfig
 create mode 100644 drivers/net/ethernet/qlogic/Makefile
 rename drivers/net/{ => ethernet/qlogic}/netxen/Makefile (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_ctx.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_ethtool.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_hdr.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_hw.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_hw.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_init.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_main.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qla3xxx.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qla3xxx.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/Makefile (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_ctx.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_ethtool.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_hdr.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_hw.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_init.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_main.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/Makefile (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_dbg.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_ethtool.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_main.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_mpi.c (100%)
 rename drivers/net/{ => ethernet}/r6040.c (100%)
 create mode 100644 drivers/net/ethernet/racal/Kconfig
 create mode 100644 drivers/net/ethernet/racal/Makefile
 rename drivers/net/{ => ethernet/racal}/ni5010.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni5010.h (100%)
 rename drivers/net/{ => ethernet/racal}/ni52.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni52.h (100%)
 rename drivers/net/{ => ethernet/racal}/ni65.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni65.h (100%)
 create mode 100644 drivers/net/ethernet/radisys/Kconfig
 create mode 100644 drivers/net/ethernet/radisys/Makefile
 rename drivers/net/{ => ethernet/radisys}/ixp2000/Kconfig (80%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/Makefile (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/caleb.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/caleb.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/enp2611.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400-msf.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400-msf.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_rx.uc (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_rx.ucode (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_tx.uc (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_tx.ucode (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixpdev.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixpdev.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixpdev_priv.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/pm3386.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/pm3386.h (100%)
 rename drivers/net/{ => ethernet/realtek}/8139cp.c (100%)
 rename drivers/net/{ => ethernet/realtek}/8139too.c (100%)
 create mode 100644 drivers/net/ethernet/realtek/Kconfig
 create mode 100644 drivers/net/ethernet/realtek/Makefile
 rename drivers/net/{ => ethernet/realtek}/atp.c (100%)
 rename drivers/net/{ => ethernet/realtek}/atp.h (100%)
 rename drivers/net/{ => ethernet/realtek}/r8169.c (100%)
 create mode 100644 drivers/net/ethernet/renesas/Kconfig
 create mode 100644 drivers/net/ethernet/renesas/Makefile
 rename drivers/net/{ => ethernet/renesas}/sh_eth.c (100%)
 rename drivers/net/{ => ethernet/renesas}/sh_eth.h (100%)
 rename drivers/net/{ => ethernet}/s6gmac.c (100%)
 rename drivers/net/{ => ethernet}/sc92031.c (100%)
 rename drivers/net/{ => ethernet}/sfc/Kconfig (100%)
 rename drivers/net/{ => ethernet}/sfc/Makefile (100%)
 rename drivers/net/{ => ethernet}/sfc/bitfield.h (100%)
 rename drivers/net/{ => ethernet}/sfc/efx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/efx.h (100%)
 rename drivers/net/{ => ethernet}/sfc/enum.h (100%)
 rename drivers/net/{ => ethernet}/sfc/ethtool.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon_boards.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon_xmac.c (100%)
 rename drivers/net/{ => ethernet}/sfc/filter.c (100%)
 rename drivers/net/{ => ethernet}/sfc/filter.h (100%)
 rename drivers/net/{ => ethernet}/sfc/io.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mac.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_mac.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_pcol.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mdio_10g.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mdio_10g.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mtd.c (100%)
 rename drivers/net/{ => ethernet}/sfc/net_driver.h (100%)
 rename drivers/net/{ => ethernet}/sfc/nic.c (100%)
 rename drivers/net/{ => ethernet}/sfc/nic.h (100%)
 rename drivers/net/{ => ethernet}/sfc/phy.h (100%)
 rename drivers/net/{ => ethernet}/sfc/qt202x_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/regs.h (100%)
 rename drivers/net/{ => ethernet}/sfc/rx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/selftest.c (100%)
 rename drivers/net/{ => ethernet}/sfc/selftest.h (100%)
 rename drivers/net/{ => ethernet}/sfc/siena.c (100%)
 rename drivers/net/{ => ethernet}/sfc/spi.h (100%)
 rename drivers/net/{ => ethernet}/sfc/tenxpress.c (100%)
 rename drivers/net/{ => ethernet}/sfc/tx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/txc43128_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/workarounds.h (100%)
 create mode 100644 drivers/net/ethernet/sgi/Kconfig
 create mode 100644 drivers/net/ethernet/sgi/Makefile
 rename drivers/net/{ => ethernet/sgi}/ioc3-eth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.h (100%)
 rename drivers/net/{ => ethernet/sgi}/sgiseeq.c (100%)
 rename drivers/net/{ => ethernet/sgi}/sgiseeq.h (100%)
 create mode 100644 drivers/net/ethernet/sis/Kconfig
 create mode 100644 drivers/net/ethernet/sis/Makefile
 rename drivers/net/{ => ethernet/sis}/sis190.c (100%)
 rename drivers/net/{ => ethernet/sis}/sis900.c (100%)
 rename drivers/net/{ => ethernet/sis}/sis900.h (100%)
 create mode 100644 drivers/net/ethernet/smc/Kconfig
 create mode 100644 drivers/net/ethernet/smc/Makefile
 rename drivers/net/{ => ethernet/smc}/epic100.c (100%)
 rename drivers/net/{ => ethernet/smc}/smc9194.c (100%)
 rename drivers/net/{ => ethernet/smc}/smc9194.h (100%)
 rename drivers/net/{ => ethernet/smc}/smc91x.c (100%)
 rename drivers/net/{ => ethernet/smc}/smc91x.h (100%)
 create mode 100644 drivers/net/ethernet/smsc/Kconfig
 create mode 100644 drivers/net/ethernet/smsc/Makefile
 rename drivers/net/{ => ethernet/smsc}/smc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.h (100%)
 create mode 100644 drivers/net/ethernet/sony/Kconfig
 create mode 100644 drivers/net/ethernet/sony/Makefile
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_net.c (100%)
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_net.h (100%)
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_wireless.c (100%)
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_wireless.h (100%)
 rename drivers/net/{ => ethernet}/starfire.c (100%)
 create mode 100644 drivers/net/ethernet/stmicro/Kconfig
 create mode 100644 drivers/net/ethernet/stmicro/Makefile
 rename drivers/net/{ => ethernet/stmicro}/stmmac/Kconfig (92%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/Makefile (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/common.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/descs.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000_core.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000_dma.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100_core.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100_dma.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac_dma.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac_lib.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/enh_desc.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/norm_desc.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_ethtool.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_main.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_mdio.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_timer.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_timer.h (100%)
 create mode 100644 drivers/net/ethernet/sun/Kconfig
 create mode 100644 drivers/net/ethernet/sun/Makefile
 rename drivers/net/{ => ethernet/sun}/cassini.c (100%)
 rename drivers/net/{ => ethernet/sun}/cassini.h (100%)
 rename drivers/net/{ => ethernet/sun}/niu.c (100%)
 rename drivers/net/{ => ethernet/sun}/niu.h (100%)
 rename drivers/net/{ => ethernet/sun}/sun3_82586.c (100%)
 rename drivers/net/{ => ethernet/sun}/sun3_82586.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunbmac.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunbmac.h (100%)
 rename drivers/net/{ => ethernet/sun}/sungem.c (100%)
 rename drivers/net/{ => ethernet/sun}/sungem.h (100%)
 rename drivers/net/{ => ethernet/sun}/sungem_phy.c (100%)
 rename drivers/net/{ => ethernet/sun}/sungem_phy.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunhme.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunhme.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunqe.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunqe.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunvnet.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunvnet.h (100%)
 rename drivers/net/{ => ethernet}/sundance.c (100%)
 create mode 100644 drivers/net/ethernet/syskonnect/Kconfig
 create mode 100644 drivers/net/ethernet/syskonnect/Makefile
 rename drivers/net/{ => ethernet/syskonnect}/skge.c (100%)
 rename drivers/net/{ => ethernet/syskonnect}/skge.h (100%)
 rename drivers/net/{ => ethernet/syskonnect}/sky2.c (100%)
 rename drivers/net/{ => ethernet/syskonnect}/sky2.h (100%)
 rename drivers/net/{ => ethernet}/tehuti.c (100%)
 rename drivers/net/{ => ethernet}/tehuti.h (100%)
 create mode 100644 drivers/net/ethernet/ti/Kconfig
 create mode 100644 drivers/net/ethernet/ti/Makefile
 rename drivers/net/{ => ethernet/ti}/cpmac.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.h (100%)
 rename drivers/net/{ => ethernet}/tsi108_eth.c (100%)
 rename drivers/net/{ => ethernet}/tsi108_eth.h (100%)
 rename drivers/net/{ => ethernet}/tulip/21142.c (100%)
 rename drivers/net/{ => ethernet}/tulip/Kconfig (93%)
 rename drivers/net/{ => ethernet}/tulip/Makefile (100%)
 rename drivers/net/{ => ethernet}/tulip/de2104x.c (100%)
 rename drivers/net/{ => ethernet}/tulip/de4x5.c (100%)
 rename drivers/net/{ => ethernet}/tulip/de4x5.h (100%)
 rename drivers/net/{ => ethernet}/tulip/dmfe.c (100%)
 rename drivers/net/{ => ethernet}/tulip/eeprom.c (100%)
 rename drivers/net/{ => ethernet}/tulip/interrupt.c (100%)
 rename drivers/net/{ => ethernet}/tulip/media.c (100%)
 rename drivers/net/{ => ethernet}/tulip/pnic.c (100%)
 rename drivers/net/{ => ethernet}/tulip/pnic2.c (100%)
 rename drivers/net/{ => ethernet}/tulip/timer.c (100%)
 rename drivers/net/{ => ethernet}/tulip/tulip.h (100%)
 rename drivers/net/{ => ethernet}/tulip/tulip_core.c (100%)
 rename drivers/net/{ => ethernet}/tulip/uli526x.c (100%)
 rename drivers/net/{ => ethernet}/tulip/winbond-840.c (100%)
 rename drivers/net/{ => ethernet}/tulip/xircom_cb.c (100%)
 create mode 100644 drivers/net/ethernet/via/Kconfig
 create mode 100644 drivers/net/ethernet/via/Makefile
 rename drivers/net/{ => ethernet/via}/via-rhine.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.h (100%)
 create mode 100644 drivers/net/ethernet/xilinx/Kconfig
 create mode 100644 drivers/net/ethernet/xilinx/Makefile
 rename drivers/net/{ => ethernet/xilinx}/ll_temac.h (100%)
 rename drivers/net/{ => ethernet/xilinx}/ll_temac_main.c (100%)
 rename drivers/net/{ => ethernet/xilinx}/ll_temac_mdio.c (100%)
 rename drivers/net/{ => ethernet/xilinx}/xilinx_emaclite.c (100%)

-- 
1.7.5.4

