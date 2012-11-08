From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix two typos in a comment in xfrm6_init()
Date: Thu, 08 Nov 2012 14:59:39 -0500 (EST)
Message-ID: <20121108.145939.2274479010583117059.davem@davemloft.net>
References: <1352363888-14068-1-git-send-email-roy.qing.li@gmail.com>
	<20121108141936.GC22290@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283Ab2KHT7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 14:59:48 -0500
In-Reply-To: <20121108141936.GC22290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 8 Nov 2012 15:19:36 +0100

> On Thu, Nov 08, 2012 at 04:38:08PM +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>> 
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  net/ipv6/xfrm6_policy.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
>> index f3ed8ca..93832e8 100644
>> --- a/net/ipv6/xfrm6_policy.c
>> +++ b/net/ipv6/xfrm6_policy.c
>> @@ -332,10 +332,10 @@ int __init xfrm6_init(void)
>>  	/*
>>  	 * We need a good default value for the xfrm6 gc threshold.
>>  	 * In ipv4 we set it to the route hash table size * 8, which
>> -	 * is half the size of the maximaum route cache for ipv4.  It
>> +	 * is half the size of the maximum route cache for ipv4.
> 
> The routing cache is removed, so this comment is obsolete. But it reminds
> me that we set the gc threshold to ip_rt_max_size/2 in ipv4. With the
> routing cache removal patch, ip_rt_max_size was set to INT_MAX. So the gc
> starts to remove entries when a threshold of INT_MAX/2 is reached.
> 
> cat /proc/sys/net/ipv4/xfrm4_gc_thresh
> 1073741823
> 
> I guess this was not intentional.

Do you mean for IPSEC routes?  For non-IPSEC routes on ipv4 there
is nothing to garbage collect.
