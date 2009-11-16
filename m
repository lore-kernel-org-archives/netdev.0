From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 02:21:44 -0800 (PST)
Message-ID: <20091116.022144.203823073.davem@davemloft.net>
References: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
	<1258365990.3251.33.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642AbZKPKV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:21:28 -0500
In-Reply-To: <1258365990.3251.33.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 16 Nov 2009 05:06:30 -0500

> On Mon, 2009-11-16 at 17:53 +0800, Changli Gao wrote:
> 
> Just one small comment; sorry, i missed this the first time:
> 
>> +		if (dev == NULL)
>>  			return -EINVAL;
>>  		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind,
>>  				     &mirred_idx_gen, &mirred_hash_info);
>>  		if (IS_ERR(pc))
>> -		    return PTR_ERR(pc);
>> +			return PTR_ERR(pc);
> 
> One indent too many? 

It's actually fixing some stray space characters into a real proper
tab character.
