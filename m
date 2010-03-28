From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sun, 28 Mar 2010 06:40:12 -0700 (PDT)
Message-ID: <20100328.064012.193708716.davem@davemloft.net>
References: <20100328082250.GA14053@gondor.apana.org.au>
	<20100328.055312.58421329.davem@davemloft.net>
	<20100328131112.GA15984@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754450Ab0C1Njt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 09:39:49 -0400
In-Reply-To: <20100328131112.GA15984@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 28 Mar 2010 21:11:12 +0800

> On Sun, Mar 28, 2010 at 05:53:12AM -0700, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Sun, 28 Mar 2010 16:22:50 +0800
>>
>> > My main question is how do we deal with source-address policy
>> > routing in a host cache?
>> 
>> We don't, the same like how we don't handle fully specified
>> IPSEC policies deciding upon the route.
> 
> I thought we did handle source-address policy routing for PMTU
> messages at least.  I just checked ip_rt_frag_needed and it does

Same for all the other metrics at the TCP level.

I guess this is the decision we have to make, what does
"host level" metrics mean for us if we decide to move
things into the inetpeer cache.

