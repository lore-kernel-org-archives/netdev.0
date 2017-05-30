From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx5: avoid build warning for uniprocessor
Date: Tue, 30 May 2017 14:09:38 -0400 (EDT)
Message-ID: <20170530.140938.195927218396234401.davem@davemloft.net>
References: <20170529130030.244337-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        mohamad@mellanox.com, danielj@mellanox.com, eli@mellanox.com,
        avivh@mellanox.com, huyn@mellanox.com, artemyko@mellanox.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170529130030.244337-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 29 May 2017 15:00:17 +0200

> Building the driver with CONFIG_SMP disabled results in a harmless
> warning:
> 
> ethernet/mellanox/mlx5/core/main.c: In function 'mlx5_irq_set_affinity_hint':
> ethernet/mellanox/mlx5/core/main.c:615:6: error: unused variable 'irq' [-Werror=unused-variable]
> 
> It's better to express the conditional compilation using IS_ENABLED()
> here, as that lets the compiler see what the intented use for the variable
> is, and that it can be silently discarded.
> 
> Fixes: b665d98edc9a ("net/mlx5: Tolerate irq_set_affinity_hint() failures")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
