From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Wed, 08 Feb 2012 18:09:17 -0500 (EST)
Message-ID: <20120208.180917.586628615268005115.davem@davemloft.net>
References: <CAJZOPZL_zEbNwUfVOmQeODny7HDf24gOc1HStfBxim_UtD-kvA@mail.gmail.com>
	<20120208.163159.2229331610142060560.davem@davemloft.net>
	<CAJZOPZLLteDbm0prTN3-npubtFun=kO2DYT7ea=E-HyJ84gaiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZLLteDbm0prTN3-npubtFun=kO2DYT7ea=E-HyJ84gaiA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 8 Feb 2012 23:49:43 +0200

> On Wed, Feb 8, 2012 at 11:31 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
>>> Hi Dave, for correct operation / future bisection, you should 1st
>>> apply Roland's patch which reduces the hard header len advertized by
>>> ipoib to be only the size of the ipoib header without that 20 bytes
>>> headroom, else the gro memcmp will be issued on the ipoib header and
>>> then 20 bytes of the ip header, kind of back to square one...
> 
>> I did.
> 
> Yep, I missed your earlier response to Roland's patch. So a question
> here, how would you recommend to get that out... since the fix for the
> problem includes two patches to core networking and one patch to
> ipoib, we can't just ship a patch to ipoib which people can apply
> build against their kernels. You've placed this work in net-next and
> not net, so I assume we should wait for 3.4-rc1 and then push to
> -stable? any other method to use here that you can recommend? thanks,

I don't think this is an appropriate bug fix at all.

Apparently this problem has existed since day one and the world has
kept on spinning meanwhile.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
