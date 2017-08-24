From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 12/13] arm64: dts: marvell: mcbin: add comphy
 references to Ethernet ports
Date: Thu, 24 Aug 2017 16:03:40 +0200
Message-ID: <20170824140340.GD28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-13-antoine.tenart@free-electrons.com>
 <20170824135813.GF8022@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="VV4b6MQE+OnNyhkM"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:42206 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdHXODv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 10:03:51 -0400
Content-Disposition: inline
In-Reply-To: <20170824135813.GF8022@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VV4b6MQE+OnNyhkM
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Aug 24, 2017 at 03:58:13PM +0200, Andrew Lunn wrote:
> > @@ -189,6 +191,7 @@
> >  	status =3D "okay";
> >  	phy =3D <&ge_phy>;
> >  	phy-mode =3D "sgmii";
> > +	phys =3D <&cps_comphy0 1>;
>=20
> Does the binding document describe the meaning of the specifier?

Ahhh no you're right! It's the port number i.e. there are multiple
inputs, each of which can support different modes. So say the input is
GoP#0, it can support 10G and SGMII.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--VV4b6MQE+OnNyhkM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme3LwACgkQXE2LyK3b
vNgJUw//WuYfKLvHrEwsNtz7a5VTbcNXAUYpu5wMC47PJvX0esktoQi8CEZ577xq
30m2iA20xrqgpExtyxXAFU6dKnuNdYIYJXPqxV2Bu4K9F9QPLkOsYvZtGDl+oTVz
0HnG/oVlvqECTFqw10aG1A1u6GQZz8d8qaaoR6aUMGLh+VLwNEjmN46Rp680fsLL
AYZSJl6s8dQLd8LL4fbb1JKnDAGO6O6EOPt+Jds0tPEpkKkZuaZResOoQXkS0frP
Ut+OyXt4+kXTZT/DqZZ83gYme9RoyCsigJj+bsaGbicwLTf8f2FbYBXHIB10Kskz
+XOdpzrKyv+7sUE5RixDwlUA958KSY4hpOHZPe03cpxLJ/LmvfvOq6sqvJrFK0/D
Dwn0N0oSS6duwszJQJoCxEvKNTpJ1SQ0bMPzaOiPghsX44nF3Z+WZsCceOiS372a
/Jnw7xgRj2sgiRBrAw5w3NGbVeNk7fuL+VZNY6wnyB1lJ0t312A4FUQ8RLwkcRLt
wdC0TeJReb/mfmk5NphrxBHYAsiNeFScA76ciES9hOwJXb2jnxKUqGmTrGdl8hkJ
XBS834aM6Jr5MszDoiS5Bs9CqWMmhzYNKAqpaw3+mMpsHeRQBbVb1jr9r6hlE/TX
epZ8nuZq1wBMhzgSZ4MJ2GLkY6/IUxTV7HcwtXB1cP7oZ0BXxkY=
=wjIr
-----END PGP SIGNATURE-----

--VV4b6MQE+OnNyhkM--
