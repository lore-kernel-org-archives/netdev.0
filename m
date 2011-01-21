From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38-rc1: arp triggers RTNL assertion
Date: Fri, 21 Jan 2011 23:13:19 +0100
Message-ID: <1295647999.2609.31.camel@edumazet-laptop>
References: <20110121061758.GA2247@fifty-fifty.audible.transient.net>
	 <1295593946.2613.52.camel@edumazet-laptop>
	 <1295635976.2609.23.camel@edumazet-laptop>
	 <20110121.130657.106806953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamie@audible.transient.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63610 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373Ab1AUWNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 17:13:25 -0500
In-Reply-To: <20110121.130657.106806953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 janvier 2011 =C3=A0 13:06 -0800, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 21 Jan 2011 19:52:56 +0100
>=20
> > Here is how I fixed this, thanks again Jamie !
> >=20
> > [PATCH] net: neighbour: pneigh_lookup() doesnt need RTNL
>=20
> Eric, I don't think we can do this.
>=20
> Fundamentally, any time a user operation changes the configuration
> of the networking, we must hold the RTNL.
>=20
> Eliding the RTNL for lookups is fine, but for things that change
> state it is not.
>=20
> I therefore think you'll need to rework the arp_ioctl() portions
> of the commit that introduced this regression.
>=20

Hmm, I'll think about it, no problem.


