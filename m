From: kuznet@ms2.inr.ac.ru
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Tue, 15 Jul 2003 18:46:57 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307151446.SAA08540@dub.inr.ac.ru>
References: <Pine.LNX.4.44.0307150906340.7445-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0307150906340.7445-100000@netcore.fi> from "Pekka Savola" at éÀÌ 15, 2003 09:14:07 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> "resolve" next-hops.  I.e., the requirement that the users/protocols will
> give you non-final nexthop information which you have to "resolve" to get
> the final nexthop (e.g. a global address -> a link-local address 
> obtained using Neighbor Discovery).

No way to resolve exists, unless it already embedded to corresponding protocol.
F.e. global address and its link-local equivalent could be transferred
as attributes of BGP4+, global address is used to validate nexthop attribute
and as soon as it happens to be on-link, its link-local counterpart is used.

If you have a global address out of context and want to use it as nexthop,
you are in troubles. You have no way to get a unique router identifier,
it is just not defined. So, you have to use global one (and kernel has to allow
this), and surely will screw up the network, unless some policy constraints
make the configuration legal.

Well, actually, we inevitably arrive to conclusion that all the idea
about scoped addresses is just a garbage, which results in nothing
but inconveniences and innumerous inconsistencies. I remember some
people predicted that it will be dropped to start of real Ipv6 deployment.
Well, it is still not night.

Alexey
