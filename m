From: Arno Wagner <arno@wagner.name>
Subject: Re: Fw: [Bug 65261] New: Packet loss or excessive packet delay
 repeatedly for some seconds
Date: Sat, 23 Nov 2013 13:11:40 +0100
Message-ID: <20131123121140.GB28775@tansi.org>
References: <20131120122316.77ce76c5@nehalam.linuxnetplumber.net>
 <20131123043359.GC15822@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km31936-01.keymachine.de ([87.118.116.4]:40134 "EHLO
	v6.tansi.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab3KWMSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Nov 2013 07:18:52 -0500
Content-Disposition: inline
In-Reply-To: <20131123043359.GC15822@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 23, 2013 at 05:33:59 CET, Hannes Frederic Sowa wrote:
> On Wed, Nov 20, 2013 at 12:23:16PM -0800, Stephen Hemminger wrote:
> > 
> > 
> > Begin forwarded message:
> > 
> > Date: Wed, 20 Nov 2013 05:57:59 -0800
> > From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> > To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> > Subject: [Bug 65261] New: Packet loss or excessive packet delay repeatedly for some seconds
> > 
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=65261
> > 
> >             Bug ID: 65261
> >            Summary: Packet loss or excessive packet delay repeatedly for
> >                     some seconds
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 3.10.19
> >           Hardware: x86-64
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: IPV4
> >           Assignee: shemminger@linux-foundation.org
> >           Reporter: arno@wagner.name
> >         Regression: No
> > 
> > Created attachment 115261
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=115261&action=edit
> > Kernel config 3.10.19
> > 
> > I recently upgraded my development-server/firewall/NAT-box from 3.10.17 to
> > 3.10.19. Since then I noticed increased DNS lookup failures on a connected
> > Windows box and occasional slow updates on putty-SSH logins when scrolling in
> > an editor (joe, takes something like an estimated 100-300ms for screen
> > updates). These update delays are repeatable for something like 10-20 seconds
> > or more, e.g. inserting a line and then deleting again, then vanish. The delays
> > make remote editing hard to do when they happen. The DNS lookup failures are
> > really annoying. 
> > 
> > I have not found a way to reliably trigger the problem.
> > 
> > Going back to 3.10.17 fixed the issue as far as I can tell. (Several hours
> > editing source code without it showing up.) The only change between the two
> > configurations was that I added the scsi CDROM driver (which should not be able
> > to cause this?).
> > 
> > The network connection has an iptables "all pass" on the server side for the
> > affected connection. The client side is a Win7 machine. The network link is GbE
> > with 2 Switches in there. No packet loss on ping/ping -f. Network hardware is 
> > Intel 82574L Gigabit card on both sides.
> 
> Could you try dropwatch while the packet drops are happening?
> Often it is helpful to check ip monitor all if events happen during bursty
> losses.

Sorry, but dropwatch is not in Debian and compiling it from sources
seem to require something called "rpmbuild". Hence I cannot use
it or at least would have to write my own Makefile for it. 

Arno

-- 
Arno Wagner,     Dr. sc. techn., Dipl. Inform.,    Email: arno@wagner.name
GnuPG: ID: CB5D9718  FP: 12D6 C03B 1B30 33BB 13CF  B774 E35C 5FA1 CB5D 9718
----
There are two ways of constructing a software design: One way is to make it
so simple that there are obviously no deficiencies, and the other way is to
make it so complicated that there are no obvious deficiencies. The first
method is far more difficult.  --Tony Hoare
