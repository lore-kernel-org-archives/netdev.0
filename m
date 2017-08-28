From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/4] mlx4 misc patches
Date: Mon, 28 Aug 2017 16:38:19 +0300
Message-ID: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38576 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751152AbdH1NjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 09:39:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains misc patches from the team
to the mlx4 Core and Eth drivers.

Patch 1 by Eran replaces large static allocations by dynamic ones.
Patch 2 by Leon makes an explicit conversion and solves a smatch warning.
In patch 3 I fix a misplaced brackets of the sizeof operation.
Patch 4 by Moshe adds the ability to inform the FW regarding user mac updates.

Series generated against net-next commit:
901c5d2fbfcd ARM: dts: rk3228-evb: Fix the compiling error

Thanks,
Tariq.


Eran Ben Elisha (1):
  net/mlx4_core: Dynamically allocate structs at mlx4_slave_cap

Leon Romanovsky (1):
  net/mlx4_core: Make explicit conversion to 64bit value

Moshe Shemesh (1):
  net/mlx4: Add user mac FW update support

Tariq Toukan (1):
  net/mlx4_core: Fix misplaced brackets of sizeof

 drivers/infiniband/hw/mlx4/qp.c                |  26 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  23 ++-
 drivers/net/ethernet/mellanox/mlx4/eq.c        |   2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |  19 +-
 drivers/net/ethernet/mellanox/mlx4/fw.h        |   6 +-
 drivers/net/ethernet/mellanox/mlx4/main.c      | 238 +++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |   2 +
 drivers/net/ethernet/mellanox/mlx4/port.c      |  25 +++
 drivers/net/ethernet/mellanox/mlx4/qp.c        |  24 +--
 include/linux/mlx4/device.h                    |  16 +-
 10 files changed, 219 insertions(+), 162 deletions(-)

-- 
1.8.3.1
