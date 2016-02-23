From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pause
 functions
Date: Tue, 23 Feb 2016 00:03:47 +0000
Message-ID: <1456185827.15241.77.camel@decadent.org.uk>
References: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
	 <1455839111.2794.51.camel@decadent.org.uk>
	 <9235D6609DB808459E95D78E17F2E43D404B55D1@CHN-SV-EXMX02.mchp-main.com>
	 <20160222.141014.1517836822587262524.davem@davemloft.net>
	 <1456171519.15241.65.camel@decadent.org.uk>
	 <9235D6609DB808459E95D78E17F2E43D404B570E@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-a9KeIhVUt14bYp8MrnQh"
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39134 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756366AbcBWAEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 19:04:09 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404B570E@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-a9KeIhVUt14bYp8MrnQh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-22 at 20:28 +0000, Woojung.Huh@microchip.com wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Monday, February 22, 2016 3:05 PM
> > To: David Miller; Woojung Huh - C21699
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pau=
se
> > functions
> >=20
> > On Mon, 2016-02-22 at 14:10 -0500, David Miller wrote:
> > > From: <Woojung.Huh@microchip.com>
> > > Date: Mon, 22 Feb 2016 18:28:18 +0000
> > >=20
> > > > > This is incorrect; you should always return the manual settings
> > > > > (fc_request_control flags) here. =C2=A0If autonegotiation is enab=
led then
> > > > > your get_settings function will return the actual pause flags.
> > > > >=20
> > > > What do you mean "return actual pause flags" when autoneg is enable=
d?
> > > > Pause flags set by (or default) advertise flag?
> > >=20
> > > It means what was negotiated by autonegotiation, and is actually in u=
se.
> > >=20
> > > Otherwise, how can the user find out what was negotiated?
> >=20
> > Well, actually we don't *directly* report the autonegotiation flow
> > control mode at present. =C2=A0We report which pause flags were adverti=
sed
> > and what the link partner advertised, from which you can work it out.
>=20
> NIC advertises pause flags via advertise register (phy reg 0x4) based on =
Rx & Tx flags,
> and get_pauseparam() returns Rx & Tx flags set by set_pauseparm() if auto=
negotiation is enabled?

Yes.

> > Perhaps ethtool (the utility) should explicitly show what the result
> > is.
> Ethtool -a reports Rx/Tx flags and Rx/Tx negotiated flag based on adverti=
sing and lp_advertising value.

It would probably make sense to include the result of pause frame
autonegotiation in both the 'ethtool -a' and 'ethtool' (no option)
output.

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u
--=-a9KeIhVUt14bYp8MrnQh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsuh4+e/yOyVhhEJAQrLJxAAy7AfxxowwHVAyNayEawv2eXXArX6WAls
9a19AnFkVOJ06156hmdAgXfu5vcb+C10AfTUXIMTJo7oiFE9rEqWWnj/9X/iPnqZ
KMXiCnMbwSyB9gY8sGMEAE+vxXdL6pO4tQHEefjIcjd+Re9m7UmG6bE0UKJ/jFeR
lzgLlb86Id990IFMOW/fYwXnFBYoGrx3CM1GfWAFAGxXiN0jJKvJSEHabrl3XU0u
1W1Vza28xbm2e9SKc9TdDdNC+/U5g7de8VqRJ8jBIe11C6FfEEEh1k86nsWUb5Q8
b+UaGa3iE+4FlRE3llowLLgg3dy4/GI6cxwXvQbFUDiJXp31PNUhBVkG0jNMoDMl
8CXDMU9a0/cgg1s4aZhVrm5Hln0wAe+et+hJESHcrbIXSyT9VTyQaFl0Vbc0cGEo
0JazSEk/l06jZJoE1ZpY1Zt4ILSUsIi0Lf5Q9NYPqXqSc/9KRmMxgnYj62QGAjqi
VJtBL2vnE8ZhcMHudd7sMCJMVpJw9s2jjcpg79Mhh5MraciCUEj9ggdCsCLujLE+
hiWOzgkCF6IK8cCuf9h1vJ6Hg6shx6/fIjajLy2TYMaQ7RD8AY/jvKqkD1xukqnN
epsiUf3/4N5d6M38Txz8CBZN9F9hIzNJbuYwDtx1vpolbHQu05MiFA3uYqmzO8g9
CRauhD/drWc=
=nXxl
-----END PGP SIGNATURE-----

--=-a9KeIhVUt14bYp8MrnQh--
