From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Mon, 16 Jun 2008 20:21:48 +0200
Message-ID: <4856AF3C.9010904@krogh.cc>
References: <483CB301.40007@sun.com> <20080528.223415.193732490.davem@davemloft.net> <483F46E5.9030707@sun.com> <20080530.000009.02995266.davem@davemloft.net> <4856AC5E.1010206@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:60048 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611AbYFPSVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 14:21:49 -0400
In-Reply-To: <4856AC5E.1010206@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matheos Worku wrote:
> David Miller wrote:
> 
>> From: Matheos Worku <Matheos.Worku@Sun.COM>
>> Date: Thu, 29 May 2008 17:14:29 -0700
>>
>>  
>>
>>> Actually what I am suggesting was a workaround for the lack of "TX 
>>> Ring Empty" interrupt by not relying on the TX interrupt at all.
>>>   
>>
>> Ahh I see.
>>
>> Some of the things I talked about in my presentation here in
>> Berlin at LinuxTAG yesterday can help mitigate the effects.
>> Most of it revolves around batching, and allowing the driver
>> to manage the backlog of packets directly when the TX queue
>> fills up.
>>
>> In such a case we could batch the TX queue refill, know how many more
>> TX packets we will queue up to the chip right now, and therefore know
>> that we can safely set periodic MARK bits and only need to force set
>> the MARK bit at the very end.
>>
>>  
>>
>>> As for the TX hang, I will try to reproduce the problem and look at
>>> the registers for the clue.
>>>   
> Have been trying but not able to reproduce the timeout. I am using NFS 
> V3 with TCP. Are you using UDP by any chance?

I wouldn't say it is easy either.. I have never got it before getting a
few TB over the "wire". I've got proto=tcp in /proc/mounts for the
mountpoints, so I'd assume that I use TCP.

There is an Extreme Networks switch in the other end, I havent got
hardware to actually test that with a different card, so I cannot rule
the switch out either. .. but it would be strange.


Jesper
-- 
Jesper
