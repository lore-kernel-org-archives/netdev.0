From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Wed, 08 Feb 2012 15:50:27 -0500 (EST)
Message-ID: <20120208.155027.599792363539233740.davem@davemloft.net>
References: <20120206.113145.1284864994961472499.davem@davemloft.net>
	<1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328727110.2631.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328727110.2631.8.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 08 Feb 2012 19:51:50 +0100

> Shlomo Pongratz reported GRO L2 header check was suited for Ethernet
> only, and failed on IB/ipoib traffic.
> 
> He provided a patch faking a zeroed header to let GRO aggregates frames.
> 
> Roland Dreier, Herbert Xu, and others suggested we change GRO L2 header
> check to be more generic, ie not assuming L2 header is 14 bytes, but
> taking into account hard_header_len.
> 
> __napi_gro_receive() has special handling for the common case (Ethernet)
> to avoid a memcmp() call and use an inline optimized function instead.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reported-by: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> Tested-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
