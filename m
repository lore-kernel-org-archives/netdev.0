From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/3] mlx4 drivers: version update
Date: Wed,  7 Jun 2017 16:26:12 +0300
Message-ID: <1496841975-7728-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54976 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751647AbdFGN1F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 09:27:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains version updates for the MLX4 drivers:
Core, EN, and IB.

Just like we've done in mlx5, we modify the outdated driver
version (reported in ethtool for example).
This better reflects the current driver state, and removes the
redundant date string.
We are not going to change this frequently or even use it.

I include the IB patch in this series as it has similar subject
and content.
It does not cause any kind of conflict with Doug's tree.
The rdma mailing list is CCed.
Please let me know if I need to submit this differently.

Series generated against net-next commit:
216fe8f021e3 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

Thanks,
Tariq.

Tariq Toukan (3):
  net/mlx4_core: Bump driver version
  net/mlx4_en: Bump driver version
  IB/mlx4: Bump driver version

 drivers/infiniband/hw/mlx4/main.c               | 5 ++---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c    | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/main.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h       | 3 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 3 +--
 6 files changed, 8 insertions(+), 11 deletions(-)

-- 
1.8.3.1
