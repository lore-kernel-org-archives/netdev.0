From: Andy Fleming <afleming@freescale.com>
Subject: Re: [BUG] 2.6.30-rc4: Kernel BUG under network load with gianfar
Date: Fri, 22 May 2009 12:18:22 -0500
Message-ID: <C6E445A9-0CE7-4270-848E-6FB34B3271D5@freescale.com>
References: <50F164E7-D247-4FD6-B41B-BDAA8681166B@it-loops.com> <20090520214734.GA11277@mail.wantstofly.org> <20090521.152439.79009648.davem@davemloft.net> <9E304569-5828-403D-B4B0-845D8F0D6B95@it-loops.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, buytenh@wantstofly.org,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	netdev@vger.kernel.org
To: Michael Guntsche <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45533 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbZEVRTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 13:19:08 -0400
In-Reply-To: <9E304569-5828-403D-B4B0-845D8F0D6B95@it-loops.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 22, 2009, at 9:27 AM, Michael Guntsche wrote:

>>>
>>> Something like the patch below would fix it.
>>
>> Let me know when a final, tested, version of this patch is available
>> and please make sure it makes it to netdev@vger.kernel.org
>
> I can confirm that Lennert's patch fixes my panic problems here.  
> After applying it, my connection has been rock solid and I no longer  
> get any kernel panics.
> That said, I think the final descision if this patch should go in  
> like it is now has to be made by Andy Fleming since he wrote the  
> initial code.

I'm working (admittedly fairly slowly) on a patch that resets the  
pointers so they don't get moved twice.  That way we can continue to  
benefit from recycling the error skbs.
