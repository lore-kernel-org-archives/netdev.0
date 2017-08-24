From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 07/13] net: mvpp2: improve the link management
 function
Date: Thu, 24 Aug 2017 16:14:13 +0200
Message-ID: <20170824141413.GE28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-8-antoine.tenart@free-electrons.com>
 <20170824140625.GH8022@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="EgVrEAR5UttbsTXg"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824140625.GH8022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EgVrEAR5UttbsTXg
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Aug 24, 2017 at 04:06:25PM +0200, Andrew Lunn wrote:
> On Thu, Aug 24, 2017 at 10:38:17AM +0200, Antoine Tenart wrote:
> > @@ -5753,14 +5753,24 @@ static void mvpp2_link_event(struct net_device =
*dev)
> >  		port->link =3D phydev->link;
> > =20
> >  		if (phydev->link) {
> > +			mvpp2_interrupts_enable(port);
> > +			mvpp2_port_enable(port);
> > +
> >  			mvpp2_egress_enable(port);
> >  			mvpp2_ingress_enable(port);
> > +			netif_carrier_on(dev);
>=20
> Have you seen cases where it is required to change the carrier state?
> The phy state machine should be doing this. e.g. when autoneg has
> completed, force link configuration, the link goes down etc.

I don't think I saw a case where this was needed. And if phylib already
handle this I think it should be removed from here as the
mvpp2_link_event only is called by phylib.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--EgVrEAR5UttbsTXg
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme3zUACgkQXE2LyK3b
vNjVKg//bGMubmaz+YrpgfX+PdPCLyy0fVHPjJjIoqI94ap95IGxIl7nFQcU5apl
0nAnnHXup0E6plXI3icpw1AdKJFJtmEIwxfU7LXxBeNVGMHPJNY9smoc0NP8diCs
W2XGT2yJL+wudVo5aZYoMuMsFSD/vmU8eAFjVMrsXLT2pZakDstDjF7WbdoLoSmO
7el9kpXuclsHzKuN5A7PSEEedXYbcmRgmvS0oMTseGzdFNiFdnvgFEVl4iGupjMo
M+IbhlOjMulL+hRPBAtfQgtGpAXwWYF/aGxrO9DuN1N65t4NuEyXZi7ZfWXBnp10
H1liwN+HoeIrb1r5Wkjxdhcl1ZnEwi5Uh69yv0LzlJOMcPc1iPMT+AUiLZBlhGK/
HdCeqQTW5T5K8nh6V8DQW2cxeeaXR/P+PgXXeu9Nu1icvsOw7jUNlyLsjLAbCNPi
+q8uuXIKogK2JxjViLlu4sYHxXWoei6PeDAZ2mGnWVxDeitu2MgSNgy6n/hHgPSN
R7qSYJEZx9JOdQD0v6aBJTa4b8kJ3iQSWsqnOV0ru5HdJbWnXRBT9IGcvglhad3z
SNms3soZtb8elofNMeyZRKPekGmFL2kq0QM2dEu5+ANVgvk57t+bgVnZvd5ou1rP
d94utvXnk0UnDBkfhSk4oM45oYNRiqDai2JgImzDPASjgYUhprA=
=9E1p
-----END PGP SIGNATURE-----

--EgVrEAR5UttbsTXg--
