From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/62] drivers/net: Use static const
Date: Sat, 20 Nov 2010 18:38:01 -0800
Message-ID: <cover.1290305773.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	ath5k-devel@lists.ath5k.org, ath9k-devel@lists.ath9k.org,
	liberta
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

Summary of sizes old and new.  Compiled allyesconfig x86 only.

   text	   data	    bss	    dec	    hex	filename
2075402   67170  466644 2609216  27d040 (TOTALS) -new
2074597   70614  466668 2611879  27daa7 (TOTALS) -old

Joe Perches (62):
  3c501: Use static const
  3c503: Use static const
  3c507: Use static const
  3c527: Use static const
  at1700: Use static const
  benet: Use static const
  bnx2: Use static const
  bnx2x: Use static const
  can: Use static const
  chelsio: Use static const
  cxgb3: Use static const
  cxgb3: Use static const
  cxgb4: Use static const
  cxgb4vf: Use static const
  e1000: Use static const
  e1000: Use static const
  e1000e: Use static const
  e2100: Use static const
  eepro: Use static const
  eexpress: Use static const
  gianfar: Use static const
  hp: Use static const
  igb: Use static const
  irda: Use static const
  irda: Use static const
  ixgbe: Use static const
  ixgbevf: Use static const
  ixgb: Use static const
  jme: Use static const
  ksz884x: Use static const
  netxen: Use static const
  ni52: Use static const
  ni65: Use static const
  pcmcia: Use static const
  qlcnic: Use static const
  qlge: Use static const
  r8169: Use static const
  s2io: Use static const
  skfp: Use static const
  skge: Use static const
  smc-ultra: Use static const
  tg3: Use static const
  tokenring: Use static const
  tulip: Use static const
  tulip: Use static const
  usb: Use static const
  vmxnet3: Use static const
  wan: Use static const
  wd: Use static const
  ar9170: Use const
  ath5k: Use static const
  ath9k: Use static const
  carl9170: Use static const
  atmel: Use static const
  b43: Use static const
  iwlwifi: Use static const
  libertas: Use static const
  ray_cs: Use static const
  rndis_wlan: Use static const
  rt2x00: Use static const
  wl12xx: Use static const
  zd1211rw: Use const

 drivers/net/3c501.c                            |    4 +-
 drivers/net/3c503.c                            |    4 +-
 drivers/net/3c507.c                            |    4 +-
 drivers/net/3c527.c                            |    6 +-
 drivers/net/at1700.c                           |    6 +-
 drivers/net/benet/be_ethtool.c                 |    4 +-
 drivers/net/benet/be_main.c                    |   10 ++--
 drivers/net/bnx2.c                             |   46 ++++++++++++-----------
 drivers/net/bnx2x/bnx2x_main.c                 |    6 ++-
 drivers/net/can/sja1000/plx_pci.c              |    2 +-
 drivers/net/chelsio/sge.c                      |   10 ++---
 drivers/net/cxgb3/ael1002.c                    |   24 ++++++------
 drivers/net/cxgb3/t3_hw.c                      |    2 +-
 drivers/net/cxgb4/t4_hw.c                      |   48 ++++++++++++------------
 drivers/net/cxgb4vf/t4vf_hw.c                  |    2 +-
 drivers/net/e1000/e1000_hw.c                   |    8 ++--
 drivers/net/e1000/e1000_param.c                |   13 +++---
 drivers/net/e1000e/phy.c                       |   11 +++--
 drivers/net/e2100.c                            |    2 +-
 drivers/net/eepro.c                            |    9 ++--
 drivers/net/eexpress.c                         |    2 +-
 drivers/net/gianfar.c                          |   10 +++--
 drivers/net/hp.c                               |    6 +-
 drivers/net/igb/e1000_phy.c                    |   11 +++--
 drivers/net/irda/act200l-sir.c                 |    2 +-
 drivers/net/irda/donauboe.c                    |    4 +-
 drivers/net/ixgb/ixgb_param.c                  |   21 +++++-----
 drivers/net/ixgbe/ixgbe_ethtool.c              |   22 ++++++----
 drivers/net/ixgbevf/ethtool.c                  |   18 +++++---
 drivers/net/jme.c                              |    4 +-
 drivers/net/ksz884x.c                          |   20 +++++-----
 drivers/net/netxen/netxen_nic_hw.c             |   16 +++++---
 drivers/net/ni52.c                             |    4 +-
 drivers/net/ni65.c                             |    4 +-
 drivers/net/pcmcia/nmclan_cs.c                 |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c                 |   15 ++++---
 drivers/net/qlge/qlge_main.c                   |   13 +++---
 drivers/net/r8169.c                            |    2 +-
 drivers/net/s2io.c                             |   20 ++++++----
 drivers/net/skfp/smt.c                         |    4 +-
 drivers/net/skge.c                             |    4 +-
 drivers/net/smc-ultra.c                        |    8 +++-
 drivers/net/tg3.c                              |   26 ++++++-------
 drivers/net/tokenring/ibmtr.c                  |    5 +-
 drivers/net/tulip/de2104x.c                    |   18 ++++++---
 drivers/net/tulip/tulip_core.c                 |   15 ++++---
 drivers/net/usb/hso.c                          |   39 ++++++++-----------
 drivers/net/vmxnet3/vmxnet3_drv.c              |    4 +-
 drivers/net/wan/dscc4.c                        |    6 +-
 drivers/net/wd.c                               |    2 +-
 drivers/net/wireless/ath/ar9170/cmd.c          |    2 +-
 drivers/net/wireless/ath/ath5k/ani.c           |   34 ++++++++--------
 drivers/net/wireless/ath/ath9k/ani.c           |    8 ++--
 drivers/net/wireless/ath/ath9k/ar5008_phy.c    |   32 ++++++++-------
 drivers/net/wireless/ath/ath9k/ar9002_phy.c    |   12 +++--
 drivers/net/wireless/ath/ath9k/ar9003_calib.c  |   10 ++--
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    8 ++-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c  |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c     |   12 +++--
 drivers/net/wireless/ath/ath9k/eeprom_9287.c   |   14 +++---
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |   17 +++++---
 drivers/net/wireless/ath/ath9k/htc_drv_init.c  |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c            |    9 ++--
 drivers/net/wireless/ath/ath9k/rc.c            |    6 +-
 drivers/net/wireless/ath/carl9170/cmd.c        |    2 +-
 drivers/net/wireless/atmel.c                   |    6 ++-
 drivers/net/wireless/b43/phy_common.c          |    8 ++-
 drivers/net/wireless/b43/phy_n.c               |    9 ++--
 drivers/net/wireless/iwlwifi/iwl-3945.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |    6 +-
 drivers/net/wireless/libertas/cfg.c            |    2 +-
 drivers/net/wireless/libertas/rx.c             |    4 +-
 drivers/net/wireless/ray_cs.c                  |    4 +-
 drivers/net/wireless/rndis_wlan.c              |    9 +++-
 drivers/net/wireless/rt2x00/rt2800lib.c        |    2 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c       |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.c        |    4 +-
 78 files changed, 422 insertions(+), 362 deletions(-)

-- 
1.7.3.2.245.g03276.dirty
