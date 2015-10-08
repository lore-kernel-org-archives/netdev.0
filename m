From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/7] Mellanox driver update for net-next
Date: Thu,  8 Oct 2015 17:13:56 +0300
Message-ID: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45223 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755540AbbJHOO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Some small fixes and small enhancements from the team.

Series applies over net-next commit acb4a6b "tcp: ensure prior synack rtx behavior
with small backlogs".

Or.

Eli Cohen (4):
  net/mlx5_core: Improve mlx5 messages
  net/mlx5_core: Prepare cmd interface to system errors handling
  net/mlx5_core: Use accessor functions to read from device memory
  net/mlx5_core: Use private health thread for each device

Ido Shamay (1):
  net/mlx4_en: Add steering rules after RSS creation

Jack Morgenstein (1):
  net/mlx4_core: Fix mailbox leak in error flow when performing update qp

Saeed Mahameed (1):
  net/mlx4_core: Fix resource tracker error flow in add_res_range

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 144 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   6 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  20 ++-
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  98 +++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  37 +++---
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  22 ++--
 include/linux/mlx5/driver.h                        |  13 +-
 8 files changed, 194 insertions(+), 150 deletions(-)

-- 
2.3.7
