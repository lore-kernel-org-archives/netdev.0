From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Linux router performance (3c59x) (fwd)
Date: Tue, 18 Mar 2003 00:09:42 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0303172356440.8302@ns.istop.com>
References: <Pine.LNX.4.51.0303172239390.30872@ns.istop.com>
 <3E76A508.30007@candelatech.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3E76A508.30007@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Mar 2003, Ben Greear wrote:

> Ralph Doncaster wrote:
[...]
> > Currently the box in question is running a 67% system load with ~40kpps.
> > Here's the switch port stats that the 2 3c905cx cards are plugged into:
> >
> >   5 minute input rate 36143000 bits/sec, 8914 packets/sec
> >   5 minute output rate 54338000 bits/sec, 10722 packets/sec
> > -
> >   5 minute input rate 50585000 bits/sec, 12445 packets/sec
> >   5 minute output rate 34326000 bits/sec, 9596 packets/sec
>
> When using larger packets, NAPI doesn't have much effect.

So I should just give up on Linux and go with FreeBSD?
http://info.iet.unipi.it/~luigi/polling/

> Have you tried routing with simple routing tables to see if that
> speeds anything up?

No, but I did read through a bunch of the route-cache code and even with
the dynamic hashtable size introduced in recent 2.4 revs, it looks very
ineficient for core routing.  I'd expect a speedup with a small routing
table, but then it would be useless as a core router in my network.

> Could also try an e100 or Tulip NIC.  Those usually work pretty
> good...  Or, could use an e1000 GigE NIC...

If I can get confirmation that under similar conditions the e1000 performs
significantly better, then I'll go that route.

> It's also possible that you are just reaching the limit of your
> system.

The NAPI docs imply 144kpps is easily attainable on lesser hardware than
mine.  Also I can't see bandwidth being the issue as I'm moving
<25Mbytes/sec over the PCI bus.  I should be able to do more than double
that before I have to worry about PCI saturation.

-Ralph
