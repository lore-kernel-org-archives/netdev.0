From: jamal <hadi@cyberus.ca>
Subject: Re: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 22:50:59 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0206192242200.28882-100000@shell.cyberus.ca>
References: <Mutt.LNX.4.44.0206201238360.32372-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, Chris Friesen <cfriesen@nortelnetworks.com>,
   Donald Becker <becker@scyld.com>, <netdev@oss.sgi.com>,
   Stefan Rompf <srompf@isg.de>
Return-path: <owner-netdev@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0206201238360.32372-100000@blackbird.intercode.com.au>
List-Id: netdev.vger.kernel.org



Before someone reinvents the wheel, did anyone actually bother following
the discussion that happened here on netdev:
http://marc.theaimsgroup.com/?t=101751064400001&r=1&w=2

If Stefan Rompf hasnt disapeared or is buried in work somewhere,
all pieces are already in place. thats what the device netcarrier state
is for.

cheers,
jamal

On Thu, 20 Jun 2002, James Morris wrote:

> On Wed, 19 Jun 2002, Andi Kleen wrote:
>
> > On Wed, Jun 19, 2002 at 05:44:05PM -0400, Chris Friesen wrote:
> > > Andi Kleen wrote:
> > >
> > > > I would suggest sending a netlink message from the driver.  That's really
> > > > what netlink was designed for.
> > >
> > > Can you point me to a driver that's done this cleanly as an example to follow?
> >
> > Not exactly a driver, but you can e.g. look at the ip_queue netfilter
> > module.
> >
>
> It's not a very clean example at this stage, unfortunately, as it contains
> some fairly ugly logic for maintaining unicast sessions.
>
> If you don't specifically need unicast Netlink (which I don't think you
> do), try also looking at the tcpdiag & ctnetlink code.
>
>
> - James
> --
> James Morris
> <jmorris@intercode.com.au>
>
>
