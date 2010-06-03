From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 23:50:07 -0400
Message-ID: <20100602235007.02506d99.billfink@mindspring.com>
References: <1275496439.2725.203.camel@edumazet-laptop>
	<alpine.DEB.2.00.1006021140320.30182@router.home>
	<20100602.101258.134121018.davem@davemloft.net>
	<20100602.103102.121237521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:50243 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750777Ab0FCEY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 00:24:28 -0400
In-Reply-To: <20100602.103102.121237521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Jun 2010, David Miller wrote:

> Just in case people are really so clueless as to be unable to figure
> this out:
> 
> echo 1 >/sys/kernel/debug/tracing/events/skb/kfree_skb/enable
> ...do some stuff...
> cat /sys/kernel/debug/tracing/trace
> 
> You can even trace it using 'perf' by passing "skb:kfree_skb"
> as the event specifier.

Could someone remind me where to get documentation for obtaining
and using perf.

						-Thanks

						-Bill
