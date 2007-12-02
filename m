From: Patrick McHardy <kaber@trash.net>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sun, 02 Dec 2007 21:03:56 +0100
Message-ID: <47530FAC.1070804@trash.net>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca>	<20071201111736.297dd99a@freepuppy.rosehill>	<20071201163035.321fd554@freepuppy.rosehill>	<475227B1.2060802@rtr.ca> <20071201202354.672aed18@freepuppy.rosehill> <47530778.7030605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757023AbXLBUEi@vger.kernel.org>
In-Reply-To: <47530778.7030605@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Stephen Hemminger wrote:
>>>
>>> Naw, enterprise (or any other) distro vendors shouldn't have any 
>>> issues here,
>>> since they can just patch their kernels around any issues.
>>>
>>> But it looks like Eric has this one thought out well enough.
>>>     
>>
>> So you are saying all this is not a problem, fine.
>> Any affected parties can certainly lobby for themselves. But I suspect
>> they all think the kernel community is a bunch of ... and will just 
>> ignore
>> the problem.   
 >
> I have a binary module that uses dev_get_by_name...it's sort of a 
> bridge-like thing and
> needs user-space to tell it which device to listen for packets on...
> 
> This code doesn't need or care about name-spaces, so I don't see how it 
> could really
> be infringing on the author's code (any worse than loading a binary 
> driver into the kernel
> ever does).
> 
> I would certainly prefer to not have to patch around any problems with 
> calling dev_get_by_name
> from a non-gpl module, but if required, I can probably figure something 
> out...


For all I care binary modules can break, but frankly I don't see
how encapsulating a couple of structures and pointers in a new
structure and adding a new argument to existing functions shifts
the decision about how a function should be usable to the namespace
guys. IMO all functions should continue to be usable as before,
as decided by whoever actually wrote them. The only exception
might be stuff where an existing EXPORT_SYMBOL is clearly wrong,
but that would be a seperate discussion.

