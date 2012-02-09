From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Thu, 9 Feb 2012 12:46:20 +0200
Message-ID: <4F33A3FC.1050205@mellanox.com>
References: <CAJZOPZLLteDbm0prTN3-npubtFun=kO2DYT7ea=E-HyJ84gaiA@mail.gmail.com> <20120208.180917.586628615268005115.davem@davemloft.net> <CAJZOPZ+SyGsDpnK89wNWtBn4Jdzc2tg1diKjbHSv=n75XiG+ug@mail.gmail.com> <20120208.182629.1816927738607872730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120208.182629.1816927738607872730.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/9/2012 1:26 AM, David Miller wrote:
> the bug was introduced on 2.6.38 when LRO was removed from IPoIB
> and GRO added, so users who run distributions containing pre 2.6.38
> kernels don't hit the bug.
>
> This I didn't know, Ok I'll apply this stuff to the net tree and add it
> to my -stable queue as well.

Dave,

Thanks, going net and -stable will help here. I'm still cloning net, but 
from git web looking it seems that you've applied Roland's and Eric's 
patches on net but not yours... e.g net-next commit 
a0417fa3a18a14be1f4d9cffcf378a7c42d92a91 
"net: Make qdisc_skb_cb upper size bound explicit" is missing from net, 
and it has to be applied before Roland's.

Or.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
