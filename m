From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC]: net-sched 00/05: dynamically sized class hashes
Date: Wed, 02 Jul 2008 16:30:09 +0200
Message-ID: <486B90F1.8020606@trash.net>
References: <20080701143410.26309.45560.sendpatchset@localhost.localdomain> <20080701.195050.177373433.davem@davemloft.net> <486B262F.2040108@cdi.cz> <486B54B7.2060100@trash.net> <486B8ECF.3070604@trash.net> <486B9064.4010506@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39378 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbYGBOaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 10:30:11 -0400
In-Reply-To: <486B9064.4010506@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Devera wrote:
> Patrick McHardy wrote:
>> Patrick McHardy wrote:
>>> Martin Devera wrote:
>>>> Interestingly, once you do this patch then children/siblings list-heads
>>>> are used only in htb_parent_last_child and to detect empty class.
>>>> Thus we could remove children/siblings lists altogether ane keep only
>>>> children counter.
>>>> I can't believe it is so simple, what do you think, Patrick ?
>>>
>>> Yes, it looks like that would work. I'll give it a try :)
>>
>> How about this, on top of my previous patches?
> 
> Yes, it is exactly what have been in my mind. It should work.

Thanks!

> Only I'm wondering why I didn't do it this way in the first
> version :-)

I'm guessing there was no working example of destroying
filters without walking the tree in hierarchical order.
All other qdiscs were buggy or non-existant at that time :)
