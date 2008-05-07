From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Remove cli()/sti() calls from HYSDN driver.
Date: Wed, 7 May 2008 10:05:17 -0700
Message-ID: <20080507100517.c51cbda6.akpm@linux-foundation.org>
References: <1209673012-10500-1-git-send-email-mark.asselstine@windriver.com>
	<20080502131529.GA12635@pingi.kke.suse.de>
	<200805071225.23643.Mark.Asselstine@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <kkeil@suse.de>, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
To: "M. Asselstine" <Mark.Asselstine@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53333 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753197AbYEGRFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 13:05:23 -0400
In-Reply-To: <200805071225.23643.Mark.Asselstine@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 May 2008 12:25:23 -0400 "M. Asselstine" <Mark.Asselstine@windriver.com> wrote:

> On Friday 02 May 2008, Karsten Keil wrote:
> > On Thu, May 01, 2008 at 04:16:52PM -0400, Mark Asselstine wrote:
> > > >From looking at this driver the use of cli()/sti() within the do/while
> > >
> > > was a way to ensure interrupts were only disabled for short periods of
> > > time while the bulk of the time interrupts were free to occur. The
> > > use of the spin lock has eliminated the need to play with interrupts
> > > in this way while still allowing for IO to be protected.
> > >
> > > The remaining 3 sti() calls seem unneeded now that at no other point
> > > in the driver is there a call to cli().
> > >
> > > Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
> >
> >   Acked-by: Karsten Keil <kkeil@suse.de>
> >
> Andrew, 
> 
> Would it be possible to include this commit in your tree. It is the last of 
> the cli()/sti() calls and I would love to get his work completed.

Sure, I'll take a look at it.

> The patch 
> has been vetted in kernel-janitors and netdev but no one has picked it up 
> yet. unfortunately.

I don't troll netdev for unloved patches.  A Cc:linux-kernel is often a
good idea...

