From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/5] Use ETH_ALEN
Date: Wed, 16 Nov 2011 11:38:01 -0800
Message-ID: <cover.1321472142.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove other #defines and uses in favor of ETH_ALEN

Joe Perches (5):
  ethernet: Convert MAC_ADDR_LEN uses to ETH_ALEN
  ethernet: Convert ETHER_ADDR_LEN uses to ETH_ALEN
  bna: Convert MAC_ADDRLEN uses to ETH_ALEN
  amd8111e:  Convert ETH_ADDR_LEN uses to ETH_ALEN
  ucc_geth: Convert ENET_NUM_OCTETS_PER_ADDRESS uses to ETH_ALEN

 drivers/net/ethernet/8390/8390.h           |    2 -
 drivers/net/ethernet/8390/apne.c           |    2 +-
 drivers/net/ethernet/8390/ax88796.c        |    5 +-
 drivers/net/ethernet/8390/es3210.c         |    2 +-
 drivers/net/ethernet/8390/hp-plus.c        |    2 +-
 drivers/net/ethernet/8390/hp.c             |    2 +-
 drivers/net/ethernet/8390/hydra.c          |    2 +-
 drivers/net/ethernet/8390/lne390.c         |    4 +-
 drivers/net/ethernet/8390/ne-h8300.c       |    2 +-
 drivers/net/ethernet/8390/ne.c             |    4 +-
 drivers/net/ethernet/8390/ne2.c            |    2 +-
 drivers/net/ethernet/8390/ne3210.c         |    2 +-
 drivers/net/ethernet/8390/stnic.c          |    2 +-
 drivers/net/ethernet/8390/zorro8390.c      |    2 +-
 drivers/net/ethernet/amd/amd8111e.c        |    6 +-
 drivers/net/ethernet/amd/amd8111e.h        |    1 -
 drivers/net/ethernet/amd/nmclan_cs.c       |   12 ++---
 drivers/net/ethernet/broadcom/sb1250-mac.c |    3 +-
 drivers/net/ethernet/brocade/bna/cna.h     |    3 +-
 drivers/net/ethernet/freescale/gianfar.c   |   12 +++---
 drivers/net/ethernet/freescale/gianfar.h   |    3 -
 drivers/net/ethernet/freescale/ucc_geth.c  |    2 +-
 drivers/net/ethernet/freescale/ucc_geth.h  |    6 +-
 drivers/net/ethernet/micrel/ksz884x.c      |   59 +++++++++++++--------------
 drivers/net/ethernet/realtek/r8169.c       |    5 +--
 drivers/net/ethernet/sis/sis190.c          |    8 +--
 26 files changed, 68 insertions(+), 87 deletions(-)

-- 
1.7.6.405.gc1be0
