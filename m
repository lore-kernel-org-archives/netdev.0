From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 03 Nov 2008 23:34:43 -0800 (PST)
Message-ID: <20081103.233443.173719917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752698AbYKDHfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 02:35:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nothing terribly exciting in here, some small driver fixups,
a partial revert of a smc91x driver change to fix the build
on some systems, and some UDP ICMP mib statistic fixes.

Please pull, thanks a lot!

The following changes since commit 48dcc33e5e11de0f76b65b113988dbc930d17395:
  Jianjun Kong (1):
        af_unix: netns: fix problem of return value

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (2):
      fs_enet: fix polling
      xfrm: Fix xfrm_policy_gc_lock handling.

Arnaud Ebalard (1):
      XFRM: copy_to_user_kmaddress() reports local address twice

David S. Miller (2):
      SMC91x: Fix compilation on some platforms.
      niu: Use pci_ioremap_bar().

Eilon Greenstein (4):
      bnx2x: Removing the PMF indication when unloading
      bnx2x: PCI configuration bug on big-endian
      bnx2x: Calling netif_carrier_off at the end of the probe
      bnx2x: Version Update

Jeff Kirsher (1):
      net: kconfig cleanup

Lennert Buytenhek (1):
      mv643xx_eth: fix SMI bus access timeouts

Wei Yongjun (2):
      udp: Fix the SNMP counter of UDP_MIB_INDATAGRAMS
      udp: Fix the SNMP counter of UDP_MIB_INERRORS

Will Newton (1):
      drivers/net/smc911x.c: Fix lockdep warning on xmit.

 drivers/net/Kconfig                |   18 +++++++++++++++---
 drivers/net/bnx2x_init.h           |    9 +++++----
 drivers/net/bnx2x_main.c           |   10 ++++++----
 drivers/net/fs_enet/fs_enet-main.c |    6 ++++--
 drivers/net/mv643xx_eth.c          |    9 ++++++---
 drivers/net/niu.c                  |    6 +-----
 drivers/net/smc911x.c              |    2 +-
 drivers/net/smc91x.c               |    2 ++
 net/ipv6/udp.c                     |   28 +++++++++++++++++++++-------
 net/xfrm/xfrm_policy.c             |    4 ++--
 net/xfrm/xfrm_user.c               |    2 +-
 11 files changed, 64 insertions(+), 32 deletions(-)
