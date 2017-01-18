From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Thu, 19 Jan 2017 09:56:00 +1100
Message-ID: <20170119095600.6d7a84d7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
produced this warning:

drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: In function 'mlx5e_set_channels':
drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:546:6: warning: unused variable 'ncv' [-Wunused-variable]
  int ncv = mlx5e_get_max_num_channels(priv->mdev);
      ^

Introduced by commit

  639e9e94160e ("net/mlx5e: Remove unnecessary checks when setting num channels")

which removed the last reference to 'ncv'.

-- 
Cheers,
Stephen Rothwell
