From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 16:14:14 +0200
Message-ID: <469E2036.8050606@trash.net>
References: <200707181527.38895.florian.fainelli@telecomint.eu>	 <469E16C5.4000102@trash.net>	 <200707181544.11890.florian.fainelli@telecomint.eu>	 <469E1BB0.2040104@trash.net> <1184767844.21219.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian.fainelli@telecomint.eu>,
	netdev@vger.kernel.org
To: Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39780 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758825AbXGRORZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 10:17:25 -0400
In-Reply-To: <1184767844.21219.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Purdie wrote:
> On Wed, 2007-07-18 at 15:54 +0200, Patrick McHardy wrote:
>   
>> Florian Fainelli wrote:
>>     
>>>> Besides missing a declaration and not linking without the network
>>>> LED config option, its pretty ridiculous to call this for every
>>>> packet just to make a led blink.
>>>>     
>>>>         
>>> Could you suggest me a better way to do so ? The code was highly inspired from 
>>> what is done with the IDE trigger. The declaration is done in linux/leds.h, 
>>> which is included in dev.c for that purpose.
>>>   
>>>       
>> Maybe just increment a variable and periodically check it or something
>> like that.
>>     
>
> Are there not already packet counters that the LED trigger could just
> look at? If it did that at say 20Hz or 10Hz, it would probably look
> quite reasonable without impacting on the system too much

The qdisc counters might work, I think all qdiscs properly maintain
at least byte and packet counters. Or simply check the queue length,
if > 0 there is activity.

