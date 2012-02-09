From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Thu, 09 Feb 2012 07:44:34 +0100
Message-ID: <4F336B52.90000@profihost.ag>
References: <4F2B8348.3090305@profihost.ag>	<1328253972.2480.42.camel@edumazet-laptop>	<4F2B963F.4020504@profihost.ag> <20120208.202651.97221367956126026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregkh@linuxfoundation.org,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:41388 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953Ab2BIGof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 01:44:35 -0500
In-Reply-To: <20120208.202651.97221367956126026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.02.2012 02:26, schrieb David Miller:
> From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
> Date: Fri, 03 Feb 2012 09:09:35 +0100
> 
>> Hi,
>>
>> attached you find the patch files applying cleanly to 3.0.X.
>>
>>>> I've made my own backport of the patch and removed at least 1-2
>>>> dependencies. Anybody interested?
>>>>
>>>
>>> If you did the work, post it for review.
>>
>> Thanks!
> 
> I think you backported way too much, the ->lookup_neigh() dst ops
> abstraction is unnecessary, all of the neighbour hash function
> changes are also completely unnecessary.
> 
> All you needed to backport is that bit that abstracts dst->neighbour()
> behind helper routines.
> 
> The point of this exercise is not to keep backporting changes until
> the subsequent patch applies cleanly, it's to backport the minimal
> amount necessary to get the effect of the patch you're ultimately
> interested in adding.
> 
> I'll work on coming up with something much more sensible tonight.

Thank you very much. As im pinted out i'm not a C dev nor a kernel
hacker. So i was pretty happy that it was working.

Stefan
