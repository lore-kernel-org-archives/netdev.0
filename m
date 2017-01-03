From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rdma-leon tree with the net-next
 tree
Date: Tue, 3 Jan 2017 12:27:20 +1100
Message-ID: <20170103122720.26c1b461@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leon,

Today's linux-next merge of the rdma-leon tree got conflicts in:

  drivers/infiniband/hw/mlx5/main.c
  drivers/infiniband/hw/mlx5/mlx5_ib.h
  drivers/infiniband/hw/mlx5/mr.c
  drivers/infiniband/hw/mlx5/qp.c
  drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
  drivers/net/ethernet/mellanox/mlx5/core/en_main.c
  drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
  drivers/net/ethernet/mellanox/mlx5/core/eq.c
  drivers/net/ethernet/mellanox/mlx5/core/main.c
  include/linux/mlx5/device.h
  include/linux/mlx5/driver.h
  include/linux/mlx5/mlx5_ifc.h

between commits in the rdma-leon tree and commits (several of whitch
are the same, or similar, patches) in the net-next tree.

I just dropped the rdma-leon tree for today.  Please clean it up.

-- 
Cheers,
Stephen Rothwell
