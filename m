From: Shannon Wynter <kernel.org.alias@fremnet.net>
Subject: Re: [PATCH] skge: 32bit DMA for ASUS A8N-SLI Premium
Date: Wed, 05 Jan 2011 15:55:13 +1000
Message-ID: <4D2407C1.3020907@fremnet.net>
References: <4CEFBB72.2060400@fremnet.net> <20101126105233.091f818d@nehalam> <4CF004EF.90107@fremnet.net>
Reply-To: Shannon Wynter <kernel.org.alias@fremnet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:13977 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750938Ab1AEGA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 01:00:27 -0500
Received: from priya.2y.net (localhost [127.0.0.1])
	by priya.2y.net (Postfix) with ESMTP id A78271D82A5
	for <netdev@vger.kernel.org>; Wed,  5 Jan 2011 15:55:17 +1000 (EST)
Received: from [10.0.1.117] (eth2026.qld.adsl.internode.on.net [150.101.176.237])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: freman from domain fremnet.net)
	by priya.2y.net (Postfix) with ESMTPSA id 2C84E1D82A3
	for <netdev@vger.kernel.org>; Wed,  5 Jan 2011 15:55:16 +1000 (EST)
In-Reply-To: <4CF004EF.90107@fremnet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't mean to be impatient but any progress with this?

On 27/11/10 05:05, Shannon Wynter wrote:
> Stephen Hemminger wrote:
>> On Fri, 26 Nov 2010 23:51:46 +1000
>> Shannon Wynter <kernel.org.alias@fremnet.net> wrote:
>>
>>> Add ASUS A8N-SLI Premium to the list of boards that require the 
>>> quirk to
>>> limit DMA to 32bit in the skge.c module.
>>>
>>> Signed-off-by: Shannon Wynter <kernel.org.alias@fremnet.net>
>>> ---
>>> --- a/drivers/net/skge.c    2010-11-26 08:35:21.000000000 +1000
>>> +++ b/drivers/net/skge.c    2010-11-26 08:58:52.000000000 +1000
>>> @@ -4158,6 +4158,13 @@
>>>               DMI_MATCH(DMI_BOARD_NAME, "nForce"),
>>>           },
>>>       },
>>> +    {
>>> +        .ident = "ASUSTeK A8N-SLI Premium",
>>> +        .matches = {
>>> +            DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
>>> +            DMI_MATCH(DMI_BOARD_NAME, "A8N-SLI Premium"),
>>> +        },
>>> +    },
>>>       {}
>>>   };
>>>
>>>
>>
>> Ok. Maybe I have to buy one of these beasts to find the root
>> cause of this.
>>
>
> It's quite an old board, I'd let you on mine and say go for your life 
> but it's actually kind of mission critical (in so much as a home 
> server can be).
>
> Is there anything I can provide/do/run for you to give you a head 
> start in the right direction?
> The problem showed up when I upgraded from 1gb to 4gb of memory (the 
> maximum the board can handle)
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
