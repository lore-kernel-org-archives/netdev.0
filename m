From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] infiniband: mlx5: avoid a compile-time warning
Date: Tue, 13 Jan 2015 17:08:41 -0500 (EST)
Message-ID: <20150113.170841.1549791027972784427.davem@davemloft.net>
References: <2267004.49D0qFBpL1@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2267004.49D0qFBpL1@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Tue, 13 Jan 2015 17:09:43 +0100

> The return type of find_first_bit() is architecture specific,
> on ARM it is 'unsigned int', while the asm-generic code used
> on x86 and a lot of other architectures returns 'unsigned long'.
> 
> When building the mlx5 driver on ARM, we get a warning about
> this:
> 
> infiniband/hw/mlx5/mem.c: In function 'mlx5_ib_cont_pages':
> infiniband/hw/mlx5/mem.c:84:143: warning: comparison of distinct pointer types lacks a cast
>      m = min(m, find_first_bit(&tmp, sizeof(tmp)));
> 
> This patch changes the driver to use min_t to make it behave
> the same way on all architectures.
> 
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
