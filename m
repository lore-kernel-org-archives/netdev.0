From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC]: net-sched 00/05: dynamically sized class hashes
Date: Wed, 02 Jul 2008 12:13:11 +0200
Message-ID: <486B54B7.2060100@trash.net>
References: <20080701143410.26309.45560.sendpatchset@localhost.localdomain> <20080701.195050.177373433.davem@davemloft.net> <486B262F.2040108@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65204 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbYGBKNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 06:13:13 -0400
In-Reply-To: <486B262F.2040108@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Devera wrote:
> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Tue,  1 Jul 2008 16:34:11 +0200 (MEST)
>>
>>> Only RFC at this point because they haven't been tested thoroughly yet
>>> and depend on the filter destruction fixes I sent this morning, but any
>>> review (especially of 4/5, the htb_delete changes) is welcome.
>>
>> These patches look fine to me.
>>
>> I haven't investigated the correctness of the details of patch
>> 4 yet, sorry :-)  Maybe someone else will be able to.
>>
> 
> It seems ok to me. I even can't remember why to destroy in class order :-)
> Interestingly, once you do this patch then children/siblings list-heads
> are used only in htb_parent_last_child and to detect empty class.
> Thus we could remove children/siblings lists altogether ane keep only
> children counter.
> I can't believe it is so simple, what do you think, Patrick ?

Yes, it looks like that would work. I'll give it a try :)
