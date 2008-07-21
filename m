From: David Miller <davem@davemloft.net>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 13:20:17 -0700 (PDT)
Message-ID: <20080721.132017.209065925.davem@davemloft.net>
References: <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>
	<20080721.120052.123606398.davem@davemloft.net>
	<20080721194414.GA4872@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32853
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751554AbYGUUUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:20:17 -0400
In-Reply-To: <20080721194414.GA4872@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jul 2008 21:44:14 +0200

> 
> * David Miller <davem@davemloft.net> wrote:
> 
> > From: Linus Torvalds <torvalds@linux-foundation.org>
> > Date: Mon, 21 Jul 2008 11:35:21 -0700 (PDT)
> > 
> > > Maybe the network drivers are few enough that it will get fixed, or
> > > maybe the WARN_ON_ONCE() will just be removed and the rule not
> > > reinforced.
> > > 
> > > I personally suspect the latter, since it seems to happen with just
> > > about _any_ random network driver, including the common and
> > > well-maintained ones (ie the Gods only help us for the truly
> > > odd/random cases)
> > 
> > Yes, we'll see how this plays out.
> > 
> > Ian Schram just posted a patch for the NULL pointer derfer in wireless 
> > Ingo reported, so we'll see if that bug will be fixed now as well.
> 
> Yes, the fix from Ian below solved the CONFIG_MAC80211_HWSIM=y crash i 
> was getting. I have no other pending issues other than a few low-prio 
> ne2000 build failures.
> 
> Thanks guys,

Thanks everyone, applied.
