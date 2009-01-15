From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [RFC] FEC patches
Date: Thu, 15 Jan 2009 14:06:55 +1000
Message-ID: <496EB65F.2060704@snapgear.com>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:47335 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755014AbZAOEHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:07:01 -0500
In-Reply-To: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sacha,

Sascha Hauer wrote:
> The following patches apply to the FEC driver (drivers/net/fec.c). While
> found on several Freescale/Motorola chips, this driver is currently only
> used for Coldfire. These patches add support for the ARM based i.MX27
> SoC.
> 
> I'm almost sure I break the driver for some (all?) Coldfire guys, but I
> do not have any Coldfire based board to test the patches on.

I can test patches on most ColdFire boards.


> The first 4 patches should be ok as is, comments?

Only the one that I commented on with FEC_FLASHMAC.
Otherwise the first 4 apply and work for ColdFire.


> The other patches are somewhat work in progress, but they show which
> changes I need for my hardware.

Currently the change to use dma_alloc_coherent breaks ColdFire.
I need to debug that and see why that is the case.

Otherwise they look ok to me.


> The driver could use quite some cleanup patches for coding style, turn
> it into a platform device driver and add exit functions. I'm sure I

Yes, it does badly need this. I have been meaning to extract
the ColdFire platform specifics for some time. That would improve
it quite a bit.

Regards
Greg



> could find some time to work on these topics, but first I need the
> patches to support my board to be able to test my changes.
 >
> Any comments welcome
> 
> Sascha
> 
> PS Greg, Sebastian: I'm sending this again because I got the list
> address wrong. I put you on cc because you were the last persons
> committing patches to this driver
> 
> 
> 

-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
