From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Wed, 21 May 2003 08:39:27 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521075617.N43477@shell.cyberus.ca>
References: <1053313298.3909.5.camel@rth.ninka.net>  <20030519202756.I39498@shell.cyberus.ca>
 <3EC9B815.4000504@ethanet.com>  <20030520080940.E40885@shell.cyberus.ca>
 <3ECA3E2C.20805@ethanet.com>  <20030520105356.U41173@shell.cyberus.ca>
 <1053443703.17386.138.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ethan Sommer <sommere@ethanet.com>, "David S. Miller" <davem@redhat.com>,
   linux-net@vger.kernel.org, netdev@oss.sgi.com, biondi@cartel-securite.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1053443703.17386.138.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 20 May 2003, Martin Josefsson wrote:

> Maybe make it take a length parameter and if it's zero treat null's like
> all other algorithms do and it's non-zero use the length instead.
> Then you can hide it in a wrapper function for the "normal" case that
> just calls the actual search-function but with 0 as length.
>

Actually, the library that you pointed to seems to have callbacks
associated with every match - so it could be used on string matches.
The author is on the cc.

> Well we don't have a that big bread slicer (yet) but take a look at
> libqsearch, it is a library for searching and has been ported to the
> linux kernel by the author. It has support for various algorithms that

Didnt see anything kernel related in my quick scan.
The library certainly appears sane.

> have diffrent capabilities, unfortunately I don't think it has an
> algorithm that has support for regexp yet (the framework is there, ie
> the flag that says an algorithm supports regexp).
> It's modular and I don't think it should be that hard to add an regexp
> algorithm.

it does seems to imply regexp is available but wasnt anywhere i could
find.

> It looks quite nice and it can search for multiple strings at the same
> time and call diffrent callbacks depending on which string matched.
>

yep, can sed that packet easily with those callbacks ;-> s/val/val2/g

On Tue, 20 May 2003, Ethan Sommer wrote:

> One thing I should have pointed out earlier, it only copies that
> memory/does regex stuff until it finds a match or the first 8 packets,
> whichever is less. So, at least based on my tests, it doesn't seem to
> slow down 100BT much from what it would be otherwise. We might run into
> trouble if we look at GB or 10GB, but until we find a problem with
> speed, I think it is probably more important to make this as simple and
> easy to maintain as possible. If we see a need to make it more
> complicated due to speed issues, _then_ we should think about trying to
> get rid of that copy.
>

I think you should do some measurements - "it  doesnt slow 100Mbps" and
"lets worry about it when we get to 1 or 10Gbps" are handwaving at best.
Infact i would strongly recommend looking at the libqpsearch above.

cheers,
jamal
