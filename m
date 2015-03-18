From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 2/6] rhashtable: Introduce max_size/min_size
Date: Wed, 18 Mar 2015 12:47:42 -0400 (EDT)
Message-ID: <20150318.124742.962014167222813920.davem@davemloft.net>
References: <20150315104306.GA21999@gondor.apana.org.au>
	<E1YY9qm-0005mA-Jy@gondolin.me.apana.org.au>
	<20150318105528.GO17829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbbCRQro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 12:47:44 -0400
In-Reply-To: <20150318105528.GO17829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 18 Mar 2015 10:55:28 +0000

> On 03/18/15 at 08:01pm, Herbert Xu wrote:
>> @@ -935,6 +938,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
>>  
>>  	params->min_shift = max_t(size_t, params->min_shift,
>>  				  ilog2(HASH_MIN_SIZE));
>> +	params->min_size = max(params->min_size, HASH_MIN_SIZE);
>>  
>>  	if (params->nelem_hint)
>>  		size = rounded_hashtable_size(params);
> 
> The only change I would add on top is to ensure that min_size
> and max_size are a power of two as otherwise the table size
> used will end up being greater or smaller than specified.
> I can do that as a follow-up though.

Feel free.
