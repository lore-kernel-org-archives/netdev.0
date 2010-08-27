From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v3] gro: __napi_gro_receive() optimizations
Date: Thu, 26 Aug 2010 22:02:15 -0700 (PDT)
Message-ID: <20100826.220215.39172437.davem@davemloft.net>
References: <1282883713.2501.29.camel@edumazet-laptop>
	<20100826.213816.112615295.davem@davemloft.net>
	<20100827044201.GA24224@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753762Ab0H0FB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 01:01:59 -0400
In-Reply-To: <20100827044201.GA24224@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Aug 2010 21:42:01 -0700

> On Thu, Aug 26, 2010 at 09:38:16PM -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 27 Aug 2010 06:35:13 +0200
>> 
>> > +	fold |= *(unsigned long *)(a + 6) ^ *(unsigned long *)(b + 6);
>> 
>> Shouldn't these be "+ 8" instead of "+ 6"?
> 
> I think +6 is right since we're trying to compare 14 bytes worth
> of data.

Indeed, thanks.  I need to borrow some brain cells :)
