From: alex@pilosoft.com
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 6 Mar 2005 15:19:11 -0500 (EST)
Message-ID: <Pine.LNX.4.44.0503061515520.12011-100000@bawx.pilosoft.com>
References: <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-net@vger.kernel.org>
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 6 Mar 2005, Zdenek Radouch wrote:

> 
> 1) looks like what I need may be possible, at least as far as
>     some kernels are concerned.  It's not clear that 2.4.25 will work.
It is clear it will.

> 2) I only have to perform close to magic in locating the "right"
>     tools that happen to work on a "right" kernel release.
Not really. Recent (as in, in past 3 years) tools and recent (as in, in 
past 3 years) kernel.
> 
> 3) Clearly the route processing is in flux, at least within the
>     releases I am dealing with, so I need to be careful interpreting
>     what I see, and I should avoid making any inferences.
No, not really.
> 
> There is no doubt that the 127.x net is treated in a special way.  If I
> have to believe what I just learned, then the 127 routes are in a
> "local" table, a table on which the "route" utility by definition does
> not operate!  On the 2.4.25 machine I cannot get any of the "ip"
> commands to execute without an error:
'Route' utility is by definition deprecated.

>   $ ip route del 127.0.0.1 dev lo table local
>   ip: either "to" is duplicate, or "table" is a garbage.
[root@bawx2 ~]# ip route del 127.0.0.1 dev lo table local
[root@bawx2 ~]#

And don't forget to delete the /8 route as well.

> Since there was no "to" on the command line I suspect the busybox crap
> to be doing something very bad. I'll look at that.
Don't try to use broken tools (busyboxed iproute2). Test with known-good
iproute2.

> To summarize, it appears that I can subnet the 127 net by appropriately
> manipulating one or two kernel routing tables, if I can find the right
> tools to do that.  If the tools don't work, then getting the tools to
> work would be the necessary modifications I would have to make on my
> machines to get the job done.
-alex

