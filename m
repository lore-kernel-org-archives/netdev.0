From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
	originated TCP streams
Date: Mon, 30 Jan 2012 19:18:49 +1100
Message-ID: <20120130081849.GA7848@gondor.apana.org.au>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com> <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com> <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com> <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1327910672.2891.12.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 09:04:32AM +0100, Eric Dumazet wrote:
>
> Hmm, do we really need to compare ether header, thats the question.

I think we do.  As otherwise macvlan would break.

Cheers,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
