From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sun, 28 Mar 2010 05:53:12 -0700 (PDT)
Message-ID: <20100328.055312.58421329.davem@davemloft.net>
References: <20100327.203120.98894145.davem@davemloft.net>
	<20100328082250.GA14053@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754555Ab0C1Mwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 08:52:49 -0400
In-Reply-To: <20100328082250.GA14053@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 28 Mar 2010 16:22:50 +0800

> On Sat, Mar 27, 2010 at 08:31:20PM -0700, David Miller wrote:
>>
>> Finally, we can really move the metrics array into the inetpeer
>> entries.
> 
> My main question is how do we deal with source-address policy
> routing in a host cache?

We don't, the same like how we don't handle fully specified
IPSEC policies deciding upon the route.
