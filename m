From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Thu, 9 Feb 2012 22:04:34 +0200
Message-ID: <CAJZOPZJj=rBoss-JiLm6K66D1h+zyerDspDS+358t7u=Mg2pfQ@mail.gmail.com>
References: <CAJZOPZ+SyGsDpnK89wNWtBn4Jdzc2tg1diKjbHSv=n75XiG+ug@mail.gmail.com>
	<20120208.182629.1816927738607872730.davem@davemloft.net>
	<4F33A3FC.1050205@mellanox.com>
	<20120209.135235.957414875716615693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120209.135235.957414875716615693.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2012 at 8:52 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> I've fix this now, thanks.

Yep, I see it there, still, for correctness/biscetion, you should
rebase such that the order of commits when pushed to Linus is

3. 5ca3b72c5da47d95b83857b768def6172fbc080a "gro: more generic L2 header check"

2. 936d7de3d736e0737542641269436f4b5968e9ef "IPoIB: Stop lying about
hard_header_len and use skb->cb to stash LL addresses"

1. 16bda13d90c8d5da243e2cfa1677e62ecce26860 "net: Make qdisc_skb_cb
upper size bound explicit" comes before "

currently its 2,3,1

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
