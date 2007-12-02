From: Adrian Bunk <bunk@kernel.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sun, 2 Dec 2007 21:43:56 +0100
Message-ID: <20071202204356.GN15974@stusta.de>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com> <47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill> <20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca> <20071201202354.672aed18@freepuppy.rosehill> <47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756681AbXLBUoW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47530FAC.1070804@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 02, 2007 at 09:03:56PM +0100, Patrick McHardy wrote:
> Ben Greear wrote:
>> Stephen Hemminger wrote:
>>>>
>>>> Naw, enterprise (or any other) distro vendors shouldn't have any issues 
>>>> here,
>>>> since they can just patch their kernels around any issues.
>>>>
>>>> But it looks like Eric has this one thought out well enough.
>>>>     
>>>
>>> So you are saying all this is not a problem, fine.
>>> Any affected parties can certainly lobby for themselves. But I suspect
>>> they all think the kernel community is a bunch of ... and will just 
>>> ignore
>>> the problem.   
> >
>> I have a binary module that uses dev_get_by_name...it's sort of a 
>> bridge-like thing and
>> needs user-space to tell it which device to listen for packets on...
>>
>> This code doesn't need or care about name-spaces, so I don't see how it 
>> could really
>> be infringing on the author's code (any worse than loading a binary driver 
>> into the kernel
>> ever does).
>>
>> I would certainly prefer to not have to patch around any problems with 
>> calling dev_get_by_name
>> from a non-gpl module, but if required, I can probably figure something 
>> out...
>
>
> For all I care binary modules can break, but frankly I don't see
> how encapsulating a couple of structures and pointers in a new
> structure and adding a new argument to existing functions shifts
> the decision about how a function should be usable to the namespace
> guys. IMO all functions should continue to be usable as before,
> as decided by whoever actually wrote them.
>...

Even ignoring the fact that it's unclear whether distributing modules 
with not GPLv2 compatible licences is legal at all or might bring you in 
jail, your statement has an interesting implication:

Stuff like e.g. the EXPORT_SYMBOL(sk_alloc) predates the 
EXPORT_SYMBOL_GPL stuff.

Who is considered the author of this code?

And when should he state whether he prefers to use EXPORT_SYMBOL_GPL 
but wasn't able to use it at that when he wrote it since his code 
predates it and is glad to be able to decide this now?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

