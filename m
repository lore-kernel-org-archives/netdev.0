From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 01:00:56 -0700 (PDT)
Message-ID: <20100929.010056.115931816.davem@davemloft.net>
References: <20100929.002544.183044247.davem@davemloft.net>
	<1285746352.2615.11.camel@edumazet-laptop>
	<20100929075758.GA5188@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752160Ab0I2IAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 04:00:36 -0400
In-Reply-To: <20100929075758.GA5188@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Sep 2010 16:57:58 +0900

> On Wed, Sep 29, 2010 at 09:45:52AM +0200, Eric Dumazet wrote:
> .
>> > > install ipv6 /bin/true
>> > > 
>> > > or
>> > > 
>> > > options ipv6 disable=1
>> > 
>> > If you set the disable option, it should do the right thing.  Since
>> > the ipv6 symbols will be available, yet the ipv6 stack won't by
>> > default bring up ipv6 addresses onto interfaces etc.
>> 
>> I must miss something obvious.
>> 
>> David, with your patch, I cant :
>> 
>> install ipv6 /bin/true
>> modprobe ip_gre
> 
> Does it work if you use
> 
> 	options ipv6 disable=1
> 
> If so then that's what should be used in this case.

That's what one should use "always" :-)

Bonding has the same issue, and it's why we added the
disable module option, so that the /bin/true stupidity
could stop.
