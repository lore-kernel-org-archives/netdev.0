From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH net-next-2.6] net: build_ehash_secret() and
	rt_bind_peer() cleanups
Date: Thu, 19 Aug 2010 12:30:22 -0400
Message-ID: <20100819163022.GD24357@Krystal>
References: <1282232815.2549.61.camel@edumazet-laptop> <AANLkTinpqNa3cgEb=86H0sYXdLmo-RP1G2icJgWpfyN1@mail.gmail.com> <20100819161326.GB24357@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts43.bellnexxia.net ([209.226.175.110]:38218 "EHLO
	tomts43-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751150Ab0HSQa1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 12:30:27 -0400
Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts43-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20100819163026.GMDD6618.tomts43-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 12:30:26 -0400
Content-Disposition: inline
In-Reply-To: <20100819161326.GB24357@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Mathieu Desnoyers (mathieu.desnoyers@polymtl.ca) wrote:
> * Changli Gao (xiaosuo@gmail.com) wrote:
> > On Thu, Aug 19, 2010 at 11:46 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
[...]
> > > + =A0 =A0 =A0 peer =3D cmpxchg(&rt->peer, NULL, peer);
> > > +
> > > + =A0 =A0 =A0 if (unlikely(peer))
> >=20
> > It isn't correct, and should be
> >      if (unlikely(cmpxchg(&rt->peer, NULL, peer) !=3D NULL))
> >=20
> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_putpeer(peer);
> > > =A0}
>=20
> What do you mean by "It isn't correct" ? Eric code and yours perform =
the
> exact same thing. So I assume this is just a code style issue here.

Nevermind my comment, it's not accurate.

Thanks,

Mathieu


--=20
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
