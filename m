From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Real World Traffic WAS(Re: Route cache performance tests (fwd)
Date: Wed, 11 Jun 2003 08:09:52 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611080924.D39831@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think is interesting enough for general consumption

---------- Forwarded message ----------
Date: Wed, 11 Jun 2003 07:38:41 -0400 (EDT)
From: Jamal Hadi <hadi@shell.cyberus.ca>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: Pekka Savola <pekkas@netcore.fi>, ralph+d@istop.com,
     Simon Kirby <sim@netnation.com>, CIT/Paul <xerox@foonet.net>,
     'David S. Miller' <davem@redhat.com>
Subject: Real World Traffic WAS(Re: Route cache performance tests



Ok time to start changing topics; this thread is already over two
hundred emails ;->

On Tue, 10 Jun 2003, Florian Weimer wrote:

> Pekka Savola <pekkas@netcore.fi> writes:
>
> > I really hope you're kidding about Sprint core routers.
>
> Some of the IP carriers have far too little traffic in their backbone,
> to a degree that it's an economic disaster.  You need some spare
> capacity in order to deal with some aspects of IP traffic, but not a
> factor of 10 or something similar.
>

I think this is what might be happening at those sprint routers.
Note that though the pps is low the flows per secs is very high.

Look at the info on nyc-21:
The 95th percentile of traffic is around 63Kpps.
Then look at the 95th percentile for number of flows: 72K flows

this implies that each flow is getting to send less than 1pps.

I think the number of flows is also interesting. May help in formulizing
the garbage collection.
376K flows(flowi/dst cache) stored at the worst case. In the worst case
88K flows are active every second.

Pekka, do you have similar data you collect as well?

> I once asked a networking engineer at another rather large NSP to do
> some DoS backtracking for me.  The network apparently used GSRs
> throughout its core.  Unfortunately, GSRs are very shy in the standard
> configuration and they won't reveal much data about the traffic they
> are routing.  So this guy issued "ip route-cache flow" on the
> interface on which the traffic was leaving his AS.  It took him over
> an hour to get that line card up again.  Ouch.  The funny thing is,
> however, that the engineer insisted that this had always worked for
> him on all other routers.  ("ip route-cache flow" turns on flow-based
> process switching, and the line card CPU and its buses are certainly
> not powerful enough for that!  If it causes no problems, you could
> certainly use a 72xx or 75xx, maybe even a PC running Linux 8-) to
> route that traffic.)

isnt that equivalent to what we do with route caching?

cheers,
jamal
