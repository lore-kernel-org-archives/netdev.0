From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 0/6] mlx4: Fixes and enhancements to SRIOV code.
Date: Thu, 19 Jan 2012 21:42:22 +0200
Message-ID: <4F18721E.5040901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:43134 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932675Ab2ASTm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:42:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This is V1 of a series of enhancements and some fixes for mlx4 SRIOV code.
Main changes are: 
- Correct ethtool statistics report for each VF/PF.
- The ability of each function to decide on which event queue to receive asynchronous events.
- Bug fixes.

Thanks,
Yevgeny
---

Change from V0:
	using hweight64()

 drivers/net/ethernet/mellanox/mlx4/cmd.c              |    9 ++
 drivers/net/ethernet/mellanox/mlx4/cq.c               |    4 -
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c       |   66 +++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |   38 +++++++---
 drivers/net/ethernet/mellanox/mlx4/eq.c               |   21 ++---
 drivers/net/ethernet/mellanox/mlx4/fw.c               |    7 -
 drivers/net/ethernet/mellanox/mlx4/fw.h               |    1
 drivers/net/ethernet/mellanox/mlx4/main.c             |    3
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |    8 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h          |    1
 drivers/net/ethernet/mellanox/mlx4/mr.c               |    2
 drivers/net/ethernet/mellanox/mlx4/pd.c               |    3
 drivers/net/ethernet/mellanox/mlx4/port.c             |   23 ++++++
 drivers/net/ethernet/mellanox/mlx4/profile.c          |    2
 drivers/net/ethernet/mellanox/mlx4/qp.c               |    2
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |   39 ----------
 drivers/net/ethernet/mellanox/mlx4/srq.c              |    2
 include/linux/mlx4/device.h                           |    1
 18 files changed, 133 insertions(+), 99 deletions(-)
