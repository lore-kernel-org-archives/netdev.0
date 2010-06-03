From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Thu, 3 Jun 2010 00:56:19 -0400
Message-ID: <20100603005619.48138462.billfink@mindspring.com>
References: <1275496439.2725.203.camel@edumazet-laptop>
	<alpine.DEB.2.00.1006021140320.30182@router.home>
	<20100602.101258.134121018.davem@davemloft.net>
	<20100602.103102.121237521.davem@davemloft.net>
	<20100602235007.02506d99.billfink@mindspring.com>
	<1275537240.29413.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:33548 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751176Ab0FCE4X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 00:56:23 -0400
In-Reply-To: <1275537240.29413.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Jun 2010, Eric Dumazet wrote:

> Le mercredi 02 juin 2010 =E0 23:50 -0400, Bill Fink a =E9crit :
> > On Wed, 02 Jun 2010, David Miller wrote:
> >=20
> > > Just in case people are really so clueless as to be unable to fig=
ure
> > > this out:
> > >=20
> > > echo 1 >/sys/kernel/debug/tracing/events/skb/kfree_skb/enable
> > > ...do some stuff...
> > > cat /sys/kernel/debug/tracing/trace
> > >=20
> > > You can even trace it using 'perf' by passing "skb:kfree_skb"
> > > as the event specifier.
> >=20
> > Could someone remind me where to get documentation for obtaining
> > and using perf.
> >=20
>=20
> Its sources are included in kernel tree
>=20
> cd tools/perf
> make
> ./perf --help

Thanks.  That seems easy enough.  From some gitweb digging, it
appears perf first appeared in 2.6.31 kernels, so I'm going to
have to do a kernel upgrade from our current 2.6.30.10 kernels.

=46or others, I also ran across a perf wiki page at:

	https://perf.wiki.kernel.org/index.php/Main_Page

						-Bill
