From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 14:53:44 -0300
Message-ID: <20080513175344.GJ15306@ghostprotocols.net>
References: <OF8AA2B2D0.51E14DBC-ON88257448.005BC2A0-88257448.005D57D0@us.ibm.com> <200805132006.35010.rdenis@simphalempin.com> <20080513173454.GH15306@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	Gerrit Renker <gerrit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755380AbYEMRzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 13:55:13 -0400
Content-Disposition: inline
In-Reply-To: <20080513173454.GH15306@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, May 13, 2008 at 02:34:54PM -0300, Arnaldo Carvalho de Melo escr=
eveu:
> Em Tue, May 13, 2008 at 08:06:34PM +0300, R=E9mi Denis-Courmont escre=
veu:
> > Le Tuesday 13 May 2008 19:59:35 David Stevens, vous avez =E9crit=A0=
:
> > >         Well, SOCK_STREAM/IPPROTO_DCCP then. :-) But it isn't rea=
lly that
> > > either, as Remi said.
> > >         If you do a connect() on a UDP socket, it doesn't cease t=
o
> > > be a SOCK_DGRAM socket, so I don't really care about that distinc=
tion,
> > > but if others do, that's ok with me. There are ACKs here, too, so=
 maybe.
> >=20
> > But connect() is a _non-blocking_ operation which merely sets the _=
default_=20
> > destination (you can still sendto() someone else).
> >=20
> > Using socket types blindly may also break applications using=20
> > getsockopt(SO_TYPE), if they exists (I think I wrote one once...) t=
o=20
> > determine how to use a socket.
> >=20
> > SOCK_DCCP was perhaps a bad idea, but SOCK_DGRAM seems worse. In th=
e end, it's=20
> > more a matter of patching libc getaddrinfo than changing the kernel=
 API=20
> > anyway. Did AIX not have a similar socket type as DCCP under a more=
 generic=20
> > name by the way?
>=20
> /me feels Deja Vu :-)
>=20
> Lemme dig the URL for the discussion where SOCK_DCCP was discussed an=
d
> AIX was summoned, etc :-)

http://www.ietf.org/mail-archive/web/dccp/current/msg01540.html

While discussing with Nishida-san, the NetBSD DCCP guy.

- Arnaldo
