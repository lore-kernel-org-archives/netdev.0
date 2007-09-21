From: Bruce Cole <bacole@gmail.com>
Subject: Re: e1000 driver and samba
Date: Fri, 21 Sep 2007 15:01:47 -0700
Message-ID: <46F43F4B.7090903@gmail.com>
References: <46F302A8.7040008@gmail.com> <20070921214916.GA2386@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bacole@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:25891 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761104AbXIUWFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 18:05:10 -0400
Received: by rv-out-0910.google.com with SMTP id k20so909007rvb
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 15:05:10 -0700 (PDT)
In-Reply-To: <20070921214916.GA2386@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Bruce Cole <bacole@gmail.com> :
>   
>>> If you look for it on the Realtek cards, there had been sporadic
>>> Nissues up to late 2005. The solution posted universally was 'change
>>> card'.
>>>       
>> Yes, that *was* the common recommendation.
>>     
>
> There was no such thing as a universal solution to sporadic issues.
>   
I made no such claim.  I do claim the realtek samba et all issues are 
not sporadic however.  In fact the
common problem is readily reproducible as has been shown.
> [...]
>   
>> I suspect the root problem is the driver isn't properly locking
>> the TX queue.
>>     
>
> Can you be more specific ?
>   
Yes per the reference I gave:
http://www.spinics.net/lists/netdev/msg40384.html
"Now since this change heals the TX queue stall, it would seem that the real

underlying problem involves a race condition with enqueueing to the TX queue

while the controller is processing the queue. The ultimate fix for that 
I bet is either to address locking at TX enqueue time, or there is a 
controller bug. Any clarification from realtek on the necessary 
processing for the NPQ bit, or

a known controller problem?

PS: I've also received private email that this problem pertains to video
streaming (to a Kiss DVD player) not just samba or X11 traffic.  Basically
most all high-level TCP based protocols are affected it seems.  This serious

performance problem should be considered to impact a lot more than just 
samba

users."

I could probably help fix the underlying problem but I didn't
receive any response to my post quoted above.





