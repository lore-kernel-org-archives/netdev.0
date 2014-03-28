From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*"
 and "foo * bar"
Date: Fri, 28 Mar 2014 01:40:12 -0400 (EDT)
Message-ID: <20140328.014012.963819707045886028.davem@davemloft.net>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com>
	<1395979624-8544-4-git-send-email-wangyufen@huawei.com>
	<1395980521.19009.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangyufen@huawei.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaC1FkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 01:40:15 -0400
In-Reply-To: <1395980521.19009.8.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 27 Mar 2014 21:22:01 -0700

> On Fri, 2014-03-28 at 12:07 +0800, Wangyufen wrote:
> []
>> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> []
>> @@ -143,7 +143,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
>>  	       addr[fn_bit >> 5];
>>  }
> 
> Perhaps all the __inline__ uses could be changed to inline too.

Or rather, deleted completely, this is a *.c file after all.
