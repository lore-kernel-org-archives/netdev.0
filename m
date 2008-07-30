From: Dan Williams <dcbw@redhat.com>
Subject: Re: NETDEV WATCHDOG: wifi0: transmit timed out
Date: Wed, 30 Jul 2008 07:41:30 -0400
Message-ID: <1217418091.11432.24.camel@localhost.localdomain>
References: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
	 <20080729215315.5a505fe7.komurojun-mbn@nifty.com>
	 <20080729065859.2bcc65ed@infradead.org>
	 <20080729.134706.249036102.davem@davemloft.net>
	 <dd18b0c30807291548u285bb00eqd376e0e96cede86c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arjan@infradead.org,
	komurojun-mbn@nifty.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Justin Mattock <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756AbYG3LoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 07:44:13 -0400
In-Reply-To: <dd18b0c30807291548u285bb00eqd376e0e96cede86c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-29 at 15:48 -0700, Justin Mattock wrote:
> On Tue, Jul 29, 2008 at 1:47 PM, David Miller <davem@davemloft.net> wrote:
> > From: Arjan van de Ven <arjan@infradead.org>
> > Date: Tue, 29 Jul 2008 06:58:59 -0700
> >
> >> On Tue, 29 Jul 2008 21:53:15 +0900
> >> Komuro <komurojun-mbn@nifty.com> wrote:
> >>
> >> > Hi,
> >> >
> >> > Please try to comment out the "WARN_ON_ONCE"
> >> > at net/sched/sched_generic.c.
> >> >
> >>
> >> "I have a hardware failure so I'll comment out the message that says
> >> so, and then I won't have a failure". Yeah that'll work well.
> >
> > Yes, this is indeed a recidulious suggestion, to hide the problem
> > instead of trying to figure out what it might actually be.
> >
> > Komuro has a serious problem accepting the fact that this condition is
> > in fact an abnormal error should should be logged, and he keeps
> > pushing to get this WARN_ON() removed over and over again.
> >
> > I'm just ignoring him at this point.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >
> 
> I should of mentioned the madwifi module I've been
> using is from february, so maybe madwifi took care of this already.
> As for experimanting with ath9k I pulled yesterday and compiled,
> but from what I saw ath9k seems to not handle wpa keys that well.
> so back to madwifi until later on.

ath9k certainly should handle WPA keys; the hardware and driver really
don't care what the key type is because all that is taken care of by
mac80211.  What specific issues were you having with ath9k?  There's
some generic mac80211 breakage going on right now while people figure
out how to fix the skb->cb situation that Dave's multiqueue stuff
exposed, which might be screwing up ath9k for you.

Dan


