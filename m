From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
	originated TCP streams
Date: Wed, 1 Feb 2012 19:38:37 +1100
Message-ID: <20120201083837.GA7081@gondor.apana.org.au>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com> <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com> <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com> <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop> <20120130081849.GA7848@gondor.apana.org.au> <1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120130085742.GA8262@gondor.apana.org.au> <CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2012 at 10:23:22AM +0200, Or Gerlitz wrote:
>
> So what would you recommend here? not sure if you saw that, but Shlomo
> suggested to add new entry to the header ops, compare_header e.g such
> that if skb->dev has this callback use it instead of
> compare_ether_header in __napi_gro_receive, makes sense?

If we just turn it into a memcmp with a variable length would
that work for you?

Cheers,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
