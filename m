From: Bill Fink <billfink@mindspring.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 23:49:17 -0400
Message-ID: <20100714234917.924f420d.billfink@mindspring.com>
References: <4C3E0684.5060409@wildgooses.com>
	<4C3E1B54.40604@hp.com>
	<20100714203919.GD6682@nuttenaction>
	<20100714.145547.102555471.davem@davemloft.net>
	<20100714221301.GI6682@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	lists@wildgooses.com, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:36383 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932260Ab0GODtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 23:49:21 -0400
In-Reply-To: <20100714221301.GI6682@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jul 2010, Hagen Paul Pfeifer wrote:

> * David Miller | 2010-07-14 14:55:47 [-0700]:
> 
> >Although section 3 of RFC 5681 is a great text, it does not say at all
> >that increasing the initial CWND would lead to fairness issues.
> 
> Because it is only one side of the medal, probing conservative the available
> link capacity in conjunction with n simultaneous probing TCP/SCTP/DCCP
> instances is another.
> 
> >To be honest, I think google's proposal holds a lot of weight.  If
> >over time link sizes and speeds are increasing (they are) then nudging
> >the initial CWND every so often is a legitimate proposal.  Were
> >someone to claim that utilization is lower than it could be because of
> >the currenttly specified initial CWND, I would have no problem
> >believing them.
> >
> >And I'm happy to make Linux use an increased value once it has
> >traction in the standardization community.
> 
> Currently I know no working link capacity probing approach, without active
> network feedback, to conservatively probing the available link capacity with a
> high CWND. I am curious about any future trends.

A long, long time ago, I suggested a Path BW Discovery mechanism
to the IETF, analogous to the Path MTU Discovery mechanism, but
it didn't get any traction.  Such information could be extremely
useful to TCP endpoints, to determine a maximum window size to
use, to effectively rate limit a much stronger sender from
overpowering a much weaker receiver (for example 10-GigE -> GigE),
resulting in abominable performance across large RTT paths
(as low as 12 Mbps), even in the absence of any real network
contention.

						-Bill
