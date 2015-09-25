From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/8] Mellanox mlx5 driver update
Date: Fri, 25 Sep 2015 10:49:08 +0300
Message-ID: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39353 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755369AbbIYHuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:50:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Bunch of changes from the team, while warming engines for the 
upcoming SRIOV support.

Or.


Achiad Shochat (2):
  net/mlx5e: Priv state flag not rolled-back upon netdev open error
  net/mlx5_core: Remove redundant "err" variable usage

Eli Cohen (4):
  net/mlx5_core: Fix async commands return code
  net/mlx5_core: Fix notification of page supplement error
  net/mlx5_core: Fix wrong name in struct
  net/mlx5_core: Update health syndromes

Majd Dibbiny (1):
  net/mlx5_core: New init and exit flow for mlx5_core

Saeed Mahameed (1):
  net/mlx5_core: Fix struct type in the DESTROY_TIR/TIS device commands

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  11 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 341 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/mr.c       |   1 +
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  63 ++--
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  35 +--
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |   4 +-
 include/linux/mlx5/device.h                        |   2 +-
 13 files changed, 262 insertions(+), 209 deletions(-)

-- 
2.3.7
