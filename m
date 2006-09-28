From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 11:04:10 +1000
Message-ID: <1159405450.9974.8.camel@localhost.localdomain>
References: <200609271726.34305.mb@bu3sch.de>
	 <451AA446.7060009@lwfinger.net> <200609271950.47430.mb@bu3sch.de>
	 <1159395803.18293.72.camel@localhost.localdomain>
	 <451B1AB0.9020302@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	Christian <email@christianhoffmann.info>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:12206 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S964980AbWI1BJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 21:09:06 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <451B1AB0.9020302@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 19:43 -0500, Larry Finger wrote:
> Benjamin Herrenschmidt wrote:
> >> 
> > I won't try some random other git tree to test things, it's simply not
> > feasible for me and we need something we can give to distros to backport
> > so they have something remotely stable (I'm thinking for example about
> > the upcoming ubuntu edgy which is coming out soon an a 2.6.17 base).
> 
> I don't know what your problem is! Despite your negative attitude, I have tried to accommodate you, 
> but obviously you do not appreciate my efforts. My big patch for 2.6.18 concentrated on bcm43xx. Yes 
> there were changes in softmac, but they had no major effect until Michael's fix of the race condition.
> 
> The bottom line is that I have had it with you! You had best go back to some mainline kernel as you 
> will get no further help from me. There are lots of folks that need help _AND_ are appreciative of 
> that help. My time will be spent on them.

Maybe because I'm a hot blooded asshole :)

Note that I wasn't complaining about your patch (which is a bit huge tho
for a stable release, but it did make a difference here along with
Michael debug one). I just noticed that none of Michael last "final"
patches would apply on 2.6.18 + your patch, and went into my usual rant
in case they were supposed to apply to the wireless tree.

There is a number of reasons why people can't just use a wireless-git or
whatever else tree, and having something against mainline is the only
way I see to get something to distros now, which is the way to fix the
most people problems rather than only the ones finding this mailing
list.

Ben.


