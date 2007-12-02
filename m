From: Patrick McHardy <kaber@trash.net>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sun, 02 Dec 2007 22:59:46 +0100
Message-ID: <47532AD2.8090704@trash.net>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com> <47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill> <20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca> <20071201202354.672aed18@freepuppy.rosehill> <47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net> <20071202204356.GN15974@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46990 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbXLBV7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 16:59:53 -0500
In-Reply-To: <20071202204356.GN15974@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> On Sun, Dec 02, 2007 at 09:03:56PM +0100, Patrick McHardy wrote:
>
>> For all I care binary modules can break, but frankly I don't see
>> how encapsulating a couple of structures and pointers in a new
>> structure and adding a new argument to existing functions shifts
>> the decision about how a function should be usable to the namespace
>> guys. IMO all functions should continue to be usable as before,
>> as decided by whoever actually wrote them.
>> ...
> 
> Even ignoring the fact that it's unclear whether distributing modules 
> with not GPLv2 compatible licences is legal at all or might bring you in 
> jail,

Agreed, lets ignore that :)

> your statement has an interesting implication:
> 
> Stuff like e.g. the EXPORT_SYMBOL(sk_alloc) predates the 
> EXPORT_SYMBOL_GPL stuff.
> 
> Who is considered the author of this code?
> 
> And when should he state whether he prefers to use EXPORT_SYMBOL_GPL 
> but wasn't able to use it at that when he wrote it since his code 
> predates it and is glad to be able to decide this now?


He can state it when he feels like it, I don't see the point.
Authors generally get to decide whether they use EXPORT_SYMBOL
or EXPORT_SYMBOL_GPL unless in cases where its really clear-cut
that EXPORT_SYMBOL is inapproriate. But thats a different matter.

If a symbol was OK to be used previously and something using it
would not automatically be considered a derived work, how does
passing &init_net to the function just to make the compiler
happy, avoid BUG_ONs and generally keep things working as before
make it more of a derived work?
