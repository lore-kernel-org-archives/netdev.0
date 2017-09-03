From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next] net/mlx4_core: fix memory leaks on error exit
 path
Date: Sun, 03 Sep 2017 10:57:32 -0700 (PDT)
Message-ID: <20170903.105732.1712307481321249919.davem@davemloft.net>
References: <20170831163053.2349-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tariqt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831163053.2349-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 31 Aug 2017 17:30:53 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The structures hca_param and func_cap are not being kfree'd on an error
> exit path causing two memory leaks. Fix this by jumping to the existing
> free memory error exit path.
> 
> Detected by CoverityScan, CID#1455219, CID#1455224 ("Resource Leak")
> 
> Fixes: c73c8b1e47ca ("net/mlx4_core: Dynamically allocate structs at mlx4_slave_cap")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
