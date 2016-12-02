From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx5e: skip loopback selftest with
 !CONFIG_INET
Date: Fri, 02 Dec 2016 11:56:19 -0500 (EST)
Message-ID: <20161202.115619.1098706795726222374.davem@davemloft.net>
References: <20161130210552.1756085-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        kamalh@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130210552.1756085-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 30 Nov 2016 22:05:39 +0100

> When CONFIG_INET is disabled, the new selftest results in a link
> error:
> 
> drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.o: In function `mlx5e_test_loopback':
> en_selftest.c:(.text.mlx5e_test_loopback+0x2ec): undefined reference to `ip_send_check'
> en_selftest.c:(.text.mlx5e_test_loopback+0x34c): undefined reference to `udp4_hwcsum'
> 
> This hides the specific test in that configuration.
> 
> Fixes: 0952da791c97 ("net/mlx5e: Add support for loopback selftest")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
