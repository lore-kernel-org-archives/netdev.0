From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10682] New: (net 8139too) dual ethernet
 system, any reasonable network causes: NETDEV WATCHDOG: ethN: transmit
 timed out
Date: Mon, 12 May 2008 15:11:42 -0700
Message-ID: <20080512151142.067b98d2.akpm@linux-foundation.org>
References: <bug-10682-10286@http.bugzilla.kernel.org/>
	<20080511211055.af2595e9.akpm@linux-foundation.org>
	<20080512214014.GB27236@ebb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: "Bradley M. Kuhn" <bkuhn@ebb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60487 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754156AbYELWLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 18:11:46 -0400
In-Reply-To: <20080512214014.GB27236@ebb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2008 17:40:14 -0400
"Bradley M. Kuhn" <bkuhn@ebb.org> wrote:

> Andrew, thanks so much for your quick reply!
> 
> I reported this bug:
> > > http://bugzilla.kernel.org/show_bug.cgi?id=10682
> > >
> > >            Summary: (net 8139too) dual ethernet system, any reasonable
> > >                     network causes: NETDEV WATCHDOG: ethN: transmit timed
> > >                     out
> > >            Product: Drivers
> > >            Version: 2.5
> > >      KernelVersion: 2.6.25.3
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >          Component: Network
> > >         AssignedTo: jgarzik@pobox.com
> > >         ReportedBy: bkuhn@ebb.org
> 
> Andrew Morton replied:
> 
> > I really dont' know where to begin with this, sorry.  It's _probably_
> > some platform-related IRQ delivery problem.  But then again it might be
> > something else :(
> 
> I understand.  FWIW, I tried every BIOS change imaginable to make sure it
> wasn't some weird BIOS interaction.
> 
> > It would certainly be valuable to try some older kernels.
> 
> What are you suggestions regarding "how old"?  My plan *was* to install a
> 2.4 based distribution next, but if there are specific 2.6.x versions you
> think are worth trying, I'm happy to give a try.  I'd rather try the
> 2.6.x's you suggest first, of course.

I think an early 2.6 would be a good place to start - 2.6.5. 2.6.9, etc.

If that doesn't help then we can probably safely assume that it's
always been busted.  If that kernel works OK then we can drill in more
cloesly, if you're so inclined (which we hope you are ;))
