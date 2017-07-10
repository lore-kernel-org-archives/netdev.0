From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/mlx5: IPSec, fix 64-bit division correctly
Date: Mon, 10 Jul 2017 19:34:39 +0100 (WEST)
Message-ID: <20170710.193439.1383814646174599742.davem@davemloft.net>
References: <20170710093842.2921914-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, yossiku-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, kliteyn-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170710093842.2921914-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Mon, 10 Jul 2017 11:37:51 +0200

> The new IPSec offload code introduced a build error:
> 
> drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.o: In function `mlx5e_ipsec_build_inverse_table':
> ipsec_rxtx.c:(.text+0x556): undefined reference
> 
> Another patch was added on top to fix the build error, but
> that introduced a new bug, as we now use the remainder of
> the division rather than the result.
> 
> This makes it use the correct helper function instead.
> 
> Fixes: 5dfd87b67cd9 ("net/mlx5: IPSec, Fix 64-bit division on 32-bit builds")
> Fixes: 2ac9cfe78223 ("net/mlx5e: IPSec, Add Innova IPSec offload TX data path")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
