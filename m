From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv6: Replace inet6_ifaddr->dead with state
Date: Tue, 18 May 2010 15:27:20 -0700 (PDT)
Message-ID: <20100518.152720.163227756.davem@davemloft.net>
References: <20100518110243.GA7750@gondor.apana.org.au>
	<E1OEKax-00022W-6K@gondolin.me.apana.org.au>
	<20100518102334.70b6c0b4@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56854
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751548Ab0ERW1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:27:11 -0400
In-Reply-To: <20100518102334.70b6c0b4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 18 May 2010 10:23:34 -0700

> On Tue, 18 May 2010 21:04:19 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>>  
>> +enum {
>> +	INET6_IFADDR_STATE_DAD,
>> +	INET6_IFADDR_STATE_POSTDAD,
>> +	INET6_IFADDR_STATE_UP,
>> +	INET6_IFADDR_STATE_DEAD,
>> +};
>> +
>>  #ifdef __KERNEL__
> 
> Does this really need to be visible to user applications?

I'll fix this up when I apply Herbert's patches.
