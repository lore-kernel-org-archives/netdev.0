From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] [net, 4.12] mlx5e: add CONFIG_INET dependency
Date: Tue, 16 May 2017 15:48:20 -0400 (EDT)
Message-ID: <20170516.154820.1799235741418300305.davem@davemloft.net>
References: <20170516112807.4107417-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170516112807.4107417-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Tue, 16 May 2017 13:27:49 +0200

> We now reference the arp_tbl, which requires IPv4 support to be
> enabled in the kernel, otherwise we get a link error:
> 
> drivers/net/built-in.o: In function `mlx5e_tc_update_neigh_used_value':
> (.text+0x16afec): undefined reference to `arp_tbl'
> drivers/net/built-in.o: In function `mlx5e_rep_neigh_init':
> en_rep.c:(.text+0x16c16d): undefined reference to `arp_tbl'
> drivers/net/built-in.o: In function `mlx5e_rep_netevent_event':
> en_rep.c:(.text+0x16cbb5): undefined reference to `arp_tbl'
> 
> This adds a Kconfig dependency for it.
> 
> Fixes: 232c001398ae ("net/mlx5e: Add support to neighbour update flow")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
