From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 00/64] use setup_timer() helper function.
Date: Thu, 21 Sep 2017 22:34:21 +0530
Message-ID: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 This series uses setup_timer() helper function. The series
addresses the files under drivers/net/*.


Allen Pais (64):
  drivers: net: de4x: use setup_timer() helper.
  drivers: net: b44: use setup_timer() helper.
  drivers: net: pcnet32: use setup_timer() helper.
  drivers: net: brcm80211: use setup_timer() helper.
  drivers : net: niu: use setup_timer() helper.
  drivers: net: bcm63xx: use setup_timer() helper.
  drivers: net: declance: use setup_timer() helper.
  drivers: net: am79c961: use setup_timer() helper.
  drivers: net: et131x: use setup_timer() helper.
  drivers: net: appletalk: cops: use setup_timer() helper.
  drivers: net: rsi_91x: use setup_timer() helper.
  drivers: net: atp: use setup_timer() helper.
  drivers: net: ns83820: use setup_timer() helper.
  drivers: net: ixgb: use setup_timer() helper.
  drivers: net: sundance: use setup_timer() helper.
  drivers: net: tg3: use setup_timer() helper.
  drivers: net: sdla: use setup_timer() helper.
  drivers: net: cisco_hdlc: use setup_timer() helper.
  drivers: net: slip: use setup_timer() helper.
  drivers: net: spider_net: use setup_timer() helper.
  drivers: net: sun: cassini: use setup_timer() helper.
  drivers: net: natsemi: use setup_timer() helper.
  drivers: net: winbond-840: use setup_timer() helper.
  drivers: net: enic: use setup_timer() helper.
  drivers: net: bnx2: use setup_timer() helper.
  drivers: net: xen-netback: use setup_timer() helper.
  drivers: net: atmel: use setup_timer() helper.
  drivers: net: hippi: use setup_timer() helper.
  drivers: net: smsc: use setup_timer() helper.
  drivers: net: qlogic: use setup_timer() helper.
  drivers: net: e1000e: use setup_timer() helper.
  drivers: net: amd: use setup_timer() helper.
  drivers: net: amd8111e: use setup_timer() helper.
  drivers: net: eql: use setup_timer() helper.
  drivers: net: can: usb: use setup_timer() helper.
  drivers: net: can: use setup_timer() helper.
  drivers: net: arcnet: use setup_timer() helper.
  drivers: net: ath6kl: use setup_timer() helper.
  drivers: net: sun: use setup_timer() helper.
  drivers: net: sis900: use setup_timer() helper.
  drivers: net: packetengines: use setup_timer() helper.
  drivers: net: mlx5: use setup_timer() helper.
  drivers: net: mlx4: use setup_timer() helper.
  drivers: net: pxa168: use setup_timer() helper.
  drivers: net: fealnx: use setup_timer() helper.
  drivers: net: dmfe: use setup_timer() helper.
  drivers: net: bnxt: use setup_timer() helper.
  drivers: net: amd: use setup_timer() helper.
  drivers: net: adi: use setup_timer() helper.
  drivers: net: can: sja1000: use setup_timer() helper.
  drivers: net: caif: use setup_timer() helper.
  drivers: net: appletalk: use setup_timer() helper.
  drivers: net: dscc: use setup_timer() helper.
  drivers: net: hdlc_ppp: use setup_timer() helper.
  drivers: net: hamradio: use setup_timer() helper.
  drivers: net: cpsw_ale: use setup_timer() helper.
  drivers: net: stmmac: use setup_timer() helper.
  drivers: net: packetengines: use setup_timer() helper.
  drivers: net: i40evf: use setup_timer() helper.
  drivers: net: uli526x: use setup_timer() helper.
  drivers: net: enic: use setup_timer() helper.
  drivers: net: cxgb: use setup_timer() helper.
  drivers: net: bnx2x: use setup_timer() helper.
  drivers: net: lmc: use setup_timer() helper.

 drivers/net/appletalk/cops.c                              |  4 +---
 drivers/net/appletalk/ltpc.c                              |  4 +---
 drivers/net/arcnet/arcnet.c                               |  4 +---
 drivers/net/caif/caif_hsi.c                               | 15 ++++++---------
 drivers/net/can/grcan.c                                   | 10 ++++------
 drivers/net/can/sja1000/peak_pcmcia.c                     |  4 +---
 drivers/net/can/usb/peak_usb/pcan_usb.c                   |  5 ++---
 drivers/net/eql.c                                         |  4 +---
 drivers/net/ethernet/adi/bfin_mac.c                       |  5 ++---
 drivers/net/ethernet/agere/et131x.c                       |  5 ++---
 drivers/net/ethernet/amd/a2065.c                          |  7 +++----
 drivers/net/ethernet/amd/am79c961a.c                      |  4 +---
 drivers/net/ethernet/amd/amd8111e.c                       |  5 ++---
 drivers/net/ethernet/amd/declance.c                       |  6 +++---
 drivers/net/ethernet/amd/pcnet32.c                        |  5 ++---
 drivers/net/ethernet/amd/sunlance.c                       |  5 ++---
 drivers/net/ethernet/broadcom/b44.c                       |  4 +---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c              |  5 ++---
 drivers/net/ethernet/broadcom/bnx2.c                      |  4 +---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c          |  4 +---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                 |  4 +---
 drivers/net/ethernet/broadcom/tg3.c                       |  4 +---
 drivers/net/ethernet/chelsio/cxgb/sge.c                   |  5 ++---
 drivers/net/ethernet/cisco/enic/enic_clsf.h               |  5 ++---
 drivers/net/ethernet/cisco/enic/enic_main.c               |  5 ++---
 drivers/net/ethernet/dec/tulip/de4x5.c                    |  5 ++---
 drivers/net/ethernet/dec/tulip/dmfe.c                     |  4 +---
 drivers/net/ethernet/dec/tulip/uli526x.c                  |  4 +---
 drivers/net/ethernet/dec/tulip/winbond-840.c              |  4 +---
 drivers/net/ethernet/dlink/sundance.c                     |  4 +---
 drivers/net/ethernet/fealnx.c                             |  8 ++------
 drivers/net/ethernet/intel/e1000e/netdev.c                | 11 ++++-------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c           |  5 ++---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c               |  5 ++---
 drivers/net/ethernet/marvell/pxa168_eth.c                 |  5 ++---
 drivers/net/ethernet/mellanox/mlx4/catas.c                |  4 +---
 drivers/net/ethernet/mellanox/mlx5/core/health.c          |  4 +---
 drivers/net/ethernet/natsemi/natsemi.c                    |  4 +---
 drivers/net/ethernet/natsemi/ns83820.c                    |  4 +---
 drivers/net/ethernet/packetengines/hamachi.c              |  4 +---
 drivers/net/ethernet/packetengines/yellowfin.c            |  4 +---
 drivers/net/ethernet/qlogic/qla3xxx.c                     |  4 +---
 drivers/net/ethernet/realtek/atp.c                        |  4 +---
 drivers/net/ethernet/sis/sis900.c                         |  4 +---
 drivers/net/ethernet/smsc/epic100.c                       |  4 +---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c         |  4 +---
 drivers/net/ethernet/sun/cassini.c                        |  5 +----
 drivers/net/ethernet/sun/niu.c                            |  4 +---
 drivers/net/ethernet/sun/sungem.c                         |  4 +---
 drivers/net/ethernet/ti/cpsw_ale.c                        |  4 +---
 drivers/net/ethernet/toshiba/spider_net.c                 | 12 +++++-------
 drivers/net/hamradio/6pack.c                              |  4 +---
 drivers/net/hippi/rrunner.c                               |  4 +---
 drivers/net/slip/slip.c                                   |  8 ++------
 drivers/net/wan/dscc4.c                                   |  4 +---
 drivers/net/wan/hdlc_cisco.c                              |  4 +---
 drivers/net/wan/hdlc_ppp.c                                |  4 +---
 drivers/net/wan/lmc/lmc_main.c                            |  4 +---
 drivers/net/wan/sdla.c                                    |  4 +---
 drivers/net/wireless/ath/ath6kl/txrx.c                    |  4 +---
 drivers/net/wireless/atmel/atmel.c                        |  5 ++---
 .../net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c   |  5 ++---
 drivers/net/wireless/rsi/rsi_91x_hal.c                    |  5 ++---
 drivers/net/xen-netback/interface.c                       |  3 +--
 64 files changed, 102 insertions(+), 216 deletions(-)

-- 
2.7.4
