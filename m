From: Shannon Wynter <kernel.org.alias@fremnet.net>
Subject: Re: [PATCH] skge: 32bit DMA for ASUS A8N-SLI Premium
Date: Sat, 27 Nov 2010 05:05:19 +1000
Message-ID: <4CF004EF.90107@fremnet.net>
References: <4CEFBB72.2060400@fremnet.net> <20101126105233.091f818d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:34237 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755817Ab0KZTF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 14:05:26 -0500
In-Reply-To: <20101126105233.091f818d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 26 Nov 2010 23:51:46 +1000
> Shannon Wynter <kernel.org.alias@fremnet.net> wrote:
>
>   
>> Add ASUS A8N-SLI Premium to the list of boards that require the quirk to
>> limit DMA to 32bit in the skge.c module.
>>
>> Signed-off-by: Shannon Wynter <kernel.org.alias@fremnet.net>
>> ---
>> --- a/drivers/net/skge.c	2010-11-26 08:35:21.000000000 +1000
>> +++ b/drivers/net/skge.c	2010-11-26 08:58:52.000000000 +1000
>> @@ -4158,6 +4158,13 @@
>>   			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
>>   		},
>>   	},
>> +	{
>> +		.ident = "ASUSTeK A8N-SLI Premium",
>> +		.matches = {
>> +			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
>> +			DMI_MATCH(DMI_BOARD_NAME, "A8N-SLI Premium"),
>> +		},
>> +	},
>>   	{}
>>   };
>>
>>
>>     
>
> Ok. Maybe I have to buy one of these beasts to find the root
> cause of this.
>
>   

It's quite an old board, I'd let you on mine and say go for your life 
but it's actually kind of mission critical (in so much as a home server 
can be).

Is there anything I can provide/do/run for you to give you a head start 
in the right direction?
The problem showed up when I upgraded from 1gb to 4gb of memory (the 
maximum the board can handle)
