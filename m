From: jamal <hadi@cyberus.ca>
Subject: Re: TODO list before feature freeze
Date: Tue, 30 Jul 2002 07:58:42 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207300750240.15727-100000@shell.cyberus.ca>
References: <20020729182659.D570@oknodo.bof.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, Rusty Russell <rusty@rustcorp.com.au>,
   <netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>,
   <netfilter-core@lists.netfilter.org>
Return-path: <owner-netdev@oss.sgi.com>
To: Patrick Schaaf <bof@bof.de>
In-Reply-To: <20020729182659.D570@oknodo.bof.de>
List-Id: netdev.vger.kernel.org



On Mon, 29 Jul 2002, Patrick Schaaf wrote:

> Jamal,
>
> > They also have a lot of problems with their per-packet computations.
> > Robert and I spent a short time looking at "this thing that is making
> > us look bad" (perfomance wise) and talked to Harald.
>
> Do you have written up somewhere what kind of performance problems you were
> seeing, under which conditions (hash bucket count, number of tracked
> connections, packet load)
>

Just standard setup in forwarding. Infact you only need one or two flows
active to verify this -- which leads me to believe hashing may play a
smaller role in the whole problem.
What i have seen and reported by many people (someone seems to have gone
one step further and documented numbers, but cant find his email right
now). Take Linux as a router, it routes at x% of wire rate. Load
conntracking and watch it go down another 25% at least.

> > Something that looked like needs improvement at first glance was the aging
> > and hashing schemes.
>
> Regarding the hashing schemes, please see discussions on netfilter-devel
> over the last weeks:
>

I think hashing is one of the problems. What performance improvemet are
you seeing? (couldnt tell from looking at your data)

cheers,
jamal
