From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/10 - GIT PULL] drivers: net: Next block of
	Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:09:54 -0700
Message-ID: <cover.1380056108.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, cbe-oss-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The following changes since commit b0983d3c9b132c33b6fb2e28d157a1edc18a173c:

  tcp: fix dynamic right sizing (2013-09-24 11:07:32 -0400)

are available in the git repository at:

  git://repo.or.cz/linux-2.6/trivial-mods.git 20130924_dn_externs_2

for you to fetch changes up to 294da3abaa73a0b69fd54e442b0b5bd9455b7be6:

  irda: Remove extern from function prototypes (2013-09-24 12:54:17 -0700)

----------------------------------------------------------------
Joe Perches (10):
  ibm/emac: Remove extern from function prototypes
  intel: Remove extern from function prototypes
  oki-semi: Remove extern from function prototypes
  qlogic: Remove extern from function prototypes
  sfc: Remove extern from function prototypes
  stmicro: Remove extern from function prototypes
  ti: Remove extern from function prototypes
  toshiba: Remove extern from function prototypes
  fddi/skfp: Remove extern from function prototypes
  irda: Remove extern from function prototypes

 drivers/net/ethernet/ibm/emac/debug.h             |  14 +-
 drivers/net/ethernet/ibm/emac/rgmii.h             |  18 +-
 drivers/net/ethernet/ibm/emac/tah.h               |  14 +-
 drivers/net/ethernet/ibm/emac/zmii.h              |  18 +-
 drivers/net/ethernet/intel/e1000/e1000.h          |  32 ++--
 drivers/net/ethernet/intel/e1000e/e1000.h         |  45 +++--
 drivers/net/ethernet/intel/igb/e1000_82575.h      |  16 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h         |   6 +-
 drivers/net/ethernet/intel/igb/e1000_i210.h       |  38 ++--
 drivers/net/ethernet/intel/igb/e1000_mac.h        |   2 +-
 drivers/net/ethernet/intel/igb/igb.h              |  73 ++++----
 drivers/net/ethernet/intel/igbvf/igbvf.h          |  22 +--
 drivers/net/ethernet/intel/ixgb/ixgb.h            |  22 +--
 drivers/net/ethernet/intel/ixgb/ixgb_hw.h         |  25 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          | 172 +++++++++---------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  34 ++--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h   |  56 +++---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h   |   5 +-
 drivers/net/ethernet/qlogic/qlge/qlge.h           |  58 +++---
 drivers/net/ethernet/sfc/efx.h                    | 104 ++++++-----
 drivers/net/ethernet/sfc/mcdi.h                   | 120 ++++++-------
 drivers/net/ethernet/sfc/mdio_10g.h               |  26 ++-
 drivers/net/ethernet/sfc/nic.h                    | 210 +++++++++++-----------
 drivers/net/ethernet/sfc/phy.h                    |   8 +-
 drivers/net/ethernet/sfc/selftest.h               |  15 +-
 drivers/net/ethernet/stmicro/stmmac/common.h      |  12 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h   |  17 +-
 drivers/net/ethernet/stmicro/stmmac/mmc.h         |   6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  10 +-
 drivers/net/ethernet/ti/cpts.h                    |   9 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.h      |  29 ++-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.h |   6 +-
 drivers/net/ethernet/toshiba/spider_net.h         |   4 +-
 drivers/net/fddi/skfp/h/smc.h                     |  28 +--
 drivers/net/irda/sir-dev.h                        |  29 +--
 35 files changed, 631 insertions(+), 672 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60133471&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
