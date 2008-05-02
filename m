From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] via-rhine: suspend/resume bugfix
Date: Fri, 2 May 2008 22:32:46 +0200
Message-ID: <20080503002655.GA3956@ucw.cz>
References: <20080427071351.GA20561@localhost.localdomain> <4814406B.8000907@gmail.com> <20080427095843.GA28784@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jirislaby@gmail.com>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rl@hellgate.ch
To: Ondrej Zajicek <santiago@crfreenet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.31.123]:46368 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765928AbYEBUdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:33:05 -0400
Content-Disposition: inline
In-Reply-To: <20080427095843.GA28784@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun 2008-04-27 11:58:44, Ondrej Zajicek wrote:
> On Sun, Apr 27, 2008 at 10:59:23AM +0200, Jiri Slaby wrote:
> > >+	/* Disable interrupts by clearing the interrupt mask. */
> > >+	iowrite16(0x0000, ioaddr + IntrEnable);
> > >+
> > >+	/* Stop the chip's Tx and Rx processes. */
> > >+	iowrite16(CmdStop, ioaddr + ChipCmd);
> 
> > What about PCI posting?
> 
> Hmm, i will fix it. And i found that the patch might break
> wakeup-on-LAN. So please discard it.

IRQ line should not be neccessary for WoL...?

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
