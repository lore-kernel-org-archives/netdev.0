From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH/RFC 00/10] Transparent proxying patches version 4
Date: Mon, 8 Jan 2007 00:58:42 +0100
Message-ID: <20070107235842.GU15618@prithivi.gnumonks.org>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <20070107141134.GA13543@prithivi.gnumonks.org> <20070107161106.GA13717@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tfmLD+Hxjexp/STe"
Cc: KOVACS Krisztian <hidden@balabit.hu>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:34767 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932229AbXAHIwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 03:52:11 -0500
Received: from uucp by ganesha.gnumonks.org with local-bsmtp (Exim 4.50)
	id 1H3qEj-0000x5-NK
	for netdev@vger.kernel.org; Mon, 08 Jan 2007 09:52:09 +0100
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20070107161106.GA13717@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tfmLD+Hxjexp/STe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 07, 2007 at 05:11:06PM +0100, Lennert Buytenhek wrote:
> On Sun, Jan 07, 2007 at 03:11:34PM +0100, Harald Welte wrote:
>=20
> > > So instead of using NAT to dynamically redirect traffic to local
> > > addresses, we now rely on "native" non-locally-bound sockets and do
> > > early socket lookups for inbound IPv4 packets.=20
> >=20
> > It's good to see a solid implementation of this 'old idea'. =20
> >=20
> > Just as a quick historical note to netdev:  This is the way how the
> > netfilter project  advised the balabit guys to implement fully
> > transparent proxy support, after having seen the complexity of the old
> > nat-based TPROXY patches.
>=20
> Didn't rusty tell the balabit guys to use the NAT approach?

that was originally, way back.  It turned out to be a bad idea, after
all... way too complex.  At least that's how I look at it.  Too sad :(

Rusty and me then had the idea about the routing based approach at some
point, if I remember correctly.  We talked about it with Krisztian and
Balazs at least on one occasion.

All that isn't really important.  All I wanted to say was:

"I (and AFAIR the netfilter core team) believe this is the way to
implement good support for transparent proxying.  It's already the
second completely independent implementation, let's merge it after all."

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--tfmLD+Hxjexp/STe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFFoYkyXaXGVTD0i/8RArN9AJ4l2HFAYKyA4eu9WaX7eYoXN6jxSACfb/a1
YRMMeX8/cYJ5jVvfYl1QiBM=
=ChP0
-----END PGP SIGNATURE-----

--tfmLD+Hxjexp/STe--
