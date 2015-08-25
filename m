From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 0/4] net/mlx5e: Driver updates 25-Aug-2015
Date: Tue, 25 Aug 2015 15:29:56 +0300
Message-ID: <1440505800-5934-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54932 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754083AbbHYMcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 08:32:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small patchset contains:

Exposure of some mlx5_core access functions for mlx5_ib to use
(Patch 1/4 - "Expose transobj APIs from mlx5 core").

Error flow fix (2/4 - "Priv state flag not rolled-back upon netdev
open error").

Small typo bug fixes (Patch 3/4 - "Fix struct type in the
DESTROY_TIR/TIS device commands").

A cosmetic cleanup removing a redundant "err" variable (Patch 4/4 -
"Remove redundant "err" variable usage").

The patchset was applied and tested over commit "net/mlx5e: Avoid
accessing NULL pointer at ndo_select_queue" that I sent lately to the
mailing list.

Thanks,
Achiad

Achiad Shochat (2):
  net/mlx5e: Priv state flag not rolled-back upon netdev open error
  net/mlx5_core: Remove redundant "err" variable usage

Saeed Mahameed (1):
  net/mlx5_core: Fix struct type in the DESTROY_TIR/TIS device commands

Yishai Hadas (1):
  net/mlx5_core: Expose transobj APIs from mlx5 core

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  8 ++-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 35 ++++-------
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 32 +++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h | 72 ----------------------
 6 files changed, 48 insertions(+), 103 deletions(-)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.h

-- 
1.8.3.1
