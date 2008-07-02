From: Martin Devera <devik@cdi.cz>
Subject: Re: [RFC]: net-sched 00/05: dynamically sized class hashes
Date: Wed, 02 Jul 2008 16:27:48 +0200
Message-ID: <486B9064.4010506@cdi.cz>
References: <20080701143410.26309.45560.sendpatchset@localhost.localdomain> <20080701.195050.177373433.davem@davemloft.net> <486B262F.2040108@cdi.cz> <486B54B7.2060100@trash.net> <486B8ECF.3070604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:54764 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753717AbYGBO2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 10:28:08 -0400
In-Reply-To: <486B8ECF.3070604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> Martin Devera wrote:
>>> Interestingly, once you do this patch then children/siblings list-heads
>>> are used only in htb_parent_last_child and to detect empty class.
>>> Thus we could remove children/siblings lists altogether ane keep only
>>> children counter.
>>> I can't believe it is so simple, what do you think, Patrick ?
>>
>> Yes, it looks like that would work. I'll give it a try :)
> 
> How about this, on top of my previous patches?

Yes, it is exactly what have been in my mind. It should work.
Only I'm wondering why I didn't do it this way in the first
version :-)
