From: Andi Kleen <ak@muc.de>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 06 Mar 2005 21:19:25 +0100
Message-ID: <m1y8d0mss2.fsf@muc.de>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	<E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	<E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	<E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	<20050306173145.GQ31837@postel.suug.ch>
	<E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> (Zdenek Radouch's
 message of "Sun, 06 Mar 2005 14:48:31 -0500")
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zdenek Radouch <zdenek@rcn.com> writes:

> OK, I think I am getting the picture.
>
> 1) looks like what I need may be possible, at least as far as
>     some kernels are concerned.  It's not clear that 2.4.25 will work.
>
> 2) I only have to perform close to magic in locating the "right"
>     tools that happen to work on a "right" kernel release.

iproute2 has been the tool of choice since Linux 2.2.

ifconfig/route and the old ioctl interface have been only
there for compatibility and show only a small subset of 
the full functionality.

That has been true for many many years.

>
> 3) Clearly the route processing is in flux, at least within the
>     releases I am dealing with, so I need to be careful interpreting
>     what I see, and I should avoid making any inferences.

I don't think that's true. Routing hasn't changed much for a long time.

>
> There is no doubt that the 127.x net is treated in a special
> way.  If I have to believe what I just learned, then the 127

It is. 127.* is hardcoded in the routing engine and e.g.
it won't accept outside packets with a loopback address.

Most likely it's enough to change the "LOOPBACK" macro to allow
parts of the Class A to be used for other purposes.


-Andi 
