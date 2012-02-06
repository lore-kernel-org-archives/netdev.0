From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 14:12:23 -0500 (EST)
Message-ID: <20120206.141223.332863167187002998.davem@davemloft.net>
References: <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120206.115859.1384761795375582044.davem@davemloft.net>
	<CAG4TOxOBCbEEOtP62ZM1R3-6umebdbJFkK0bnjphLCZOgHzt1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAG4TOxOBCbEEOtP62ZM1R3-6umebdbJFkK0bnjphLCZOgHzt1g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Mon, 6 Feb 2012 09:23:58 -0800

> IMHO the problem is in the IPoIB RFC: (4391) which makes
> a distinction between an "encapsulation header" and the "link
> layer address".  The LL address is what we put into ARP and
> ND packets, and so I think we are forced into exposing that
> to the network stack as our hardware address.

An address is not a hardware MAC header, we're only talking
about the length of the latter.

If the addressing is such that you need to put the GID
into the ARP/NDISC packets, and that's different from what
ends up in the final encapsulation header, I really don't
see what the problem is specificially with respect to the
MAC header size.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
