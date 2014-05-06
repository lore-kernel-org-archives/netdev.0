From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 21:14:47 +0200
Message-ID: <20140506191447.GB4137@netboy>
References: <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: josh@joshtriplett.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:32990 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbaEFTO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 15:14:59 -0400
Content-Disposition: inline
In-Reply-To: <20140506164108.GA20536@cloud>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 09:41:08AM -0700, josh@joshtriplett.org wrote:
> On Tue, May 06, 2014 at 11:59:41AM -0400, David Miller wrote:
> > Making 2MB RAM machines today makes no sense at all.

Besides cost, one of the main reasons for designing tiny systems today
is battery life. Some devices cannot be recharged every week, like
your smart phone must.

> > The lowest end dirt cheap smartphone, something which fits on
> > someone's pocket, has gigabytes of ram.

Right, these low end smart phones are nicer than the DEC Alpha work
stations we had at university. I would not call them "small" embedded
systems.

> Every KB of RAM costs real money and SoC die area (for eDRAM/eSRAM).
> Look at how much cache low-end processors have, and imagine running
> entirely out of *that*.  Let's not surrender that entire class of
> devices to VxWorks, FreeRTOS, and other painfully non-Linux systems,
> when we already know it's possible to run Linux on them successfully.

I have also been working on tiny system recently (and hope to get out
of it soon ;). This whole IoT trend might just go away, I sure hope it
does, but in general there is a growing need for tiny systems with
excellent networking.

Davem's attitude is understandable, and Linux should not be expected
to fit into every last micro controller, but still I observe the kernel
getting ever bigger, even in the most basic configurations. I don't
think there is valid technical reason for bloat, but rather it is an
issue that doesn't affect too many people.

In any case I would really like to see the possibility of leaving
pieces out for these tiny systems, but it would be a balancing act.
On the one hand, we want the stable/powerful/wonderful Linux stack in
our tiny systems. On the other hand, if we rip everything out to make
it fit, then it is no longer the same thing. So I think Dave is right
in rejecting anything that compromises the _quality_ of the stack.

Off on a tangent:

Regarding the multiplicity of RTOSs out there, all I can say is, they
all suck, especially the ones you pay money for. It would be great to
have a small Linux like OS for micro controllers and tiny micro
processors. I have looked and looked for an open source, posix like
alternative, but all I found was Nuttx, ActionOS, and RTEMS. I looked
closely at the first two, and putting aside technical issues, neither
seems to have any steam in terms of active development. RTEMS says it
has a BSD stack, and it seems to have a respectable development
effort, but I did not look too closely at it.

There is a huge area out there (think of all the Cortex M3) that needs
a real networking stack, but I don't see much hope. Minimizing Linux
is a big PITA (tons of work), and building a suitably small OS from
scratch is hopeless. As was said, it is easier just to buy a bigger
memory. The people who can't or won't (who are also building the IoT)
will just throw in some lwIP or uIP. You can imagine how secure these
systems will be.

Thanks,
Richard
