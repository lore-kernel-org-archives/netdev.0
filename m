From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 20/21] forcedeth: fix locking bug with netconsole
Date: Sat, 29 Mar 2008 00:46:28 +0100
Message-ID: <20080328234628.GA8459@elte.hu>
References: <200803282141.m2SLfUwU011858@imap1.linux-foundation.org> <20080328.154353.43255092.davem@davemloft.net> <47ED75CE.1080400@garzik.org> <20080328164209.e8b723d8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, aabdulla@nvidia.com,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758147AbYC1XrR@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080328164209.e8b723d8.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > > Please do not mix device driver changes with core networking 
> > > changes.
> > 
> > FWIW my plan was to snip the net/* stuff and only apply the 
> > forcedeth portion.
> > 
> > (leaving <whomever> to pick up the pieces, should they so desire)
> > 
> 
> Just drop 'em completely I'd say.

you mean the netpoll.c bits? sure.

> otoh, drivers do seem a bit flakey in the netpoll-support area, so a 
> bit of extra debug wouldn't hurt.  But checking irqs_disabled() either 
> side of a udelay() was a bit paranoid ;)

yeah. i completely forgot about those bits. But lets make sure the 
forcedeth.c fix gets into .25 - it's obvious and it fixes a nasty bug. 
Without that fix netconsole is unusable on forcedeth.

	Ingo
