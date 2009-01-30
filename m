From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [0/4] GRO optimisations
Date: Thu, 29 Jan 2009 16:28:57 -0800
Message-ID: <498249C9.3050708@chelsio.com>
References: <20090130001849.GA1272@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:30343 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201AbZA3AeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:34:19 -0500
In-Reply-To: <20090130001849.GA1272@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Hi Dave:
>
> This is a dump of my current patches to optimise GRO in order
> to get cxgb3 performance back up to the LRO level.  I've got
> some more ideas but I'd like to get this out first so it doesn't
> rot in my tree.
>
> Oh and of course a direct LRO comparison isn't exactly fair because
> LRO skipped some tests such as checking the IP header checksum
> (naughty :) so the current 5.7 vs. 6.1 figure isn't all that bad.
>
> But I think we should be able to get back to 6Gb/s with cxgb3
>   

Hi Herbert,

I'll give these patches a try within a day or two.
Please note that the 6Gb/s rate is achieved on a low perf server.
Using this server makes it easy to witness the impact of optimizations.
Faster boxes reach line rate.
Just want to make clear that cxgb3 HW is not limited to 6Gb/s ;)

Cheers,
Divy
