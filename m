From: Ben Greear <greearb@candelatech.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 03 Jan 2007 08:53:22 -0800
Message-ID: <459BDF82.9000901@candelatech.com>
References: <4599E6D5.6050207@candelatech.com> <OFB8CE3E37.99FD5849-ON88257257.0080FAE8-88257257.00819B15@us.ibm.com> <20070103080711.GA1747@ff.dom.local> <20070103082826.GB1747@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:59699 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbXACQ6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 11:58:48 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070103082826.GB1747@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Wed, Jan 03, 2007 at 09:07:11AM +0100, Jarek Poplawski wrote:
>   
>> On Tue, Jan 02, 2007 at 03:35:39PM -0800, David Stevens wrote:
>>     
>>> I've looked at this a little too -- it'd be nice to know who holds
>>> the write lock.
>>>       
>> If you mean mc_list_lock - probably nobody - it's
>> not initialized (so the timers) for this in_device
>>     
>
> I should say: "... probably not initialized ...".
>   
That should print out the debugging when you access an un-initialized 
lock, and I did not
see that print-out in the logs.   I looked at the code and could not 
explain how it could
be accessed un-initialized, so I'm not certain this is the problem.

If I can reproduce this in a controlled manner, I'll add debugging to 
print out who is holding
the lock (if anyone), as well as make sure it is initialized before the 
blocking method initializes
it.  It will likely be a few days before we can set up something to 
reproduce it, however.

If you can explain any code path that could leave the lock 
uninitialized, then that would be a
big help...but it looked ok to me...

Ben

> Jarek P. 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


