From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 11 Oct 2008 15:11:53 -0700 (PDT)
Message-ID: <20081011.151153.223811080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbYJKWMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 18:12:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This includes:

1) The bad IP_VS dependency randconfig build failure.

2) GRE tunnel rtnl_link initialization (bad memset size),
   from Herbert Xu.

3) External PHY detection fix in smc911x from Guennadi Liakhovetski.

4) E1000 VLAN feature flags should include TSO and CSUM offloads,
   from Patrick McHardy and ACK'd by Intel folks.

Please pull, thanks a lot!

The following changes since commit bf6f51e3a46f6a602853d3cbacd05864bc6e2a37:
  Linus Torvalds (1):
        Merge phase #3 (IOMMU) of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      ipvs: Add proper dependencies on IP_VS, and fix description header line.

Guennadi Liakhovetski (1):
      smc911x: Fix external PHY detection

Herbert Xu (1):
      gre: Initialise rtnl_link tunnel parameters properly

Patrick McHardy (1):
      e1000: allow VLAN devices to use TSO and CSUM offload

 drivers/net/e1000/e1000_main.c |    5 +++++
 drivers/net/smc911x.c          |    3 +++
 net/ipv4/ip_gre.c              |    2 +-
 net/netfilter/ipvs/Kconfig     |    4 ++--
 4 files changed, 11 insertions(+), 3 deletions(-)
