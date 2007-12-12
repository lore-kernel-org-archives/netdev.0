From: Daniel Mack <daniel@caiaq.de>
Subject: Re: DM9000_IRQ_FLAGS
Date: Wed, 12 Dec 2007 16:01:33 +0100
Message-ID: <3F482A1B-2B23-4582-9714-18E40DAD16A2@caiaq.de>
References: <20071211191823.GD15295@buzzloop.caiaq.de> <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com> <20071212134153.GA21510@buzzloop.caiaq.de> <3efb10970712120646ub8f5047ub333b74658bab44d@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Remy Bohmer <linux@bohmer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:60622 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbXLLPBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 10:01:24 -0500
In-Reply-To: <3efb10970712120646ub8f5047ub333b74658bab44d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Dec 12, 2007, at 3:46 PM, Remy Bohmer wrote:

> The DM9000 adapter is connected to a GPIO line on the at91sam9261-ek
> board, the board-specific code has a generic handler for every GPIO
> interrupt. So, the Device driver __does not need to know__ the type of
> interrupt, It just installs a handler by request_irq().

Ok.

>>         resource->flags = IORESOURCE_IRQ | IRQT_RISING;
>>
> These types of flags are never meant to be compatible, and thus they
> shall not be stored in the same flags variable. The same is valid for
> the flags IRQF_* and IRQT* flags, so request_irq() is also not the
> place to do this.

Ah, so I was trapped by faulty code doing that. I thought as the
type of interrupt is also a detail information about the resource,
this is the place to put is. However, it also works with
set_irq_type().

Thanks for sorting that out :)

Best regards,
Daniel

