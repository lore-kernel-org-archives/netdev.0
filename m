From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] net/mlx5e: shut up maybe-uninitialized warning
Date: Mon, 03 Oct 2016 01:56:01 -0400 (EDT)
Message-ID: <20161003.015601.1695276307529816567.davem@davemloft.net>
References: <20160930161734.70928-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, amirva-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160930161734.70928-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Fri, 30 Sep 2016 18:17:09 +0200

> Build-testing this driver with -Wmaybe-uninitialized gives a new false-positive
> warning that I can't really explain:
> 
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'mlx5e_configure_flower':
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:509:3: error: 'old_attr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> It's obvious from the code that 'old_attr' is initialized whenever 'old'
> is non-NULL here. The warning appears with all versions I tested from gcc-4.7
> through gcc-6.1, and I could not come up with a way to rewrite the function
> in a more readable way that avoids the warning, so I'm adding another
> initialization to shut it up.
> 
> Fixes: 8b32580df1cb ("net/mlx5e: Add TC vlan action for SRIOV offloads")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
