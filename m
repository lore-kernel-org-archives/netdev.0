From: jamal <hadi@cyberus.ca>
Subject: Re: multipath routing doesn't work with netlink
Date: Mon, 4 Nov 2002 08:14:34 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211040811550.25806-100000@shell.cyberus.ca>
References: <20021030073722.A30664@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rik van Riel <riel@conectiva.com.br>, netdev <netdev@oss.sgi.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20021030073722.A30664@oldwotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 30 Oct 2002, Andi Kleen wrote:

> - real multipath routing.
> It is configured by setting multiple nexthops to a single route
> (ip route add ... nexthop ... )
> The kernel will do load balancing by route (=srcip/dstip/tos tripple)
>

The only caveat is of course you have to wait for the cache entry to
expire ;-> (or ARPs to fail etc). I have a patch that will force specific
cache entries to be deleted via netlink; if theres a fireman/woman with
some time in their hand and willing to write something in user space,
contact me ;->

cheers,
jamal
