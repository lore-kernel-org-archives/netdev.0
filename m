From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused
 by netem)
Date: Thu, 9 Jul 2009 19:44:33 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0907091943290.2768@localhost.localdomain>
References: <200907031326.21822.andres@anarazel.de> <200907091728.23367.andres@anarazel.de> <alpine.LFD.2.00.0907091801130.24704@localhost.localdomain> <200907091846.37926.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:52597 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbZGIRow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 13:44:52 -0400
In-Reply-To: <200907091846.37926.andres@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andres,

On Thu, 9 Jul 2009, Andres Freund wrote:

> On Thursday 09 July 2009 18:01:56 Thomas Gleixner wrote:
> > Andres,
> >
> > On Thu, 9 Jul 2009, Andres Freund wrote:
> > > On Thursday 09 July 2009 16:28:05 Thomas Gleixner wrote:
> > > > Please test them separate from each other. The one I sent in this
> > > > thread was just for narrowing down the issue, but I'm now quite sure
> > > > that they really hit the issue which is addressed by the hrtimer
> > > > patch.
> > >
> > > No crash yet. 15min running (seconds to a minute before).
> > >
> > > Will let it run for some hours to be sure.
> >
> > Which one of the patches are you testing ?
> Your "real" one, i.e. de907e8432b08f2d5966c36e0747e97c0e596810
> 
> 1h30m now...

Looks like I hit the nail on the head. Queueing it up for Linus.

Thanks,

	tglx
