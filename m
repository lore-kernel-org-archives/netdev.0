From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.17: networking bug??
Date: Tue, 13 Jun 2006 15:08:59 -0400
Message-ID: <448F0D4B.30201@rtr.ca>
References: <448EC6F3.3060002@rtr.ca> <448ECB09.3010308@rtr.ca> <448ED2FC.2040704@rtr.ca> <448ED9B3.8050506@rtr.ca> <448EEE9D.10105@rtr.ca> <448EF45B.2080601@rtr.ca> <448EF85E.50405@psc.edu> <Pine.LNX.4.64.0606131048550.5498@g5.osdl.org> <448F0344.9000008@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([64.26.128.89]:23962 "EHLO mail.rtr.ca")
	by vger.kernel.org with ESMTP id S1750990AbWFMTJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 15:09:01 -0400
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <448F0344.9000008@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord wrote:
> Linus Torvalds wrote:
>
>> It's not like there aren't broken boxes out there, and it might be 
>> better to make the default buffer sizes just be low enough that window 
>> scaling simply isn't an issue.
>>
>> I suspect that the people who really want/need window scaling know 
>> about it, and could be assumed to know enough to raise their limits, no?
> 
> Agreed.  It's taken me over a month here to realize that the particular
> webserver in question (www.everymac.com) wasn't "dead", but merely being
> blocked by my 2.6.17 kernel.  All was fine with 2.6.16, as I discovered 
> today.
> 
> I wonder how many other "dead sites" there are out there,
> that will be shut off from people when they "upgrade" to 2.6.17 ?
> 
> I'm a kernel hacker.  Most users of 2.6.17 will not be.
> The default should be something that works "by default".

Further to this, the current behaviour is badly unpredictable.

A machine could be working perfectly, not (noticeably) affected
by this bug.  And then the user adds another stick of RAM to it.

Poof.. many sites from the internet stop responding.
Obviously the RAM upgrade broke things.. must be bad RAM, right?

Err.. no, the networking stack simply decided to become incompatible
with certain sites, as a result of the user adding more RAM to their machine.

BbD.
