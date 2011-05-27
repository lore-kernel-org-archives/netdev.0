From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: Kill ratelimit.h dependency in linux/net.h
Date: Fri, 27 May 2011 13:42:04 -0400 (EDT)
Message-ID: <20110527.134204.174469626330626704.davem@davemloft.net>
References: <20110526.164330.2076981043593394399.davem@davemloft.net>
	<20110527084403.GD21386@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968Ab1E0RmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 13:42:11 -0400
In-Reply-To: <20110527084403.GD21386@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 27 May 2011 10:44:03 +0200

>> diff --git a/include/linux/net.h b/include/linux/net.h
>> index 1da55e9..b299230 100644
>> --- a/include/linux/net.h
>> +++ b/include/linux/net.h
>> @@ -289,11 +289,5 @@ extern int kernel_sock_shutdown(struct socket *sock,
>>  	MODULE_ALIAS("net-pf-" __stringify(pf) "-proto-" __stringify(proto) \
>>  		     "-type-" __stringify(type))
>>  
>> -#ifdef CONFIG_SYSCTL
>> -#include <linux/sysctl.h>
>> -#include <linux/ratelimit.h>
>> -extern struct ratelimit_state net_ratelimit_state;
>> -#endif
>> -
> 
> Assuming that this moved into net_ratelimit.h with a guard define 
> this looks good to me:
> 
> Acked-by: Ingo Molnar <mingo@elte.hu>

Yep, thanks for reviewing!
