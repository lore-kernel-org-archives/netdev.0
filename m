From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: default route for link local address is not added while assigning a address
Date: Fri, 10 Jan 2014 18:16:13 +0100
Message-ID: <20140110171613.GA23647@order.stressinduktion.org>
References: <52CFE594.8010808@gmail.com> <52D020C4.30105@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sohny thomas <sohny.kernel@gmail.com>,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kumuda <kumuda@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52D020C4.30105@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 10, 2014 at 05:33:08PM +0100, Nicolas Dichtel wrote:
> CC: netdev
>=20
> Le 10/01/2014 13:20, sohny thomas a =C3=A9crit :
> >Default route for link local address is configured automatically if
> >NETWORKING_IPV6=3Dyes is in ifcfg-eth*.
> >When the route table for the interface is flushed and a new address =
is=20
> >added to
> >the same device with out removing linklocal addr, default route for =
link=20
> >local
> >address has to added by default.
> I would say that removing the link local route but not the link local=
=20
> address
> is a configuration problem.
> If you remove a connected route but not the associated address, you w=
ill=20
> have
> the same problem.

We have some user accessible routes that are essential for IPv6 stack
to work at all. So I don't know if I can agree with that.

Maybe flush is a bit too aggressive?
