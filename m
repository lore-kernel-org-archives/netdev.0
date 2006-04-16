From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: softmac: semantics of SIOCSIWFREQ
Date: Sun, 16 Apr 2006 19:17:50 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0604161913250.22040@p15091797.pureserver.info>
References: <1145190888.6560.22.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, softmac-dev@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:60347 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750762AbWDPRUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 13:20:32 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145190888.6560.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 16 Apr 2006, Johannes Berg wrote:

> > - If the flag IW_FREQ_FIXED is set, should all activitity
> >   including scanning only be allowed on this frequency? (Actually
> >   a better would even be to work with channel/frequency sets.
> >   These sets would make a lot of sense for parallel scanning
> >   whith more than one device.)
> 
> Yeah, but that's impossible to code on top of the current wext
> structures I'd say.

I could be done via an iwpriv. Actually the Personal Telco people,
would like to use WLAN devices in parallel to do WAR driving. At
least I would like to support the fixed channel semantics.

> > SIOCSIWFREQ and SIOCGIWFREQ appear to be good candidates to be
> > included in the softmac. If I would have a rough idea, what the
> > semantics should be, I would even volunteer to implement it.
> 
> I was thinking of adding all the 'what is this ioctl supposed to do'
> things we came up with to the softmac or netdev wiki. Would that be
> good/useful, or should we just put it into that driver writers guide?

Regarding the wireless extension ioctls, I think the best would be
to add kerneldoc comments.

Uli

-- 
Ulrich Kunitz - kune@deine-taler.de
