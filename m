From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 00/04] smc91x: request bus width using platform data
Date: Wed, 20 Feb 2008 10:36:57 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802201028570.2732@xanadu.home>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:21730 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933268AbYBTPg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:36:59 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWJ0092SNDLG070@VL-MO-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 20 Feb 2008 10:36:58 -0500 (EST)
In-reply-to: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008, Magnus Damm wrote:

> These patches make it possible to request bus width in the platform data.
> 
> Instead of keep on updating smc91x.h with board specific configuration,
> use platform data to pass along bus width and irq flags to the driver.
> This change is designed to be backwards-compatible, so all boards configured
> in the header file should just work as usual.

Thank you for doing this work.  I really meant to do it, and commit 
09779c6df2dbe95483269d194b327d41fe2cc57e was the first step towards that 
goal, but as you can see we're nearly two years later and I didn't do 
it.

I have a few comments though.  I will reply to those messages 
separately.


Nicolas
