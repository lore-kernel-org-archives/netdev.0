From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] sk-filter: Rate-limit WARNing, print dbg info.
Date: Tue, 17 May 2011 12:34:01 -0700
Message-ID: <4DD2CDA9.7000009@candelatech.com>
References: <1305657014-32736-1-git-send-email-greearb@candelatech.com>	<1305658349.1722.30.camel@Joe-Laptop> <20110517.152357.85105240786269960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60517 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932105Ab1EQTeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:34:05 -0400
In-Reply-To: <20110517.152357.85105240786269960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2011 12:23 PM, David Miller wrote:
> From: Joe Perches<joe@perches.com>
> Date: Tue, 17 May 2011 11:52:29 -0700
>
>> On Tue, 2011-05-17 at 11:30 -0700, greearb@candelatech.com wrote:
>>> From: Ben Greear<greearb@candelatech.com>
>>> A mis-configured filter can spam the logs with
>>> lots of stack traces.  Rate-limit the warnings
>>> and add printout of the bogus filter information.
>>> -			WARN_ON(1);
>>> +			if (net_ratelimit()) {
>>> +				pr_err("filter: Unknown code: %hu jt: %u tf: %u"
>>> +				       " k: %u\n",
>>> +				       fentry->code, (unsigned int)(fentry->jt),
>>> +				       (unsigned int)(fentry->jf), fentry->k);
>>> +				WARN_ON(1);
>>> +			}
>>
>> Maybe just using WARN is better.
>
> Yep, it looks better to me.

You want to just take his, or shall I re-spin it?

Either is fine with me.

Thanks,
Ben

>
>> I believe the casts aren't necessary.
>
> Also correct.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

