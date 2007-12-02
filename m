From: Ben Greear <greearb@candelatech.com>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sun, 02 Dec 2007 11:28:56 -0800
Message-ID: <47530778.7030605@candelatech.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca>	<20071201111736.297dd99a@freepuppy.rosehill>	<20071201163035.321fd554@freepuppy.rosehill>	<475227B1.2060802@rtr.ca> <20071201202354.672aed18@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:32952 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472AbXLBT3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 14:29:03 -0500
In-Reply-To: <20071201202354.672aed18@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>>
>> Naw, enterprise (or any other) distro vendors shouldn't have any issues here,
>> since they can just patch their kernels around any issues.
>>
>> But it looks like Eric has this one thought out well enough.
>>     
>
> So you are saying all this is not a problem, fine.
> Any affected parties can certainly lobby for themselves. But I suspect
> they all think the kernel community is a bunch of ... and will just ignore
> the problem. 
>   
I have a binary module that uses dev_get_by_name...it's sort of a 
bridge-like thing and
needs user-space to tell it which device to listen for packets on...

This code doesn't need or care about name-spaces, so I don't see how it 
could really
be infringing on the author's code (any worse than loading a binary 
driver into the kernel
ever does).

I would certainly prefer to not have to patch around any problems with 
calling dev_get_by_name
from a non-gpl module, but if required, I can probably figure something 
out...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


