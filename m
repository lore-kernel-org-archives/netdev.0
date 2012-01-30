From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Mon, 30 Jan 2012 19:53:34 +0100
Message-ID: <4F26E72E.2020007@profihost.ag>
References: <4EE32076.2020706@profihost.ag> <4F26571E.1010002@profihost.ag> <20120130171215.GA11508@kroah.com> <20120130.130717.348683183628737352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, eric.dumazet@gmail.com, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:54703 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab2A3Sxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 13:53:38 -0500
In-Reply-To: <20120130.130717.348683183628737352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Hi Greg,

>>> Am 10.12.2011 10:03, schrieb Stefan Priebe:
>>>> Am 09.12.2011 20:21, schrieb David Miller:
>>>>> From: Stefan Priebe<s.priebe@profihost.ag>
>>>>> Date: Fri, 09 Dec 2011 20:01:26 +0100
>>>>>
>>>>>> any news on that? Systems still crashing every now and then. 3.0.13
>>>>>> was released today but i haven't seen any of them.
>>>>>
>>>>> I only had time to submit these fixes for 3.1.x-stable, you'll just
>>>>> have to be incredibly patient.
>>>
>>> this bug sadly still makes the actual STABLE tree of the kernel
>>> unusable. I mean nearly everbody uses TCP/IP.
>>
>> "this bug"?
>
> Actually, like Greg, I cannot figure out which fix you are referring
> to.
>
> You haven't provided enough context, and even searching into the
> mailing list archives I cannot find a link into the real history of
> this discussion thread.

sorry about beeing so unspecific.

I'm talking about:
[171464.091567] BUG: unable to handle kernel NULL pointer dereference at 
000000000000002c
[171464.092073] IP: [<ffffffff815494f6>] ipv4_dst_check+0xb6/0x190
[171464.092073] PGD 15344e067 PUD 14c821067 PMD 0
[171464.092073] Oops: 0002 [#1] SMP

Which is caused by: ipv4: fix lockdep splat in rt_cache_seq_show
	
This is the patchset you made for 3.1:
http://www.spinics.net/lists/netdev/msg182508.html

So we're talking AT LEAST about these ones:
 >Linus tree :
 >
 >commit 580da35a31f91a594f3090b7a2c39b85cb051a12
 >IB: Fix RCU lockdep splats
 >
 >David tree :
 >
 >commit 218fa90f072e4aeff9003d57e390857f4f35513e
 >ipv4: fix lockdep splat in rt_cache_seq_show
 >
 >commit f7e57044eeb1841847c24aa06766c8290c202583
 >sch_teql: fix lockdep splat

Greets and thanks!

Stefan
