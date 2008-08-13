From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO restructuring?
Date: Wed, 13 Aug 2008 12:14:15 +1000
Message-ID: <E1KT5sN-0007uF-00@gondolin.me.apana.org.au>
References: <48A17922.4050103@myri.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, brice@myri.com
To: gallatin@myri.com (Andrew Gallatin)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36736 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751858AbYHMCOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 22:14:18 -0400
In-Reply-To: <48A17922.4050103@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Gallatin <gallatin@myri.com> wrote:
>
> Indeed.  Nor should they change lengths, or anything else.
> Everything about this "inexact" forwarding is illegal as
> hell.  However, you have to admit that it is an interesting hack :)

Solutions like this have been deployed.  For instance, many satellite
networks use transparent TCP proxies to mitigate the effect of large
latencies on older TCP stacks that don't have modern congestion
control algorithms.

Surprisingly there are actually very few problems.  The biggest
one (apart from scalability) is with non-TCP traffic masquerading
as TCP such as Cisco's VPN solution.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
