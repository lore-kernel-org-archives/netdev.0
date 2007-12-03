From: Adrian Bunk <bunk@kernel.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Mon, 3 Dec 2007 02:14:37 +0100
Message-ID: <20071203011437.GP15974@stusta.de>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com> <47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill> <20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca> <20071201202354.672aed18@freepuppy.rosehill> <47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net> <20071202204356.GN15974@stusta.de> <47532AD2.8090704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:36255 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750717AbXLCBOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 20:14:44 -0500
Content-Disposition: inline
In-Reply-To: <47532AD2.8090704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2007 at 10:59:46PM +0100, Patrick McHardy wrote:
> Adrian Bunk wrote:
>> On Sun, Dec 02, 2007 at 09:03:56PM +0100, Patrick McHardy wrote:
>...
>> your statement has an interesting implication:
>>
>> Stuff like e.g. the EXPORT_SYMBOL(sk_alloc) predates the EXPORT_SYMBOL_GPL 
>> stuff.
>>
>> Who is considered the author of this code?
>>
>> And when should he state whether he prefers to use EXPORT_SYMBOL_GPL but 
>> wasn't able to use it at that when he wrote it since his code predates it 
>> and is glad to be able to decide this now?
>
> He can state it when he feels like it, I don't see the point.
> Authors generally get to decide whether they use EXPORT_SYMBOL
> or EXPORT_SYMBOL_GPL unless in cases where its really clear-cut
> that EXPORT_SYMBOL is inapproriate. But thats a different matter.
>...

You miss my point.

Stuff like sk_alloc was exported to modules before EXPORT_SYMBOL_GPL 
existed (it was even exported to modules before EXPORT_SYMBOL existed).

We are talking about code and exports that are at about 12 years old, 
which is at about twice as old as EXPORT_SYMBOL_GPL.

So what should happen in your opinion if e.g. Alan checks which of the 
network code he had written when it was exported a dozen years ago, 
stating that he never wanted it to be available to non-GPL modules?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

