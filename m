From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Mon, 2 Jun 2003 12:46:55 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <OF5056D19C.756A70DE-ON88256D39.006A1D3D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@redhat.com
List-Id: netdev.vger.kernel.org





Regarding my previous mail :

> > Again, what I proposed was to store prefix information on fib with
> > some flags to represent advertised by routers and give user-space
> > the RA information using new rtattr (RTA_RA6INFO or something like
that).
> >
> > struct rta_ra6info {
> >      u32 rta_ra6flags;
> > };

> In my mail, I had given problems with doing that in the fib. I can look
to
> convert to fib, but please let me know which kernel routines I should
look at

What I meant is whether you are referring to addrconf_prefix_route() when
you
mention storing prefix on fib ?

> > Again, what I proposed was to store prefix information on fib with
> > some flags to represent advertised by routers and give user-space
> > the RA information using new rtattr (RTA_RA6INFO or something like
that).
>
> This sounds very reasonable.

Also since you prefer it to be implemented as part of routing table, would
it
be OK to return the prefix list via netstat or route command (this uses
rt6_info_route() to print the information). The current user for prefix
list
has no problem using a command instead of writing netlink user code to get
the list. I am not sure why rtnetlink is needed in this case.

thanks,

- KK

