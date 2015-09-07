From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH 0/3] net: irda: pxaficp_ir: dmaengine conversion
Date: Mon, 7 Sep 2015 06:16:46 +0200
Message-ID: <55ED0FAE.6000802@tul.cz>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bubo.tul.cz ([147.230.16.1]:37143 "EHLO bubo.tul.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029AbbIGEMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 00:12:35 -0400
In-Reply-To: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 3.9.2015 v 08:20 Robert Jarzmik napsal(a):
> Hi,
> 
> This serie aims at converting pxaficp_ir to dmaengine. This is almost the last
> driver to be converted, and once this is gone, legacy DMA support in pxa
> architecture can be gone.
> 
> Nothing fancy here, standard readl/writel conversion, then dmaengine support.
> 
> The main trouble is that I cannot test it, I only compiled and inserted the
> module, which works on lubbock, but I have no way to make a communcation try.
> 
> Petr, Dmitry, once the review is advanced enough, ie. in a couple of weeks, do
> you have a way to test it on corgi/magician if I give you a git tree to pull
> from ?
> 
> Cheers
> 
> --
> Robert
> 
> Robert Jarzmik (3):
>   net: irda: pxaficp_ir: use sched_clock() for time management
>   net: irda: pxaficp_ir: convert to readl and writel
>   net: irda: pxaficp_ir: dmaengine conversion
> 
>  drivers/net/irda/pxaficp_ir.c | 366 +++++++++++++++++++++++++++---------------
>  1 file changed, 233 insertions(+), 133 deletions(-)
> 

Hi,
I will test it this week.

OT: (hw verified) Magician sadly does not support FIR (only SIR transceiver module) :-( .

Petr
