From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] fs_enet: MDIO on GPIO support
Date: Fri, 18 Jul 2008 13:10:25 -0400
Message-ID: <4880CE81.4090608@pobox.com>
References: <200805261152.37636.laurentp@cse-semaphore.com> <200806261321.24338.laurentp@cse-semaphore.com> <20080626175523.54728d07@vitb.ru.mvista.com> <200807181126.48246.laurentp@cse-semaphore.com> <E7FD62BF-C2BB-4803-87AB-91DD7AB8FD0C@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurentp@cse-semaphore.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, linuxppc-dev@ozlabs.org,
	Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58694 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757441AbYGRRKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 13:10:46 -0400
In-Reply-To: <E7FD62BF-C2BB-4803-87AB-91DD7AB8FD0C@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> 
> On Jul 18, 2008, at 4:26 AM, Laurent Pinchart wrote:
> 
>> On Thursday 26 June 2008, Vitaly Bordug wrote:
>>> On Thu, 26 Jun 2008 13:21:23 +0200
>>> Laurent Pinchart <laurentp@cse-semaphore.com> wrote:
>>>
>>>>> There should be no dependencies. When the OF GPIO support is not
>>>>> selected linux/of_gpio.h will define of_get_gpio() as a stub, so the
>>>>> fs_enet driver will fall back to the legacy binding.
>>>>
>>>> Have we reached a consensus on which tree the patch should go to ?
>>> I think it should go through powerpc tree, not seeing too much
>>> netdev-generic stuff in here. If noone will object, Kumar will pick 
>>> it up I
>>> guess...
>>
>> Kumar, could you pick it up ? I'd like to see this in 2.6.27.
>>
>> Best regards,
> 
> Jeff said he applied both to his tree already.

Yep, it's already in davem's net-next...

	Jeff



