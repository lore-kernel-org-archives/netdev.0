From: Jaroslav Kysela <perex@suse.cz>
Subject: Re: [patch 5/7] bonding: replace system timer with work queue
Date: Tue, 27 Mar 2007 08:36:03 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0703270833330.7910@tm8103-a.perex-int.cz>
References: <200703270550.l2R5o16M008387@shell0.pdx.osdl.net>
 <20070326215648.58cb392b.akpm@linux-foundation.org> <25159.1174976707@death>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, oleg@tv-sign.ru,
	shemminger@linux-foundation.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.perex.cz ([212.20.107.53]:49978 "EHLO mail1.perex.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965271AbXC0HEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 03:04:13 -0400
In-Reply-To: <25159.1174976707@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Mar 2007, Jay Vosburgh wrote:

> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> >On Mon, 26 Mar 2007 21:50:01 -0800 akpm@linux-foundation.org wrote:
> >
> >> Replace system timer with work queue in monitor functions.  The reason for
> >> this change is that bonding handlers calls various sleeping functions from
> >> the timer handler which is not allowed.  Because we cannot share the main
> >> workqueue threads (rtnl_lock is used also in linkwatch_event) - new bond
> >> workqueue thread is created.
> >
> >I have a note here that this patch needs additional work.
> >
> >I forget what it was, there has since been no followup and hence I shall now
> >drop this patch.
> 
> 	Andy Gospodarek <andy@greyhouse.net> and I have been working off
> list to come up with a comprehensive scheme to resolve the various
> locking problems in bonding all at once, rather than piecemeal.
> Currently, we believe we've identified all of the problem areas, have
> worked up a set of locking rules, and are now hashing out an
> implementation that (hopefully) doesn't suck.
> 
> 	The patch referenced above is more or less a functional subset
> of the work we're doing, in that we'll also be moving the timers to
> workqueues.

When do you expect to finish your work? I think that common rule is to 
have at least some code to fix the problem rather than none.

						Jaroslav

-----
Jaroslav Kysela <perex@suse.cz>
Linux Kernel Sound Maintainer
ALSA Project, SUSE Labs
