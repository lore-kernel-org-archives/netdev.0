From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH net-2.6.25] qdisc: new rate limiter
Date: Sat, 8 Dec 2007 03:11:39 -0500
Message-ID: <20071208031139.0b6a58bb.billfink@mindspring.com>
References: <20071207162618.35715892@freepuppy.rosehill>
	<475A0804.1060006@trash.net>
	<475A0959.20701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:34469 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755373AbXLHILu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:11:50 -0500
In-Reply-To: <475A0959.20701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 08 Dec 2007, Patrick McHardy wrote:

> Patrick McHardy wrote:
> > Stephen Hemminger wrote:
> >>
> >> +struct tc_rlim_qopt
> >> +{
> >> +    __u32   limit;        /* fifo limit (packets) */
> >> +    __u32    rate;        /* bits per sec */
> >>   
> >
> > This seems a bit small, 512mbit is the maximum rate.
> 
> Its 4gbit of course, so I guess its enough :)

Actually, since we already have 10-Gbps nets, with 40-Gbps and
100-Gbps nets upcoming, it maybe should be __u64.

						-Bill
