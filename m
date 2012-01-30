From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Mon, 30 Jan 2012 11:43:33 -0500 (EST)
Message-ID: <20120130.114333.298582192453706008.davem@davemloft.net>
References: <20120130081849.GA7848@gondor.apana.org.au>
	<1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120130085742.GA8262@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120130085742.GA8262-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org>
Date: Mon, 30 Jan 2012 19:57:42 +1100

> On Mon, Jan 30, 2012 at 09:53:03AM +0100, Eric Dumazet wrote:
>>
>> If this is an attack, TCP will merge the frames anyway on the same
>> socket.
> 
> Not if we have a MAC-level filter in place or VLANs.

Right.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
