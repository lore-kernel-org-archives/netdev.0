From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Wed, 08 Feb 2012 18:26:29 -0500 (EST)
Message-ID: <20120208.182629.1816927738607872730.davem@davemloft.net>
References: <CAJZOPZLLteDbm0prTN3-npubtFun=kO2DYT7ea=E-HyJ84gaiA@mail.gmail.com>
	<20120208.180917.586628615268005115.davem@davemloft.net>
	<CAJZOPZ+SyGsDpnK89wNWtBn4Jdzc2tg1diKjbHSv=n75XiG+ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZ+SyGsDpnK89wNWtBn4Jdzc2tg1diKjbHSv=n75XiG+ug-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 9 Feb 2012 01:20:46 +0200

> On Thu, Feb 9, 2012 at 1:09 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> I don't think this is an appropriate bug fix at all.
> 
> I'm not sure to understand
> 
>> Apparently this problem has existed since day one and the world has
>> kept on spinning meanwhile.
> 
> Dave, the bug was introduced on 2.6.38 when LRO was removed from IPoIB
> and GRO added, so users who run distributions containing pre 2.6.38
> kernels don't hit the bug.

This I didn't know, Ok I'll apply this stuff to the net tree and add it
to my -stable queue as well.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
