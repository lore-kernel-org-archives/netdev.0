From: Andrew Grover <andy.grover-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [rds-devel] net-next pull request: RDS
Date: Tue, 14 Sep 2010 15:28:00 -0700
Message-ID: <AANLkTin69m0kK6bqUiwYeHRQT0Ehso16xA6RBtBFFgW3@mail.gmail.com>
References: <4C892C9C.4060304@oracle.com>
	<4C8C9422.2070306@Voltaire.com>
	<20100914183514.GA3417@takashi.pdx.zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>,
	Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	RDS Devel <rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
To: Zach Brown <zach.brown-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100914183514.GA3417-Mg0Rv1oTIzK+NQz5YmTpAAHTzkgPINtM@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2010 at 11:35 AM, Zach Brown <zach.brown-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
>> Zach Brown's "RDS/IB: print IB event strings as well as their number" - commit
>> 1bde04a63d532c2540d6fdee0a661530a62b1686 in net-next-2.6 looks perfect to
>> reside as a helper function in the core IB stack which can be in use by other
>> rdma drivers (e.g ipoib, iser, srp, etc).
>
> Yeah, if those other drivers were interested in the little helpers then it
> would make sense to bring the functionality up into the core stack.
>
> Note that there's another later commit in net-next that gives other event
> strings the same treatment: 59f740a6aeb2cde2f79fe0df38262d4c1ef35cd8 .

Since rds goes upstream via netdev not linux-rdma, it's a little
tricky.. any core ib helpers we added would not be in net-next so rds
wouldn't build. :) Once net-next gets pushed to mainline and Roland
pulls from that, then we'll be in a good position to put these helpers
where they should go, and change other ULPs to use them.

-- Andy
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
