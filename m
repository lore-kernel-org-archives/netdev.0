From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [RFC] FEC patches
Date: Thu, 15 Jan 2009 11:24:13 +0100
Message-ID: <20090115102413.GT11228@pengutronix.de>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <496EB65F.2060704@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43796 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480AbZAOKYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 05:24:14 -0500
Content-Disposition: inline
In-Reply-To: <496EB65F.2060704@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 02:06:55PM +1000, Greg Ungerer wrote:
> Hi Sacha,
>
> Sascha Hauer wrote:
>> The following patches apply to the FEC driver (drivers/net/fec.c). While
>> found on several Freescale/Motorola chips, this driver is currently only
>> used for Coldfire. These patches add support for the ARM based i.MX27
>> SoC.
>>
>> I'm almost sure I break the driver for some (all?) Coldfire guys, but I
>> do not have any Coldfire based board to test the patches on.
>
> I can test patches on most ColdFire boards.
>
>
>> The first 4 patches should be ok as is, comments?
>
> Only the one that I commented on with FEC_FLASHMAC.
> Otherwise the first 4 apply and work for ColdFire.
>
>
>> The other patches are somewhat work in progress, but they show which
>> changes I need for my hardware.
>
> Currently the change to use dma_alloc_coherent breaks ColdFire.
> I need to debug that and see why that is the case.
>
> Otherwise they look ok to me.
>
>
>> The driver could use quite some cleanup patches for coding style, turn
>> it into a platform device driver and add exit functions. I'm sure I
>
> Yes, it does badly need this. I have been meaning to extract
> the ColdFire platform specifics for some time. That would improve
> it quite a bit.
>

My plan is to put the current static initialization code into some kind
of #ifdef FEC_LEGACY and use a proper platform device driver otherwise.
This would leave the code in place for now and it could be ported over
to platform devices per platform. Is this ok for you?

Regards
  Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
