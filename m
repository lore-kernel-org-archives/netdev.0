From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 02 Dec 2014 20:39:07 -0800 (PST)
Message-ID: <20141202.203907.2100510423992272844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fill in ethtool link parameters for all link types in cxgb4,
   from Hariprasad Shenai.

2) Fix probe regressions in stmmac driver, from Huacai Chen.

3) Network namespace leaks on errirs in rtnetlink, from Nicolas
   Dichtel.

4) Remove erroneous BUG check which can actually trigger
   legitimately, in xen-netfront.  From Seth Forshee.

5) Validate length of IFLA_BOND_ARP_IP_TARGET netlink
   attributes, from Thomas Grag.

Please pull, thanks a lot.

The following changes since commit 7a5a4f978750756755dc839014e13d1b088ccc8e:

  Merge branch 'irq-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip (2014-11-29 10:49:24 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 4c2d518695338801110bc166eece6aa02822b0b4:

  cxgb4: Fill in supported link mode for SFP modules (2014-12-02 19:57:49 -0800)

----------------------------------------------------------------
Hariprasad Shenai (1):
      cxgb4: Fill in supported link mode for SFP modules

Huacai Chen (1):
      stmmac: platform: Move plat_dat checking earlier

Mitsuhiro Kimura (2):
      sh_eth: Fix skb alloc size and alignment adjust rule.
      sh_eth: Fix sleeping function called from invalid context

Nicolas Dichtel (1):
      rtnetlink: release net refcnt on error in do_setlink()

Seth Forshee (1):
      xen-netfront: Remove BUGs on paged skb data which crosses a page boundary

Thomas Graf (1):
      bond: Check length of IFLA_BOND_ARP_IP_TARGET attributes

 drivers/net/bonding/bond_netlink.c                    |    7 ++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |    8 ++++++--
 drivers/net/ethernet/renesas/sh_eth.c                 |   96 ++++++++++++++++++++++++++++++++++++++++++++++++------------------------------------------------
 drivers/net/ethernet/renesas/sh_eth.h                 |    5 +++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |   18 +++++++++---------
 drivers/net/xen-netfront.c                            |    5 -----
 net/core/rtnetlink.c                                  |    1 +
 7 files changed, 73 insertions(+), 67 deletions(-)
