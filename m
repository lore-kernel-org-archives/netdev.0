From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Thu, 9 Feb 2012 01:20:46 +0200
Message-ID: <CAJZOPZ+SyGsDpnK89wNWtBn4Jdzc2tg1diKjbHSv=n75XiG+ug@mail.gmail.com>
References: <CAJZOPZL_zEbNwUfVOmQeODny7HDf24gOc1HStfBxim_UtD-kvA@mail.gmail.com>
	<20120208.163159.2229331610142060560.davem@davemloft.net>
	<CAJZOPZLLteDbm0prTN3-npubtFun=kO2DYT7ea=E-HyJ84gaiA@mail.gmail.com>
	<20120208.180917.586628615268005115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120208.180917.586628615268005115.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2012 at 1:09 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> I don't think this is an appropriate bug fix at all.

I'm not sure to understand

> Apparently this problem has existed since day one and the world has
> kept on spinning meanwhile.

Dave, the bug was introduced on 2.6.38 when LRO was removed from IPoIB
and GRO added, so users who run distributions containing pre 2.6.38
kernels don't hit the bug.

So with the world keep spinning, GRO becomes critical when throwing
ipoib into the virtualization space, as except for LRO being
deprecated, its not supported by the virtualization stack (e.g the
bridge), and here GRO should come into play, and will, after the
fix... BTW - ipoib surely can't be plugged to bridge/macvtap as is,
but this is different story to cope with, now one less obstacle, GRO
works!

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
