From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*"
 and "foo * bar"
Date: Fri, 28 Mar 2014 13:09:38 -0400 (EDT)
Message-ID: <20140328.130938.946041549993034332.davem@davemloft.net>
References: <20140328.014012.963819707045886028.davem@davemloft.net>
	<1395985645.31134.2.camel@joe-AO722>
	<53354202.4080108@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbaC1RJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 13:09:41 -0400
In-Reply-To: <53354202.4080108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wangyufen <wangyufen@huawei.com>
Date: Fri, 28 Mar 2014 17:33:54 +0800

> On 2014/3/28 13:47, Joe Perches wrote:
>> On Fri, 2014-03-28 at 01:40 -0400, David Miller wrote:
>>> From: Joe Perches <joe@perches.com>
>>> Date: Thu, 27 Mar 2014 21:22:01 -0700
>>>
>>>> On Fri, 2014-03-28 at 12:07 +0800, Wangyufen wrote:
>>>> []
>>>>> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
>>>> []
>>>>> @@ -143,7 +143,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
>>>>>  	       addr[fn_bit >> 5];
>>>>>  }
>>>>
>>>> Perhaps all the __inline__ uses could be changed to inline too.
>>>
>>> Or rather, deleted completely, this is a *.c file after all.
>> 
>> Maybe right.  There are a lot though just in net/
>> 
>> $ git ls-files net | grep "\.c$" | \
>>   xargs grep -Pw "_{0,2}inline_{0,2}" | wc -l
>> 1512
>> 
>> 
>> 
>> 
>> 
> 
> Or change to inline and move the whole function to ip6_fib.h?

No, that is not desirable.  The whole point is to not export the interface
outside of the *.c file, and to let the compiler make inlining decisions
since it can see all of the call sites.
