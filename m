From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 07:28:16 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610072444.Q37105@shell.cyberus.ca>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092200150.28167@ns.istop.com> <20030610043453.GC23009@netnation.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ralph+d@istop.com, "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030610043453.GC23009@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 9 Jun 2003, Simon Kirby wrote:

> I was going to ask before, and it's probably not even possible anymore,
> but have you tried on a 2.0 kernel before?  2.0 kernels probably have a
> lot of other problems and don't support the new hardware, but it would be
> interesting to see how it scales to many srcs/dsts before the route cache
> was integrated.  It probably scales a lot more like FreeBSD does.  You'd
> probably have to use eepro100s or something, though.
>

As a side note, note that stateless forwarding like BSD patricie tries
is no longer sufficient. Its no longer just looking up a nexthop, dec ttl,
recompute csum that we are optimizing for.
The dst cache/flowi is the way to go, so theres no going back;-> - we just
gotta make what we have work better.

cheers,
jamal
