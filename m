From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Sat, 3 Feb 2007 10:03:01 -0500
Message-ID: <20070203150301.GA32659@hmsreliant.homelinux.net>
References: <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net> <45C3B22B.4020400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2076 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946474AbXBCPIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Feb 2007 10:08:16 -0500
Content-Disposition: inline
In-Reply-To: <45C3B22B.4020400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 02, 2007 at 04:50:35PM -0500, Vlad Yasevich wrote:
> Neil Horman wrote:
> > Ok, I'm still testing it, but heres a new patch for review.  Significant changes
> > include the addition of a CONFIG_IPV6_OPTIMISTIC_DAD option that is dependent on
> > the inclusion of both IPPV6 and EXPERIMENTAL options, as well as a new method
> > for redirecting packets from optimistic sources to incomplete neighbors by
> > instead looking up a default router in ip6_dst_lookup_tail, as I described in my
> > previous note.
> > 
> 
> Hi Neil
> 
> Still digesting the routing changes, but I think you missed addrconf_prefix_rcv()... ;)
> 
I may well have, I'll take a good look on monday.  Thanks for the eyes :)
Neil

> 
> -vlad
