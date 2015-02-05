From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/3] mlx4 driver fixes for the HA/LAG support and reset flow
Date: Thu,  5 Feb 2015 15:52:43 +0200
Message-ID: <1423144366-11814-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39738 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757417AbbBENxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 08:53:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

There are two fixes to mlx4 HA/LAG support from Moni and a patch from Yishai
which does further hardening of the mlx4 reset support for IB kernel ULPs.

Or.

Moni Shoua (2):
  net/bonding: Fix potential bad memory access during bonding events
  IB/mlx4: Always use the correct port for mirrored multicast attachments

Yishai Hadas (1):
  IB/mlx4_ib: Reset flow support for IB kernel ULPs

 drivers/infiniband/hw/mlx4/cq.c      |   57 +++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx4/main.c    |   72 +++++++++++++++++++++++++++++++++-
 drivers/infiniband/hw/mlx4/mlx4_ib.h |    9 ++++
 drivers/infiniband/hw/mlx4/qp.c      |   59 +++++++++++++++++++++++++---
 drivers/infiniband/hw/mlx4/srq.c     |    8 ++++
 drivers/net/bonding/bond_main.c      |   28 +++++--------
 include/linux/mlx4/device.h          |    2 +
 include/net/bonding.h                |    2 +-
 8 files changed, 211 insertions(+), 26 deletions(-)
