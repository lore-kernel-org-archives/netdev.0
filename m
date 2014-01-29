From: Andre Naujoks <nautsch2@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Wed, 29 Jan 2014 16:35:52 +0100
Message-ID: <52E91FD8.90402@gmail.com>
References: <52E833ED.4080006@hartkopp.net>		<1390953066.28432.26.camel@edumazet-glaptop2.roam.corp.google.com>		<52E8B053.2030808@gmail.com>	 <20140128.234630.1768378245126172951.davem@davemloft.net>	 <52E8C03A.4030906@gmail.com> <1391007225.28432.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:45814 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaA2Pfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 10:35:55 -0500
Received: by mail-wg0-f47.google.com with SMTP id m15so3786600wgh.26
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 07:35:54 -0800 (PST)
In-Reply-To: <1391007225.28432.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2014 15:53, schrieb Eric Dumazet:
> On Wed, 2014-01-29 at 09:47 +0100, Andre Naujoks wrote:
>> On 29.01.2014 08:46, schrieb David Miller:
>>> From: Andre Naujoks <nautsch2@gmail.com>
>>> Date: Wed, 29 Jan 2014 08:40:03 +0100
>>>
>>>> Even if this is a bug in the CAN BCM implementation. Your "fix" just
>>>> enabled a user space application to shut down any machine with a kernel
>>>> containing the BUG_ON patch.
>>>
>>> Rather, he detected a potential stray pointer reference to freed data
>>> that was caused by the CAN code which would difficult if not
>>> impossible to detect otherwise.
>>>
>>> That's even more dangerous, and you should be thanking him.
>>
>> "potential" is the keyword here. But its a definite kernel crash as it
>> is right now with a standard use case for the BCM.
>>
>> Don't get me wrong. If there are bugs in the code, they should be fixed,
>> but I don't think breaking a working (even if flawed) part of the kernel
>> is the right thing to do here.
> 
> Shall I remember you this patch was suggested by David Miller, our
> beloved network maintainer ?

no, but thank you.

> 
> Really this is quite silly, I'll tell you.

Totally with you on that.

> 
> I can send a patch to mark CAN as BROKEN if you want, or you can send an
> appropriate patch.
> 
> Your resistance is futile.

I am not resisting to anything. I was just *irritated* about the way
this was handled. Since Oliver is already trying to fix this, any
further discussion here is meaningless anyway.

Regards
  Andre

> 
> 
