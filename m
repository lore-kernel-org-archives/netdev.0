From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [RFC] FEC patches
Date: Fri, 16 Jan 2009 10:10:41 +1000
Message-ID: <496FD081.6060803@snapgear.com>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <496EB65F.2060704@snapgear.com> <20090115102413.GT11228@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:43333 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758858AbZAPAKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 19:10:48 -0500
In-Reply-To: <20090115102413.GT11228@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

Sascha Hauer wrote:
> On Thu, Jan 15, 2009 at 02:06:55PM +1000, Greg Ungerer wrote:
>> Hi Sacha,
>>
>> Sascha Hauer wrote:
>>> The following patches apply to the FEC driver (drivers/net/fec.c). While
>>> found on several Freescale/Motorola chips, this driver is currently only
>>> used for Coldfire. These patches add support for the ARM based i.MX27
>>> SoC.
>>>
>>> I'm almost sure I break the driver for some (all?) Coldfire guys, but I
>>> do not have any Coldfire based board to test the patches on.
>> I can test patches on most ColdFire boards.
>>
>>
>>> The first 4 patches should be ok as is, comments?
>> Only the one that I commented on with FEC_FLASHMAC.
>> Otherwise the first 4 apply and work for ColdFire.
>>
>>
>>> The other patches are somewhat work in progress, but they show which
>>> changes I need for my hardware.
>> Currently the change to use dma_alloc_coherent breaks ColdFire.
>> I need to debug that and see why that is the case.
>>
>> Otherwise they look ok to me.
>>
>>
>>> The driver could use quite some cleanup patches for coding style, turn
>>> it into a platform device driver and add exit functions. I'm sure I
>> Yes, it does badly need this. I have been meaning to extract
>> the ColdFire platform specifics for some time. That would improve
>> it quite a bit.
>>
> 
> My plan is to put the current static initialization code into some kind
> of #ifdef FEC_LEGACY and use a proper platform device driver otherwise.
> This would leave the code in place for now and it could be ported over
> to platform devices per platform. Is this ok for you?

Yeah, that is ok by me.

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
