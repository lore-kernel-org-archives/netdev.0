From: Joe Perches <joe@perches.com>
Subject: [RFC net-next 0/2] Create ancient subdirectories for old hardware
Date: Fri, 18 Mar 2016 17:33:29 -0700
Message-ID: <cover.1458347329.git.joe@perches.com>
References: <1458340518.26915.30.camel@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458340518.26915.30.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maybe something like this:

Old, rare, and unsupported hardware should be exposed as ancient.

The drivers for these ancient hardwares are generally untested with
current kernels.

Joe Perches (2):
  drivers/net: Create an ANCIENT_NETDEVICES symbol
  chelsio: Move original cxgb driver into ancient subdirectory

 drivers/net/Kconfig                                   | 19 +++++++++++++++++++
 drivers/net/ethernet/chelsio/Kconfig                  |  2 +-
 drivers/net/ethernet/chelsio/Makefile                 |  2 +-
 drivers/net/ethernet/chelsio/ancient/Makefile         |  1 +
 .../net/ethernet/chelsio/{ => ancient}/cxgb/Makefile  |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/common.h  |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/cphy.h    |  0
 .../ethernet/chelsio/{ => ancient}/cxgb/cpl5_cmd.h    |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/cxgb2.c   |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/elmer0.h  |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/espi.c    |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/espi.h    |  0
 .../ethernet/chelsio/{ => ancient}/cxgb/fpga_defs.h   |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/gmac.h    |  0
 .../ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.c   |  0
 .../ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.h   |  0
 .../ethernet/chelsio/{ => ancient}/cxgb/mv88x201x.c   |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/my3126.c  |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/pm3393.c  |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/regs.h    |  0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.c |  0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.h |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/subr.c    |  0
 .../chelsio/{ => ancient}/cxgb/suni1x10gexp_regs.h    |  0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.c  |  0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.h  |  0
 .../net/ethernet/chelsio/{ => ancient}/cxgb/vsc7326.c |  0
 .../ethernet/chelsio/{ => ancient}/cxgb/vsc7326_reg.h |  0
 28 files changed, 22 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/ancient/Makefile
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/Makefile (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/common.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cphy.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cpl5_cmd.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cxgb2.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/elmer0.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/espi.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/espi.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/fpga_defs.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/gmac.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88x201x.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/my3126.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/pm3393.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/regs.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/subr.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/suni1x10gexp_regs.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/vsc7326.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/vsc7326_reg.h (100%)

-- 
2.6.3.368.gf34be46
