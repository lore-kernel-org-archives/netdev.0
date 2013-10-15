From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/4] net/mlx4: Mellanox driver update 15-10-2013
Date: Tue, 15 Oct 2013 16:55:20 +0200
Message-ID: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52133 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932203Ab3JOOz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:55:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains small code cleaning patches, and a patch to make
mlx4_core use module_request() in order to load the relevant link layer module
(mlx4_en or mlx4_ib) according to the port type.

Thanks,
Amir

Amir Vadai (1):
  net/mlx4: Unused local variable in mlx4_opreq_action

Eyal Perry (1):
  net/mlx4_core: Load higher level modules according to ports type

Or Gerlitz (2):
  net/mlx4: Clean the code to eliminate trivial build warnings
  net/mlx4: Fix typo, move similar defs to same location

 drivers/net/ethernet/mellanox/mlx4/cmd.c       |  2 --
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |  4 +---
 drivers/net/ethernet/mellanox/mlx4/main.c      | 29 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mcg.c       |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/srq.c       |  1 +
 include/linux/mlx4/cmd.h                       |  6 ++----
 include/linux/mlx4/device.h                    |  2 +-
 8 files changed, 38 insertions(+), 14 deletions(-)

-- 
1.8.3.4
