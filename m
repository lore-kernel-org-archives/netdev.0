From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10] drivers/net/ organize Ethernet drivers
Date: Wed, 10 Aug 2011 20:27:48 -0700
Message-ID: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@tredhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4743 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753909Ab1HKD2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 23:28:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first of seven 10 patch series to move the Ethernet
drivers into drivers/net/ethernet/

The following are changes since commit 19fd61785a580c60cba900c5171bfadb57dd5056:
  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (10):
  drivers/net/ethernet: Add ethernet dir and config option
  3c*/acenic/typhoon: Move 3Com Ethernet drivers
  amd: Move AMD (Lance) chipset drivers
  8390: Move the 8390 related drivers
  broadcom: Move the Broadcom drivers
  chelsio: Move the Chelsio drivers
  intel: Move the Intel wired LAN drivers
  qlogic: Move the QLogic drivers
  smsc: Move the SMC (SMSC) drivers
  i825xx: Move the Intel 82586/82593/82596 based drivers

 MAINTAINERS                                        |   66 +-
 drivers/infiniband/hw/cxgb3/Makefile               |    2 +-
 drivers/infiniband/hw/cxgb4/Makefile               |    2 +-
 drivers/net/Kconfig                                | 1251 +-------------------
 drivers/net/Makefile                               |   92 +--
 drivers/net/arm/Kconfig                            |   22 -
 drivers/net/arm/Makefile                           |    3 -
 drivers/net/{ => ethernet/3com}/3c501.c            |    0
 drivers/net/{ => ethernet/3com}/3c501.h            |    0
 drivers/net/{ => ethernet/3com}/3c509.c            |    0
 drivers/net/{ => ethernet/3com}/3c515.c            |    0
 drivers/net/{pcmcia => ethernet/3com}/3c574_cs.c   |    0
 drivers/net/{pcmcia => ethernet/3com}/3c589_cs.c   |    0
 drivers/net/{ => ethernet/3com}/3c59x.c            |    0
 drivers/net/ethernet/3com/Kconfig                  |  147 +++
 drivers/net/ethernet/3com/Makefile                 |   12 +
 drivers/net/{ => ethernet/3com}/acenic.c           |    0
 drivers/net/{ => ethernet/3com}/acenic.h           |    0
 drivers/net/{ => ethernet/3com}/typhoon.c          |    0
 drivers/net/{ => ethernet/3com}/typhoon.h          |    0
 drivers/net/{ => ethernet/8390}/3c503.c            |    0
 drivers/net/{ => ethernet/8390}/3c503.h            |    0
 drivers/net/{ => ethernet/8390}/8390.c             |    0
 drivers/net/{ => ethernet/8390}/8390.h             |    0
 drivers/net/{ => ethernet/8390}/8390p.c            |    0
 drivers/net/ethernet/8390/Kconfig                  |  335 ++++++
 drivers/net/ethernet/8390/Makefile                 |   29 +
 drivers/net/{ => ethernet/8390}/ac3200.c           |    0
 drivers/net/{ => ethernet/8390}/apne.c             |    0
 drivers/net/{ => ethernet/8390}/ax88796.c          |    0
 drivers/net/{pcmcia => ethernet/8390}/axnet_cs.c   |    2 +-
 drivers/net/{ => ethernet/8390}/e2100.c            |    0
 drivers/net/{ => ethernet/8390}/es3210.c           |    0
 drivers/net/{arm => ethernet/8390}/etherh.c        |    2 +-
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
 drivers/net/ethernet/Kconfig                       |   24 +
 drivers/net/ethernet/Makefile                      |   13 +
 drivers/net/{ => ethernet/amd}/7990.c              |    0
 drivers/net/{ => ethernet/amd}/7990.h              |    0
 drivers/net/ethernet/amd/Kconfig                   |  192 +++
 drivers/net/ethernet/amd/Makefile                  |   20 +
 drivers/net/{ => ethernet/amd}/a2065.c             |    0
 drivers/net/{ => ethernet/amd}/a2065.h             |    0
 drivers/net/{arm => ethernet/amd}/am79c961a.c      |    0
 drivers/net/{arm => ethernet/amd}/am79c961a.h      |    0
 drivers/net/{ => ethernet/amd}/amd8111e.c          |    0
 drivers/net/{ => ethernet/amd}/amd8111e.h          |    0
 drivers/net/{ => ethernet/amd}/ariadne.c           |    0
 drivers/net/{ => ethernet/amd}/ariadne.h           |    0
 drivers/net/{ => ethernet/amd}/atarilance.c        |    0
 drivers/net/{ => ethernet/amd}/au1000_eth.c        |    0
 drivers/net/{ => ethernet/amd}/au1000_eth.h        |    0
 drivers/net/{ => ethernet/amd}/declance.c          |    0
 drivers/net/{ => ethernet/amd}/depca.c             |    0
 drivers/net/{ => ethernet/amd}/depca.h             |    0
 drivers/net/{ => ethernet/amd}/hplance.c           |    0
 drivers/net/{ => ethernet/amd}/hplance.h           |    0
 drivers/net/{ => ethernet/amd}/lance.c             |    0
 drivers/net/{ => ethernet/amd}/mvme147.c           |    0
 drivers/net/{ => ethernet/amd}/ni65.c              |    0
 drivers/net/{ => ethernet/amd}/ni65.h              |    0
 drivers/net/{pcmcia => ethernet/amd}/nmclan_cs.c   |    0
 drivers/net/{ => ethernet/amd}/pcnet32.c           |    0
 drivers/net/{ => ethernet/amd}/sun3lance.c         |    0
 drivers/net/{ => ethernet/amd}/sunlance.c          |    0
 drivers/net/ethernet/broadcom/Kconfig              |  119 ++
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
 drivers/net/ethernet/chelsio/Kconfig               |  106 ++
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
 drivers/net/{ => ethernet/i825xx}/3c505.c          |    0
 drivers/net/{ => ethernet/i825xx}/3c505.h          |    0
 drivers/net/{ => ethernet/i825xx}/3c507.c          |    0
 drivers/net/{ => ethernet/i825xx}/3c523.c          |    0
 drivers/net/{ => ethernet/i825xx}/3c523.h          |    0
 drivers/net/{ => ethernet/i825xx}/3c527.c          |    0
 drivers/net/{ => ethernet/i825xx}/3c527.h          |    0
 drivers/net/{ => ethernet/i825xx}/82596.c          |    0
 drivers/net/ethernet/i825xx/Kconfig                |  182 +++
 drivers/net/ethernet/i825xx/Makefile               |   20 +
 drivers/net/{ => ethernet/i825xx}/eepro.c          |    0
 drivers/net/{ => ethernet/i825xx}/eexpress.c       |    0
 drivers/net/{ => ethernet/i825xx}/eexpress.h       |    0
 drivers/net/{arm => ethernet/i825xx}/ether1.c      |    0
 drivers/net/{arm => ethernet/i825xx}/ether1.h      |    0
 drivers/net/{ => ethernet/i825xx}/lasi_82596.c     |    0
 drivers/net/{ => ethernet/i825xx}/lib82596.c       |    0
 drivers/net/{ => ethernet/i825xx}/lp486e.c         |    0
 drivers/net/{ => ethernet/i825xx}/ni52.c           |    0
 drivers/net/{ => ethernet/i825xx}/ni52.h           |    0
 drivers/net/{ => ethernet/i825xx}/sni_82596.c      |    0
 drivers/net/{ => ethernet/i825xx}/sun3_82586.c     |    0
 drivers/net/{ => ethernet/i825xx}/sun3_82586.h     |    0
 drivers/net/{ => ethernet/i825xx}/znet.c           |    0
 drivers/net/ethernet/intel/Kconfig                 |  220 ++++
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
 .../intel/e1000e/80003es2lan.c}                    |    0
 drivers/net/{ => ethernet/intel}/e1000e/82571.c    |    0
 drivers/net/{ => ethernet/intel}/e1000e/Makefile   |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/defines.h  |    0
 drivers/net/{ => ethernet/intel}/e1000e/e1000.h    |    0
 drivers/net/{ => ethernet/intel}/e1000e/ethtool.c  |    0
 drivers/net/{ => ethernet/intel}/e1000e/hw.h       |    0
 drivers/net/{ => ethernet/intel}/e1000e/ich8lan.c  |    0
 drivers/net/{ => ethernet/intel}/e1000e/lib.c      |    0
 drivers/net/{ => ethernet/intel}/e1000e/netdev.c   |    0
 drivers/net/{ => ethernet/intel}/e1000e/param.c    |    0
 drivers/net/{ => ethernet/intel}/e1000e/phy.c      |    0
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
 drivers/net/ethernet/qlogic/Kconfig                |   53 +
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
 drivers/net/ethernet/smsc/Kconfig                  |  131 ++
 drivers/net/ethernet/smsc/Makefile                 |   11 +
 drivers/net/{ => ethernet/smsc}/epic100.c          |    0
 drivers/net/{ => ethernet/smsc}/smc911x.c          |    0
 drivers/net/{ => ethernet/smsc}/smc911x.h          |    0
 drivers/net/{ => ethernet/smsc}/smc9194.c          |    0
 drivers/net/{ => ethernet/smsc}/smc9194.h          |    0
 .../net/{pcmcia => ethernet/smsc}/smc91c92_cs.c    |    0
 drivers/net/{ => ethernet/smsc}/smc91x.c           |    0
 drivers/net/{ => ethernet/smsc}/smc91x.h           |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.c         |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.h         |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.c         |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.h         |    0
 drivers/net/pcmcia/Kconfig                         |   59 -
 drivers/net/pcmcia/Makefile                        |    6 -
 drivers/scsi/bnx2fc/bnx2fc.h                       |    2 +-
 drivers/scsi/bnx2i/bnx2i.h                         |    2 +-
 drivers/scsi/cxgbi/cxgb3i/Kbuild                   |    2 +-
 drivers/scsi/cxgbi/cxgb4i/Kbuild                   |    2 +-
 355 files changed, 1704 insertions(+), 1472 deletions(-)
 rename drivers/net/{ => ethernet/3com}/3c501.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c501.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c509.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c515.c (100%)
 rename drivers/net/{pcmcia => ethernet/3com}/3c574_cs.c (100%)
 rename drivers/net/{pcmcia => ethernet/3com}/3c589_cs.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c59x.c (100%)
 create mode 100644 drivers/net/ethernet/3com/Kconfig
 create mode 100644 drivers/net/ethernet/3com/Makefile
 rename drivers/net/{ => ethernet/3com}/acenic.c (100%)
 rename drivers/net/{ => ethernet/3com}/acenic.h (100%)
 rename drivers/net/{ => ethernet/3com}/typhoon.c (100%)
 rename drivers/net/{ => ethernet/3com}/typhoon.h (100%)
 rename drivers/net/{ => ethernet/8390}/3c503.c (100%)
 rename drivers/net/{ => ethernet/8390}/3c503.h (100%)
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
 rename drivers/net/{arm => ethernet/8390}/etherh.c (99%)
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
 rename drivers/net/{ => ethernet/amd}/7990.c (100%)
 rename drivers/net/{ => ethernet/amd}/7990.h (100%)
 create mode 100644 drivers/net/ethernet/amd/Kconfig
 create mode 100644 drivers/net/ethernet/amd/Makefile
 rename drivers/net/{ => ethernet/amd}/a2065.c (100%)
 rename drivers/net/{ => ethernet/amd}/a2065.h (100%)
 rename drivers/net/{arm => ethernet/amd}/am79c961a.c (100%)
 rename drivers/net/{arm => ethernet/amd}/am79c961a.h (100%)
 rename drivers/net/{ => ethernet/amd}/amd8111e.c (100%)
 rename drivers/net/{ => ethernet/amd}/amd8111e.h (100%)
 rename drivers/net/{ => ethernet/amd}/ariadne.c (100%)
 rename drivers/net/{ => ethernet/amd}/ariadne.h (100%)
 rename drivers/net/{ => ethernet/amd}/atarilance.c (100%)
 rename drivers/net/{ => ethernet/amd}/au1000_eth.c (100%)
 rename drivers/net/{ => ethernet/amd}/au1000_eth.h (100%)
 rename drivers/net/{ => ethernet/amd}/declance.c (100%)
 rename drivers/net/{ => ethernet/amd}/depca.c (100%)
 rename drivers/net/{ => ethernet/amd}/depca.h (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.c (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.h (100%)
 rename drivers/net/{ => ethernet/amd}/lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/mvme147.c (100%)
 rename drivers/net/{ => ethernet/amd}/ni65.c (100%)
 rename drivers/net/{ => ethernet/amd}/ni65.h (100%)
 rename drivers/net/{pcmcia => ethernet/amd}/nmclan_cs.c (100%)
 rename drivers/net/{ => ethernet/amd}/pcnet32.c (100%)
 rename drivers/net/{ => ethernet/amd}/sun3lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/sunlance.c (100%)
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
 rename drivers/net/{ => ethernet/i825xx}/3c505.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/3c505.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/3c507.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/3c523.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/3c523.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/3c527.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/3c527.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/82596.c (100%)
 create mode 100644 drivers/net/ethernet/i825xx/Kconfig
 create mode 100644 drivers/net/ethernet/i825xx/Makefile
 rename drivers/net/{ => ethernet/i825xx}/eepro.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/eexpress.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/eexpress.h (100%)
 rename drivers/net/{arm => ethernet/i825xx}/ether1.c (100%)
 rename drivers/net/{arm => ethernet/i825xx}/ether1.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/lasi_82596.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/lib82596.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/lp486e.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/ni52.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/ni52.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/sni_82596.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/sun3_82586.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/sun3_82586.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/znet.c (100%)
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
 rename drivers/net/{e1000e/es2lan.c => ethernet/intel/e1000e/80003es2lan.c} (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/82571.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/Makefile (96%)
 rename drivers/net/{ => ethernet/intel}/e1000e/defines.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/e1000.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/ich8lan.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/lib.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/netdev.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/param.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/phy.c (100%)
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
 create mode 100644 drivers/net/ethernet/smsc/Kconfig
 create mode 100644 drivers/net/ethernet/smsc/Makefile
 rename drivers/net/{ => ethernet/smsc}/epic100.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smc9194.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc9194.h (100%)
 rename drivers/net/{pcmcia => ethernet/smsc}/smc91c92_cs.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc91x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc91x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.h (100%)

-- 
1.7.6

