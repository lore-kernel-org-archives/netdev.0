From: Zach Brown <zach.brown-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [rds-devel] net-next pull request: RDS
Date: Tue, 14 Sep 2010 11:35:14 -0700
Message-ID: <20100914183514.GA3417@takashi.pdx.zabbo.net>
References: <4C892C9C.4060304@oracle.com>
 <4C8C9422.2070306@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, RDS Devel <rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
To: Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C8C9422.2070306-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Zach Brown's "RDS/IB: print IB event strings as well as their number" - commit
> 1bde04a63d532c2540d6fdee0a661530a62b1686 in net-next-2.6 looks perfect to
> reside as a helper function in the core IB stack which can be in use by other
> rdma drivers (e.g ipoib, iser, srp, etc). 

Yeah, if those other drivers were interested in the little helpers then it
would make sense to bring the functionality up into the core stack.

Note that there's another later commit in net-next that gives other event
strings the same treatment: 59f740a6aeb2cde2f79fe0df38262d4c1ef35cd8 .

- z
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
