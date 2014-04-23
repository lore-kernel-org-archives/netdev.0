From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Wed, 23 Apr 2014 16:55:42 +0100
Message-ID: <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
	 <20140423153018.GA13717@breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0+xKm6apZCr28I3ar36C"
Cc: netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57288 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756614AbaDWPzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 11:55:54 -0400
In-Reply-To: <20140423153018.GA13717@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0+xKm6apZCr28I3ar36C
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-23 at 17:30 +0200, Florian Westphal wrote:
> Ben Hutchings <ben@decadent.org.uk> wrote:
> > ICMP ping sockets currently require a new ping binary and are only
> > available after setting a sysctl.  The code adds about 10K to the
> > (uncompressed) size of the kernel.  Make this optional and disable
> > it by default.
> >=20
> > This is compile-tested only; I'd just like to see whether people think
> > this is worth doing.
>=20
> Either this feature needs to be ripped out now or it has to be kept.
>=20
> I do not think the middle-ground you're proposing will work:
>=20
> If userspace cannot safely assume facility is available, binaries
> need to be setuid to implement fallback, and when you go down that
> road you've gained nothing and might as well not support ping sockets
> at all.

Userspace can't assume it now because access is controlled by a sysctl.

I think it is for distributions to choose whether to enable this feature
in ping and the kernel.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-0+xKm6apZCr28I3ar36C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1fifue/yOyVhhEJAQoh+w//SOvAdN9qlQ5sgCK8u2qL7s1yQh2jI6pa
CxHuf0H5VtU+uLQksE2uAQjmRovldvXoPU47y5oc5c4n06gyIACkEntAAm/AbFl2
1SmGjqU6m54a3D7oxocEAbV3cQ/iOaDP/f+xPfZen3crMLMbtCP8EaDsIwqAAcon
SUgFTozTpFan3BOnWyPN1BB+9lz13CnbmJJozHRVQ+kpqzBiT3vQyHxuHsUoBHgi
V/BuIxBPrDb9h82gk5uw2AceDVvgLKkv01AanDG/fXhyFOPQ9eWRs6I+t1NQ6Jfu
bzQ6ClOO5fIVi/GTKdfps/xHggGzapcRJsr6vI+Eg85BUs5KyERamVXdpB4LfIBp
5ayQUDrtwXiWMkcdtIGV7C3elKXkSxuhL9LmCARiKxq0tmnBC0nEAnYj1l0M4hUV
Q5FvcrFx2jIpT79dJdiGeXH0pnHJmv5oBctXqc8cR05sFoqXRBJCPcMbxvBEjP13
4QFrEKECXHREb0b79sGos31ievoNf5+Vjb4neqDk2Xe/rw8libL29DJli9aAF5i/
37Z7GdDYBXZmS1i0k546JaUt7Hlp4RE85BulpJKlSr3PbEAQyQNFj7+b3i4pYKWa
43OJ7lY7O7o2TeIAlHpVMaGawR4UXtO/lSaYun2afJ7QQP53W3mjN2AZ/YHAz+IH
env0+d7PWy0=
=ZApA
-----END PGP SIGNATURE-----

--=-0+xKm6apZCr28I3ar36C--
