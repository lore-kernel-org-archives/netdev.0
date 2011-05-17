From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sk-filter: Rate-limit WARNing, print dbg info.
Date: Tue, 17 May 2011 15:39:22 -0400 (EDT)
Message-ID: <20110517.153922.340820072009412798.davem@davemloft.net>
References: <1305658349.1722.30.camel@Joe-Laptop>
	<20110517.152357.85105240786269960.davem@davemloft.net>
	<4DD2CDA9.7000009@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab1EQTjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:39:25 -0400
In-Reply-To: <4DD2CDA9.7000009@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 17 May 2011 12:34:01 -0700

> On 05/17/2011 12:23 PM, David Miller wrote:
>> From: Joe Perches<joe@perches.com>
>> Date: Tue, 17 May 2011 11:52:29 -0700
>>
>>> On Tue, 2011-05-17 at 11:30 -0700, greearb@candelatech.com wrote:
>>>> From: Ben Greear<greearb@candelatech.com>
>>>> A mis-configured filter can spam the logs with
>>>> lots of stack traces.  Rate-limit the warnings
>>>> and add printout of the bogus filter information.
>>>> -			WARN_ON(1);
>>>> +			if (net_ratelimit()) {
>>>> + pr_err("filter: Unknown code: %hu jt: %u tf: %u"
>>>> +				       " k: %u\n",
>>>> + fentry->code, (unsigned int)(fentry->jt),
>>>> + (unsigned int)(fentry->jf), fentry->k);
>>>> +				WARN_ON(1);
>>>> +			}
>>>
>>> Maybe just using WARN is better.
>>
>> Yep, it looks better to me.
> 
> You want to just take his, or shall I re-spin it?

Respin.
