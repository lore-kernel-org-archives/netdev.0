From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH] SMC91x: don't flag spurious interrupts when polling
Date: Thu, 24 Jan 2008 21:23:30 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0801242121070.22568@xanadu.home>
References: <1201227343-10853-1-git-send-email-khilman@mvista.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Kevin Hilman <khilman@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:15431 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbYAYCXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 21:23:33 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JV60049ZHB68KA0@VL-MH-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 24 Jan 2008 21:23:30 -0500 (EST)
In-reply-to: <1201227343-10853-1-git-send-email-khilman@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jan 2008, Kevin Hilman wrote:

> When using polling, smc_poll_controller() can call smc_interrupt()
> when there are likely to be no real interrups.  This will trigger the
> "spurious interrupt" printk whenever the driver is being polled.
> 
> This adds an 'is_polling' flags, and doesn't trigger the spurious
> warning when in polling mode.
> 
> Signed-off-by: Kevin Hilman <khilman@mvista.com>
> Signed-off-by: Nicolas Pitre <nico@cam.org>

NAK

Kevin: you sent the wrong patch !


Nicolas
