From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: use del_timer_sync() in	sfq_destroy()
Date: Sun, 27 Apr 2008 21:10:23 +0200
Message-ID: <4814CF9F.5030001@trash.net>
References: <20080427125921.GA7480@ami.dom.local> <4814C4E2.50600@trash.net> <20080427190044.GA7747@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65391 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763552AbYD0TO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 15:14:28 -0400
In-Reply-To: <20080427190044.GA7747@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Sun, Apr 27, 2008 at 08:24:34PM +0200, Patrick McHardy wrote:
>   
>> Jarek Poplawski wrote:
>>     
>>> [NET_SCHED] sch_sfq: use del_timer_sync() in sfq_destroy()
>>>
>>> Let's delete timer reliably in sfq_destroy().
>>>       
>> This is broken, we hold dev->queue_lock in ->destroy.
>>
>>     
>
> But sfq timer (sfq_perturbation()) doesn't use this timer...
> Could you explain your point more?
My point was that it might sleep and can thus not be called
in atomic context. This was a misunderstanding on my side
though and your patch is fine.


