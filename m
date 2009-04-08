From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 08 Apr 2009 16:08:09 -0700 (PDT)
Message-ID: <20090408.160809.197973352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753964AbZDHXIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 19:08:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A build fix here, a chip reset fix there, and the new
virtual-function IGB driver from Intel.

Plus three netfilter bug fixes from Patrick McHardy.

Please pull, thanks a lot!

The following changes since commit 577c9c456f0e1371cbade38eaf91ae8e8a308555:
  Linus Torvalds (1):
        Linux 2.6.30-rc1

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alex Riesen (1):
      netfilter: fix selection of "LED" target in netfilter

Alexander Duyck (2):
      igbvf: add new driver to support 82576 virtual functions
      igb: remove sysfs entry that was used to set the number of vfs

Bastian Blank (1):
      bnx2: Don't use reserved names

Dan Carpenter (1):
      niu: Fix error handling

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      niu: Fix unused variable warning.

Eric Dumazet (1):
      netfilter: ip6tables regression fix

Florian Fainelli (1):
      r6040: set MODULE_VERSION

Lennert Buytenhek (1):
      mv643xx_eth: don't reset the rx coal timer on interface up

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix regression in expectation handling

Randy Dunlap (1):
      ethoc: fix library build errors

Sascha Hauer (1):
      FEC driver: add missing #endif

Steve Glendinning (1):
      smsc911x: correct debugging message on mii read timeout

Yang Hongyang (1):
      drivers/net/eql.c: Fix a dev leakage.

 drivers/net/Kconfig                         |   23 +
 drivers/net/Makefile                        |    1 +
 drivers/net/bnx2.c                          |   26 +-
 drivers/net/eql.c                           |    2 +
 drivers/net/fec.c                           |    1 +
 drivers/net/igb/igb_main.c                  |  159 +-
 drivers/net/igbvf/Makefile                  |   38 +
 drivers/net/igbvf/defines.h                 |  125 ++
 drivers/net/igbvf/ethtool.c                 |  540 +++++
 drivers/net/igbvf/igbvf.h                   |  335 +++
 drivers/net/igbvf/mbx.c                     |  350 ++++
 drivers/net/igbvf/mbx.h                     |   75 +
 drivers/net/igbvf/netdev.c                  | 2919 +++++++++++++++++++++++++++
 drivers/net/igbvf/regs.h                    |  108 +
 drivers/net/igbvf/vf.c                      |  398 ++++
 drivers/net/igbvf/vf.h                      |  265 +++
 drivers/net/mv643xx_eth.c                   |    4 +-
 drivers/net/niu.c                           |    3 +-
 drivers/net/r6040.c                         |    1 +
 drivers/net/smsc911x.c                      |    2 +-
 include/net/netfilter/nf_conntrack_expect.h |    5 +-
 net/ipv6/netfilter/ip6_tables.c             |    2 +
 net/netfilter/Kconfig                       |    2 +-
 net/netfilter/nf_conntrack_expect.c         |   30 +-
 24 files changed, 5266 insertions(+), 148 deletions(-)
 create mode 100644 drivers/net/igbvf/Makefile
 create mode 100644 drivers/net/igbvf/defines.h
 create mode 100644 drivers/net/igbvf/ethtool.c
 create mode 100644 drivers/net/igbvf/igbvf.h
 create mode 100644 drivers/net/igbvf/mbx.c
 create mode 100644 drivers/net/igbvf/mbx.h
 create mode 100644 drivers/net/igbvf/netdev.c
 create mode 100644 drivers/net/igbvf/regs.h
 create mode 100644 drivers/net/igbvf/vf.c
 create mode 100644 drivers/net/igbvf/vf.h
