From: Andi Kleen <ak@suse.de>
Subject: Re: multipath routing doesn't work with netlink
Date: Wed, 30 Oct 2002 07:37:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021030073722.A30664@oldwotan.suse.de>
References: <Pine.LNX.4.44L.0210281407540.22494-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0210281407540.22494-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 28, 2002 at 02:10:24PM -0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There are two kinds of multipath routing in the kernel (which are differently
implemented in the kernel and do different things): 

- default route failover. You configured it. It doesn't do any load balancing,
but when your default route stops working it'll eventually try the other
one. You configured that.

- real multipath routing.
It is configured by setting multiple nexthops to a single route
(ip route add ... nexthop ... )
The kernel will do load balancing by route (=srcip/dstip/tos tripple)

-Andi
