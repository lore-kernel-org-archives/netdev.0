From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] net/mlx5e: use %pad format string for
 dma_addr_t
Date: Fri, 9 Dec 2016 01:16:22 +0200
Message-ID: <5a451128-7d3a-1204-c2e2-2a928b8638e9@mellanox.com>
References: <20161208215727.44841-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Daniel Jurgens <danielj-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "Leon Romanovsky" <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161208215727.44841-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 12/08/2016 11:57 PM, Arnd Bergmann wrote:
> On 32-bit ARM with 64-bit dma_addr_t I get this warning about an
> incorrect format string:
> 
> In file included from /git/arm-soc/drivers/net/ethernet/mellanox/mlx5/core/alloc.c:42:0:
> drivers/net/ethernet/mellanox/mlx5/core/alloc.c: In function ‘mlx5_frag_buf_alloc_node’:
> drivers/net/ethernet/mellanox/mlx5/core/alloc.c:134:12: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
> 
> We have the special %pad format for printing dma_addr_t, so use that
> to print the correct address and avoid the warning.
> 
> Fixes: 1c1b522808a1 ("net/mlx5e: Implement Fragmented Work Queue (WQ)")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Thank you Arnd !!

Acked-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
