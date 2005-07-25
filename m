From: stian@nixia.no
Subject: Re: [uml-devel] multicast on loopback: mcast networking at the
     cottage
Date: Mon, 25 Jul 2005 19:20:57 +0200 (CEST)
Message-ID: <42036.85.166.82.153.1122312057.squirrel__24582.6684906662$1122312224$gmane$org@85.166.82.153>
References: <6048.1122248129@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "user-mode-linux-devel" <user-mode-linux-devel@lists.sourceforge.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <6048.1122248129@marajade.sandelman.ottawa.on.ca>
To: "Michael Richardson" <mcr@sandelman.ottawa.on.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I suspect that for people who want to do multicast between hosts on an
> actual wire won't want to have just a route to lo, they may want a route
> for 224.0.0.0/4 on all of their interfaces.  Maybe that should be
> automatic?
>
> I think that applications that are multicast aware are supposed to
> figure out which interfaces that they want to bind to anyway, so they
> should not be confused by the multiple routes.

If I remember things right (I might be wrong here):

ipv6 does this automatically, so should ipv4 have done too if multicast is
supported on a device. Multicast aware programs should always bind to a
device, or broadcast on all devices for discovery.

This is not uml-specific, but vanilla kernel. Some distroes add
multicast-routing for ipv4 during init scripts.


Stian
