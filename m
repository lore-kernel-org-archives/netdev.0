From: Ben Greear <greearb@candelatech.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 15:12:45 -0700
Message-ID: <4ABD405D.2030106@candelatech.com>
References: <20090925214505.GA3472@gondor.apana.org.au> <4ABD3B34.8010903@candelatech.com> <20090925.145915.68839478.davem@davemloft.net> <20090925220115.GA3684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59445 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbZIYWOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:14:46 -0400
In-Reply-To: <20090925220115.GA3684@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2009 03:01 PM, Herbert Xu wrote:
> On Fri, Sep 25, 2009 at 02:59:15PM -0700, David Miller wrote:
>> From: Ben Greear<greearb@candelatech.com>
>> Date: Fri, 25 Sep 2009 14:50:44 -0700
>>
>>> I get aggregate 18Gbps with LRO v/s 12Gbps without, so it's very
>>> much a useful feature for me.
>>
>> And it'll stay like that until you work with Herbert to fix
>> that performance difference.
>
> Actually I believe he's talking about hardware LRO which is a
> different beast.
>
> AFAICS the ixgbe driver doesn't use software LRO anymore.
>
> So if it is hardware LRO then what we need is for the hardware
> to switch over :)

Either way, I will be happy to test & benchmark patches of this nature
if someone wants to post them.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

