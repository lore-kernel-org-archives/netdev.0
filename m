From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/5] Mellanox driver update to 4.3-rc4
Date: Thu,  8 Oct 2015 15:26:14 +0300
Message-ID: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57443 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755146AbbJHM0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 08:26:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

Small set of fixes for net, which includes Carol's patches, a fix
from Achiad to have the right behaviour for mlx5 Eth devices w.r.t 
VLANs in promiscuous mode, a good-bye patch from Ido who left Mellanox
and the 1st patch from Jiri to our NIC drivers (I love one-liners)...

Or.

Achiad Shochat (1):

Achiad Shochat (1):
  net/mlx5e: Disable VLAN filter in promiscuous mode

Carol L Soto (2):
  net/mlx4_core: Avoid failing the interrupts test
  net/mlx4: Avoid going into legacy completion mode when unnecessary

Ido Shamay (1):
  MAINTAINERS: Update mlx4_en driver entry

Jiri Pirko (1):
  net/mlx5: Fix typo in mlx5_query_port_pvlc

 MAINTAINERS                                             |  1 -
 drivers/net/ethernet/mellanox/mlx4/eq.c                 |  4 ++++
 drivers/net/ethernet/mellanox/mlx4/main.c               | 10 ++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c | 16 ++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/port.c          |  2 +-
 5 files changed, 21 insertions(+), 12 deletions(-)

-- 
2.3.7
