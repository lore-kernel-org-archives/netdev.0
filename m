From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/3] Remove casts to same type
Date: Mon,  4 Jun 2012 15:44:15 -0700
Message-ID: <cover.1338849364.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59197 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756253Ab2FDWoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 18:44:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding casts of objects to the same type is unnecessary
and confusing for a human reader.

Remove them via coccinelle script.

No additional sparse warnings are emitted.

Joe Perches (3):
  ethernet: Remove casts to same type
  wireless: Remove casts to same type
  drivers: net: Remove casts to same type

 drivers/net/appletalk/cops.c                       |    2 +-
 drivers/net/can/bfin_can.c                         |    2 +-
 drivers/net/can/mcp251x.c                          |    3 +-
 drivers/net/ethernet/8390/apne.c                   |    2 +-
 drivers/net/ethernet/aeroflex/greth.c              |    8 ++--
 drivers/net/ethernet/amd/declance.c                |    4 +-
 drivers/net/ethernet/apple/macmace.c               |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c      |    6 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    9 ++--
 drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   35 ++++++---------
 drivers/net/ethernet/atheros/atlx/atl1.c           |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    3 +-
 drivers/net/ethernet/broadcom/cnic.c               |   12 +++---
 drivers/net/ethernet/brocade/bna/cna_fwimg.c       |    4 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |    2 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |    5 +-
 drivers/net/ethernet/dec/tulip/de4x5.c             |    2 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |    2 +-
 drivers/net/ethernet/hp/hp100.c                    |    6 +-
 drivers/net/ethernet/i825xx/lp486e.c               |    8 ++--
 drivers/net/ethernet/i825xx/sun3_82586.c           |    4 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    4 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    4 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 +-
 drivers/net/ethernet/neterion/s2io.c               |   14 +++---
 drivers/net/ethernet/neterion/vxge/vxge-config.c   |    8 ++--
 drivers/net/ethernet/neterion/vxge/vxge-config.h   |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |    8 ++--
 drivers/net/ethernet/neterion/vxge/vxge-traffic.c  |    5 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                |    4 +-
 drivers/net/ethernet/smsc/smsc9420.c               |    3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 drivers/net/ethernet/sun/sunqe.c                   |    2 +-
 drivers/net/ethernet/via/via-velocity.c            |    2 +-
 drivers/net/fddi/defxx.c                           |    4 +-
 drivers/net/fddi/skfp/pmf.c                        |    8 ++--
 drivers/net/hamradio/mkiss.c                       |    8 ++--
 drivers/net/hyperv/netvsc.c                        |    2 +-
 drivers/net/irda/ali-ircc.c                        |    6 +-
 drivers/net/irda/au1k_ir.c                         |    2 +-
 drivers/net/slip/slip.c                            |    4 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    2 +-
 drivers/net/wan/x25_asy.c                          |    2 +-
 drivers/net/wimax/i2400m/fw.c                      |    2 +-
 drivers/net/wireless/adm8211.c                     |    3 +-
 drivers/net/wireless/airo.c                        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    3 +-
 drivers/net/wireless/ath/carl9170/cmd.c            |    2 +-
 drivers/net/wireless/ath/carl9170/rx.c             |    4 +-
 drivers/net/wireless/atmel.c                       |    4 +-
 drivers/net/wireless/b43legacy/dma.c               |    2 +-
 drivers/net/wireless/b43legacy/xmit.c              |    6 +--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    2 +-
 drivers/net/wireless/hostap/hostap_proc.c          |    3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    2 +-
 drivers/net/wireless/libertas/debugfs.c            |    4 +-
 drivers/net/wireless/libertas/if_usb.c             |    2 +-
 drivers/net/wireless/libertas_tf/if_usb.c          |    2 +-
 drivers/net/wireless/mwifiex/11n.c                 |   14 ++----
 drivers/net/wireless/mwifiex/11n.h                 |    3 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   18 ++------
 drivers/net/wireless/mwifiex/cfg80211.c            |    2 +-
 drivers/net/wireless/mwifiex/join.c                |   20 +++------
 drivers/net/wireless/mwifiex/scan.c                |   24 ++++------
 drivers/net/wireless/mwifiex/sta_cmd.c             |   16 ++-----
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   24 ++++------
 drivers/net/wireless/mwifiex/sta_event.c           |    2 +-
 drivers/net/wireless/p54/eeprom.c                  |    2 +-
 drivers/net/wireless/p54/fwio.c                    |    2 +-
 drivers/net/wireless/prism54/islpci_eth.c          |    2 +-
 drivers/net/wireless/ray_cs.c                      |    2 +-
 drivers/net/wireless/rtlwifi/base.c                |    2 +-
 drivers/net/wireless/rtlwifi/cam.c                 |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |   14 +++---
 drivers/net/wireless/rtlwifi/efuse.c               |    4 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   14 +++---
 drivers/net/wireless/rtlwifi/ps.c                  |   10 ++--
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   43 +++++++++---------
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   43 +++++++++---------
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |   34 +++++++-------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   46 +++++++++----------
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/ti/wlcore/tx.c                |    3 +-
 drivers/net/wireless/zd1211rw/zd_chip.h            |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.h             |    2 +-
 102 files changed, 308 insertions(+), 368 deletions(-)

-- 
1.7.8.111.gad25c.dirty
