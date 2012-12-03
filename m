From: Greg KH <gregkh@linuxfoundation.org>
Subject: [GIT PULL] Remove __dev* markings from the networking drivers
Date: Mon, 3 Dec 2012 12:27:43 -0800
Message-ID: <20121203202743.GA29451@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Pemberton <wfp5p@virginia.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:65532 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2LCU1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 15:27:48 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1464032dak.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 12:27:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a pull request for all of Bill's __dev* removal patches for the
networking drivers, based on net-next.  I'll send out a separate one for
the wireless drivers in case those want to go through John's tree

If I should rework these in any way, please let me know.

thanks,

greg k-h

-------------

The following changes since commit 60e476d02129acb1f863a9b4932358678ee6a355:

  bna: remove useless calls to memset(). (2012-12-02 20:32:56 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/net-next.git tags/dev_removal

for you to fetch changes up to 9f9a12f8ca79839c948464a37c5b557808278708:

  net/intel: remove __dev* attributes (2012-12-03 11:17:07 -0800)

----------------------------------------------------------------
Networking:  Remove __dev* markings from the networking drivers

This is a series of patches that remove the dev* attributes for all
networking drivers, with the exception of wireless drivers, those are in
a different branch.

Use of __devinit, __devexit_p, __devinitdata, __devinitconst, and
__devexit are no longer needed since CONFIG_HOTPLUG is being removed as
an option.

Note, there are some devinit compiler section mismatch warnings due to
this series, but they are fixed up when merged with my driver-next
branch, which fixes the PCI device id warnings, and removes the modpost
detection, as it's no longer needed.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

----------------------------------------------------------------
Bill Pemberton (103):
      ARCNET: remove __dev* attributes
      can: remove __dev* attributes
      drivers/net/ethernet/amd/am79c961a.c: remove __dev* attributes
      i825xx/ether1.c: remove __dev* attributes
      i825xx: remove __dev* attributes
      3c59x: remove __dev* attributes
      typhoon: remove __dev* attributes
      3c509: remove __dev* attributes
      8390: remove __dev* attributes
      acenic: remove __dev* attributes
      starfire: remove __dev* attributes
      bfin_mac: remove __dev* attributes
      aeroflex: remove __dev* attributes
      pcnet32: remove __dev* attributes
      b44: remove __dev* attributes
      bnx2: remove __dev* attributes
      tg3: remove __dev* attributes
      bna: remove __dev* attributes
      cxgb3: remove __dev* attributes
      cxgb4: remove __dev* attributes
      cxgb4vf: remove __dev* attributes
      chelsio: remove __dev* attributes
      enic: remove __dev* attributes
      dm9000: remove __dev* attributes
      dlink: remove __dev* attributes
      fs_enet: remove __dev* attributes
      be2net: remove __dev* attributes
      ehea: remove __dev* attributes
      hp100: remove __dev* attributes
      ibmveth: remove __dev* attributes
      ibm/emac: remove __dev* attributes
      skge: remove __dev* attributes
      mlx4_core: remove __dev* attributes
      enc28j60: remove __dev* attributes
      natsemi: remove __dev* attributes
      vxge/s2io: remove __dev* attributes
      nuvoton: remove __dev* attributes
      forcedeth: remove __dev* attributes
      lpc_eth: remove __dev* attributes
      net/octeon_mgmt: remove __dev* attributes
      packetengines: remove __dev* attributes
      netxen: remove __dev* attributes
      qlcnic: remove __dev* attributes
      qla3xxx: remove __dev* attributes
      qlge: remove __dev* attributes
      r8169: remove __dev* attributes
      8139too: remove __dev* attributes
      r6040: remove __dev* attributes
      seeq: remove __dev* attributes
      sfc: remove __dev* attributes
      sc92031: remove __dev* attributes
      stmmac: remove __dev* attributes
      sis190: remove __dev* attributes
      sis900: remove __dev* attributes
      smc91x: remove __dev* attributes
      smsc911x: remove __dev* attributes
      smc911x: remove __dev* attributes
      smsc9420: remove __dev* attributes
      tulip: remove __dev* attributes
      epic100: remove __dev* attributes
      cpmac: remove __dev* attributes
      tlan: remove __dev* attributes
      cpsw: remove __dev* attributes
      tehuti: remove __dev* attributes
      tc35815: remove __dev* attributes
      via-rhine: remove __dev* attributes
      via-velocity: remove __dev* attributes
      xilinx_axienet: remove __dev* attributes
      ixp4xx_eth: remove __dev* attributes
      icplus: remove __dev* attributes
      jme: remove __dev* attributes
      net/amd: remove __dev* attributes
      net/apple: remove __dev* attributes
      net/atheros: remove __dev* attributes
      net/cadence: remove __dev* attributes
      net/freescale: remove __dev* attributes
      net/micrel: remove __dev* attributes
      net/pasemi: remove __dev* attributes
      net/sgi: remove __dev* attributes
      net/sun: remove __dev* attributes
      net/davinci_emac: remove __dev* attributes
      net/ps3_gelic_net: remove __dev* attributes
      net/spider_net: remove __dev* attributes
      net/ps3_gelic_wireless: remove __dev* attributes
      net/wiznet: remove __dev* attributes
      net/xilinx: remove __dev* attributes
      net/ethernet: remove __dev* attributes
      fddi: remove __dev* attributes
      hippi: remove __dev* attributes
      ieee802154: remove __dev* attributes
      irda: remove __dev* attributes
      net/phy: remove __dev* attributes
      virtio_net: remove __dev* attributes
      vmxnet3: remove __dev* attributes
      dscc4: remove __dev* attributes
      farsync: remove __dev* attributes
      net/hdlc: remove __dev* attributes
      ixp4xx_hss: remove __dev* attributes
      net/lmc: remove __dev* attributes
      xen-netfront: remove __dev* attributes
      net/broadcom: remove __dev* attributes
      bnx2x: remove __dev* attributes
      net/intel: remove __dev* attributes

 drivers/net/arcnet/com20020-pci.c                     |  6 ++---
 drivers/net/can/at91_can.c                            |  8 +++----
 drivers/net/can/bfin_can.c                            |  6 ++---
 drivers/net/can/c_can/c_can_pci.c                     |  6 ++---
 drivers/net/can/c_can/c_can_platform.c                |  6 ++---
 drivers/net/can/cc770/cc770_isa.c                     | 18 +++++++--------
 drivers/net/can/cc770/cc770_platform.c                | 12 +++++-----
 drivers/net/can/flexcan.c                             | 10 ++++----
 drivers/net/can/grcan.c                               |  8 +++----
 drivers/net/can/janz-ican3.c                          | 24 +++++++++----------
 drivers/net/can/mcp251x.c                             |  6 ++---
 drivers/net/can/mscan/mpc5xxx_can.c                   | 24 +++++++++----------
 drivers/net/can/pch_can.c                             |  6 ++---
 drivers/net/can/sja1000/ems_pci.c                     |  2 +-
 drivers/net/can/sja1000/ems_pcmcia.c                  |  4 ++--
 drivers/net/can/sja1000/kvaser_pci.c                  |  6 ++---
 drivers/net/can/sja1000/peak_pci.c                    |  6 ++---
 drivers/net/can/sja1000/peak_pcmcia.c                 |  2 +-
 drivers/net/can/sja1000/plx_pci.c                     | 20 ++++++++--------
 drivers/net/can/sja1000/sja1000_isa.c                 | 16 ++++++-------
 drivers/net/can/sja1000/sja1000_of_platform.c         |  8 +++----
 drivers/net/can/sja1000/tscan1.c                      |  8 +++----
 drivers/net/can/softing/softing_cs.c                  | 10 ++++----
 drivers/net/can/softing/softing_main.c                | 12 +++++-----
 drivers/net/can/ti_hecc.c                             |  4 ++--
 drivers/net/ethernet/3com/3c509.c                     | 24 +++++++++----------
 drivers/net/ethernet/3com/3c59x.c                     | 16 ++++++-------
 drivers/net/ethernet/3com/typhoon.c                   | 10 ++++----
 drivers/net/ethernet/8390/etherh.c                    |  8 +++----
 drivers/net/ethernet/8390/hydra.c                     | 16 ++++++-------
 drivers/net/ethernet/8390/ne2k-pci.c                  | 12 +++++-----
 drivers/net/ethernet/8390/ne3210.c                    |  4 ++--
 drivers/net/ethernet/8390/zorro8390.c                 | 12 +++++-----
 drivers/net/ethernet/adaptec/starfire.c               | 10 ++++----
 drivers/net/ethernet/adi/bfin_mac.c                   | 12 +++++-----
 drivers/net/ethernet/aeroflex/greth.c                 |  6 ++---
 drivers/net/ethernet/alteon/acenic.c                  | 26 ++++++++++-----------
 drivers/net/ethernet/amd/a2065.c                      | 12 +++++-----
 drivers/net/ethernet/amd/am79c961a.c                  |  2 +-
 drivers/net/ethernet/amd/amd8111e.c                   |  8 +++----
 drivers/net/ethernet/amd/ariadne.c                    |  8 +++----
 drivers/net/ethernet/amd/au1000_eth.c                 |  6 ++---
 drivers/net/ethernet/amd/declance.c                   |  8 +++----
 drivers/net/ethernet/amd/depca.c                      | 10 ++++----
 drivers/net/ethernet/amd/hplance.c                    | 14 ++++++------
 drivers/net/ethernet/amd/pcnet32.c                    | 10 ++++----
 drivers/net/ethernet/amd/sunlance.c                   |  8 +++----
 drivers/net/ethernet/apple/bmac.c                     |  4 ++--
 drivers/net/ethernet/apple/mace.c                     |  4 ++--
 drivers/net/ethernet/apple/macmace.c                  |  6 ++---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c       | 14 ++++++------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c       | 10 ++++----
 drivers/net/ethernet/atheros/atl1e/atl1e_param.c      |  7 +++---
 drivers/net/ethernet/atheros/atlx/atl1.c              | 14 ++++++------
 drivers/net/ethernet/atheros/atlx/atl2.c              | 16 ++++++-------
 drivers/net/ethernet/broadcom/b44.c                   |  8 +++----
 drivers/net/ethernet/broadcom/bcm63xx_enet.c          | 12 +++++-----
 drivers/net/ethernet/broadcom/bnx2.c                  | 20 ++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h       |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      | 66 ++++++++++++++++++++++++++---------------------------
 drivers/net/ethernet/broadcom/cnic.c                  |  2 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c            |  2 +-
 drivers/net/ethernet/broadcom/tg3.c                   | 95 ++++++++++++++++++++++++++++++++++++++--------------------------------------
 drivers/net/ethernet/brocade/bna/bnad.c               |  6 ++---
 drivers/net/ethernet/cadence/at91_ether.c             |  4 ++--
 drivers/net/ethernet/cadence/macb.c                   |  8 +++----
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c             |  6 ++---
 drivers/net/ethernet/chelsio/cxgb/sge.c               |  2 +-
 drivers/net/ethernet/chelsio/cxgb/subr.c              |  8 +++----
 drivers/net/ethernet/chelsio/cxgb/tp.c                |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c       | 12 +++++-----
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c    |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       | 22 +++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            | 12 +++++-----
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c   | 20 ++++++++--------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h    |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c        |  6 ++---
 drivers/net/ethernet/cisco/enic/enic_main.c           |  6 ++---
 drivers/net/ethernet/davicom/dm9000.c                 |  6 ++---
 drivers/net/ethernet/dec/tulip/de2104x.c              | 17 +++++++-------
 drivers/net/ethernet/dec/tulip/de4x5.c                | 18 +++++++--------
 drivers/net/ethernet/dec/tulip/dmfe.c                 | 12 +++++-----
 drivers/net/ethernet/dec/tulip/eeprom.c               | 10 ++++----
 drivers/net/ethernet/dec/tulip/media.c                |  2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c           | 14 ++++++------
 drivers/net/ethernet/dec/tulip/uli526x.c              | 12 +++++-----
 drivers/net/ethernet/dec/tulip/winbond-840.c          | 10 ++++----
 drivers/net/ethernet/dec/tulip/xircom_cb.c            |  6 ++---
 drivers/net/ethernet/dlink/dl2k.c                     |  8 +++----
 drivers/net/ethernet/dlink/sundance.c                 | 14 ++++++------
 drivers/net/ethernet/dnet.c                           |  8 +++----
 drivers/net/ethernet/emulex/benet/be_main.c           |  4 ++--
 drivers/net/ethernet/ethoc.c                          |  8 +++----
 drivers/net/ethernet/fealnx.c                         | 10 ++++----
 drivers/net/ethernet/freescale/fec.c                  | 10 ++++----
 drivers/net/ethernet/freescale/fec_mpc52xx.c          |  2 +-
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c |  2 +-
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c  |  4 ++--
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c      |  2 +-
 drivers/net/ethernet/freescale/xgmac_mdio.c           |  4 ++--
 drivers/net/ethernet/hp/hp100.c                       | 16 ++++++-------
 drivers/net/ethernet/i825xx/ether1.c                  | 14 ++++++------
 drivers/net/ethernet/i825xx/lasi_82596.c              |  8 +++----
 drivers/net/ethernet/i825xx/lib82596.c                |  2 +-
 drivers/net/ethernet/i825xx/sni_82596.c               |  8 +++----
 drivers/net/ethernet/ibm/ehea/ehea_main.c             | 10 ++++----
 drivers/net/ethernet/ibm/emac/core.c                  | 18 +++++++--------
 drivers/net/ethernet/ibm/emac/mal.c                   |  6 ++---
 drivers/net/ethernet/ibm/emac/rgmii.c                 |  6 ++---
 drivers/net/ethernet/ibm/emac/tah.c                   |  6 ++---
 drivers/net/ethernet/ibm/emac/zmii.c                  |  6 ++---
 drivers/net/ethernet/ibm/ibmveth.c                    |  6 ++---
 drivers/net/ethernet/icplus/ipg.c                     |  6 ++---
 drivers/net/ethernet/intel/e100.c                     |  6 ++---
 drivers/net/ethernet/intel/e1000/e1000_main.c         | 12 +++++-----
 drivers/net/ethernet/intel/e1000/e1000_param.c        | 10 ++++----
 drivers/net/ethernet/intel/e1000e/netdev.c            | 10 ++++----
 drivers/net/ethernet/intel/e1000e/param.c             |  6 ++---
 drivers/net/ethernet/intel/igb/igb_main.c             | 12 +++++-----
 drivers/net/ethernet/intel/igbvf/netdev.c             | 10 ++++----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c           | 10 ++++----
 drivers/net/ethernet/intel/ixgb/ixgb_param.c          |  6 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |  8 +++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c     |  8 +++----
 drivers/net/ethernet/jme.c                            |  6 ++---
 drivers/net/ethernet/lantiq_etop.c                    |  4 ++--
 drivers/net/ethernet/marvell/skge.c                   |  8 +++----
 drivers/net/ethernet/marvell/sky2.c                   | 16 ++++++-------
 drivers/net/ethernet/mellanox/mlx4/main.c             |  6 ++---
 drivers/net/ethernet/micrel/ks8695net.c               | 10 ++++----
 drivers/net/ethernet/micrel/ks8842.c                  |  6 ++---
 drivers/net/ethernet/micrel/ks8851.c                  |  6 ++---
 drivers/net/ethernet/micrel/ks8851_mll.c              |  6 ++---
 drivers/net/ethernet/micrel/ksz884x.c                 |  4 ++--
 drivers/net/ethernet/microchip/enc28j60.c             |  6 ++---
 drivers/net/ethernet/natsemi/ibmlana.c                |  4 ++--
 drivers/net/ethernet/natsemi/jazzsonic.c              |  8 +++----
 drivers/net/ethernet/natsemi/macsonic.c               | 18 +++++++--------
 drivers/net/ethernet/natsemi/natsemi.c                | 14 ++++++------
 drivers/net/ethernet/natsemi/ns83820.c                |  6 ++---
 drivers/net/ethernet/natsemi/xtsonic.c                |  6 ++---
 drivers/net/ethernet/neterion/s2io.c                  |  6 ++---
 drivers/net/ethernet/neterion/s2io.h                  |  4 ++--
 drivers/net/ethernet/neterion/vxge/vxge-config.c      |  6 ++---
 drivers/net/ethernet/neterion/vxge/vxge-config.h      |  6 ++---
 drivers/net/ethernet/neterion/vxge/vxge-main.c        | 16 ++++++-------
 drivers/net/ethernet/nuvoton/w90p910_ether.c          |  6 ++---
 drivers/net/ethernet/nvidia/forcedeth.c               |  6 ++---
 drivers/net/ethernet/nxp/lpc_eth.c                    |  2 +-
 drivers/net/ethernet/octeon/octeon_mgmt.c             |  6 ++---
 drivers/net/ethernet/packetengines/hamachi.c          | 12 +++++-----
 drivers/net/ethernet/packetengines/yellowfin.c        | 10 ++++----
 drivers/net/ethernet/pasemi/pasemi_mac.c              |  6 ++---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c  | 10 ++++----
 drivers/net/ethernet/qlogic/qla3xxx.c                 |  6 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      | 10 ++++----
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          |  8 +++----
 drivers/net/ethernet/rdc/r6040.c                      |  8 +++----
 drivers/net/ethernet/realtek/8139too.c                | 14 ++++++------
 drivers/net/ethernet/realtek/r8169.c                  | 18 +++++++--------
 drivers/net/ethernet/s6gmac.c                         |  6 ++---
 drivers/net/ethernet/seeq/ether3.c                    | 16 ++++++-------
 drivers/net/ethernet/seeq/sgiseeq.c                   |  2 +-
 drivers/net/ethernet/sfc/efx.c                        |  2 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                   | 10 ++++----
 drivers/net/ethernet/sgi/meth.c                       |  2 +-
 drivers/net/ethernet/silan/sc92031.c                  |  6 ++---
 drivers/net/ethernet/sis/sis190.c                     | 20 ++++++++--------
 drivers/net/ethernet/sis/sis900.c                     | 27 +++++++++++-----------
 drivers/net/ethernet/smsc/epic100.c                   | 12 +++++-----
 drivers/net/ethernet/smsc/smc911x.c                   | 10 ++++----
 drivers/net/ethernet/smsc/smc91x.c                    | 10 ++++----
 drivers/net/ethernet/smsc/smsc911x.c                  | 14 ++++++------
 drivers/net/ethernet/smsc/smsc9420.c                  |  6 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      |  6 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  6 ++---
 drivers/net/ethernet/sun/cassini.c                    | 12 +++++-----
 drivers/net/ethernet/sun/niu.c                        | 90 ++++++++++++++++++++++++++++++++++++------------------------------------
 drivers/net/ethernet/sun/sunbmac.c                    |  8 +++----
 drivers/net/ethernet/sun/sungem.c                     |  6 ++---
 drivers/net/ethernet/sun/sunhme.c                     | 18 +++++++--------
 drivers/net/ethernet/sun/sunqe.c                      | 12 +++++-----
 drivers/net/ethernet/sun/sunvnet.c                    | 14 ++++++------
 drivers/net/ethernet/tehuti/tehuti.c                  |  6 ++---
 drivers/net/ethernet/ti/cpmac.c                       | 10 ++++----
 drivers/net/ethernet/ti/cpsw.c                        |  6 ++---
 drivers/net/ethernet/ti/davinci_emac.c                |  6 ++---
 drivers/net/ethernet/ti/davinci_mdio.c                |  6 ++---
 drivers/net/ethernet/ti/tlan.c                        |  8 +++----
 drivers/net/ethernet/toshiba/ps3_gelic_net.c          | 14 ++++++------
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c     |  6 ++---
 drivers/net/ethernet/toshiba/spider_net.c             |  6 ++---
 drivers/net/ethernet/toshiba/tc35815.c                | 16 ++++++-------
 drivers/net/ethernet/via/via-rhine.c                  | 12 +++++-----
 drivers/net/ethernet/via/via-velocity.c               | 25 ++++++++++++--------
 drivers/net/ethernet/wiznet/w5100.c                   |  8 +++----
 drivers/net/ethernet/wiznet/w5300.c                   |  8 +++----
 drivers/net/ethernet/xilinx/ll_temac_main.c           |  8 +++----
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c     |  8 +++----
 drivers/net/ethernet/xilinx/xilinx_emaclite.c         |  8 +++----
 drivers/net/ethernet/xscale/ixp4xx_eth.c              |  4 ++--
 drivers/net/fddi/defxx.c                              | 40 ++++++++++++++++----------------
 drivers/net/fddi/skfp/skfddi.c                        |  4 ++--
 drivers/net/hippi/rrunner.c                           | 10 ++++----
 drivers/net/ieee802154/at86rf230.c                    |  6 ++---
 drivers/net/ieee802154/fakehard.c                     |  6 ++---
 drivers/net/ieee802154/fakelb.c                       |  6 ++---
 drivers/net/ieee802154/mrf24j40.c                     |  6 ++---
 drivers/net/irda/au1k_ir.c                            |  8 +++----
 drivers/net/irda/bfin_sir.c                           |  8 +++----
 drivers/net/irda/sh_irda.c                            |  6 ++---
 drivers/net/irda/sh_sir.c                             |  6 ++---
 drivers/net/irda/smsc-ircc2.c                         |  4 ++--
 drivers/net/irda/via-ircc.c                           | 14 ++++++------
 drivers/net/irda/vlsi_ir.c                            |  6 ++---
 drivers/net/phy/mdio-gpio.c                           | 10 ++++----
 drivers/net/phy/mdio-mux-gpio.c                       |  6 ++---
 drivers/net/phy/mdio-mux-mmioreg.c                    |  6 ++---
 drivers/net/phy/mdio-octeon.c                         |  6 ++---
 drivers/net/phy/spi_ks8995.c                          |  6 ++---
 drivers/net/virtio_net.c                              |  4 ++--
 drivers/net/vmxnet3/vmxnet3_drv.c                     |  6 ++---
 drivers/net/wan/dscc4.c                               |  6 ++---
 drivers/net/wan/farsync.c                             | 10 ++++----
 drivers/net/wan/hd64570.c                             |  4 ++--
 drivers/net/wan/hd64572.c                             |  4 ++--
 drivers/net/wan/ixp4xx_hss.c                          |  4 ++--
 drivers/net/wan/lmc/lmc_main.c                        |  6 ++---
 drivers/net/wan/pc300too.c                            |  2 +-
 drivers/net/wan/pci200syn.c                           |  2 +-
 drivers/net/wan/wanxl.c                               |  2 +-
 drivers/net/xen-netfront.c                            |  8 +++----
 233 files changed, 1142 insertions(+), 1133 deletions(-)
