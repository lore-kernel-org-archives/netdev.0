From: Brent Cook <bcook@bpointsys.com>
Subject: Re: neighbor vs neighbour
Date: Thu, 25 Jun 2009 15:22:07 -0500
Message-ID: <200906251522.08095.bcook@bpointsys.com>
References: <200906251431.34677.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 65-36-7-9.static.grandenetworks.net ([65.36.7.9]:37910 "EHLO
	bpointsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753508AbZFYUWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 16:22:54 -0400
In-Reply-To: <200906251431.34677.bcook@bpointsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 25 June 2009 02:31:34 pm Brent Cook wrote:
> I was looking at netstat -6 -s to debug a routing issue, and noticed that
> the output is a little confusing. What's the difference between 'neighbor
> solicits' and 'neighbour solicits'. And yes, I've already hear the
> 'Atlantic Ocean' joke :) Is one TX vs RX?

Just checked the source - neighbour is In, neighbor is Out. Looks like a net-
tools issue, I'll take it off-list.

> <snip>
> Icmp6:
>     3206 ICMP messages received
>     0 input ICMP message failed.
>     2593 ICMP messages sent
>     ICMP input histogram:
>         destination unreachable: 39
>         echo requests: 63
>         group member reductions: 6
>         router solicits: 190
>         router advertisement: 2669
>         neighbour solicits: 10
>         neighbour advertisement: 229
>         ICMP output histogram:
>         destination unreachable: 115
>         echo replies: 63
>         Icmp6OutRouterAdvertisements: 1895
>         neighbor solicits: 354
>         neighbor advertisements: 6
> </snip>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

