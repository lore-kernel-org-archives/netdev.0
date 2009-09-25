From: Ben Greear <greearb@candelatech.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 14:50:44 -0700
Message-ID: <4ABD3B34.8010903@candelatech.com>
References: <20090925214505.GA3472@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47033 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbZIYVwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 17:52:50 -0400
In-Reply-To: <20090925214505.GA3472@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2009 02:45 PM, Herbert Xu wrote:
> Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>  wrote:
>>
>>> That's a bummer.  I'm guessing you might get close to right on average with some
>>> trivial math, but if someone is sending you pkts with size of 1000 and
>>> your MTU is 1500, would there be any way to tell that the pkts were originally
>>> 1000 bytes instead of 1500?
>>
>> Good point.
>
> Well if you did GRO instead of LRO then none of this would matter :)

I get aggregate 18Gbps with LRO v/s 12Gbps without, so it's very much a useful feature
for me.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

