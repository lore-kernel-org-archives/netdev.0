From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH][-next] net/mlx5: fix spelling mistake: "Allodating" ->
 "Allocating"
Date: Sat, 01 Jul 2017 14:40:03 -0700 (PDT)
Message-ID: <20170701.144003.1643313481741710568.davem@davemloft.net>
References: <20170630105922.10397-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170630105922.10397-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Fri, 30 Jun 2017 11:59:22 +0100

> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> Trivial fix to spelling mistake in mlx5_core_dbg debug message
> 
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Applied, thanks Colin.

Mellanox folks, I don't like how these lib/ objects are built.

I absolutely depend upon being able to try and build individual
object files, by name, in order to quickly smoke-test patches.
Like this:

[davem@kkuri net-next]$ make drivers/net/ethernet/mellanox/mlx5/core/lib/gid.o

But I can't for these files:

scripts/Makefile.build:44: drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile: No such file or directory
make[1]: *** No rule to make target 'drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile'.  Stop.
Makefile:1663: recipe for target 'drivers/net/ethernet/mellanox/mlx5/core/lib/gid.o' failed

Please fix this so that I can build all object files by name in this driver
again.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
