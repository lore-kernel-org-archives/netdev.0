From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 02/13] phy: add the mvebu cp110 comphy driver
Date: Thu, 24 Aug 2017 15:58:05 +0200
Message-ID: <20170824135805.GB28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-3-antoine.tenart@free-electrons.com>
 <20170824134504.GD8022@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="9zSXsLTf0vkW971A"
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
In-Reply-To: <20170824134504.GD8022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9zSXsLTf0vkW971A
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Aug 24, 2017 at 03:45:04PM +0200, Andrew Lunn wrote:
> > +	for_each_available_child_of_node(pdev->dev.of_node, child) {
> > +		struct mvebu_comphy_lane *lane;
> > +		struct phy *phy;
> > +		int ret;
> > +		u32 val;
> > +
> > +		ret =3D of_property_read_u32(child, "reg", &val);
> > +		if (ret < 0) {
> > +			dev_err(&pdev->dev, "missing 'reg' property (%d)\n",
> > +				ret);
> > +			continue;
> > +		}
>=20
> I'm just wondering why we need this. We know how many lanes there are
> from the table. So just create a generic PHY for each lane?

At first I did this statically. I moved to this solution because:
1. It represents the h/w correctly (there are 6 lanes duplicated here).
2. It eases the dt representation, we would have something like:
   <&cpm_comphy 0 1>; otherwise.
3. If the number of lanes changes in future revisions it'll be quite
   easy to handle.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--9zSXsLTf0vkW971A
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme220ACgkQXE2LyK3b
vNh9sQ//bBN905s3pIBn+Jl6I4LxPRa7EPztstkDppMU++ii0OAlaIsXBWFi9MG8
KrHvSHZa/oVG6R4rBYusjVgDS8NvNUv131gUNI4/hDpoEb4S8hEJIRq3w1k9pGNA
jW/FQAWdDPsjbP3UeOxWw8LCeVmraimN+vlj7WhSynRyNnkeqMAQKWaHd5YZ9eYJ
sR2qpegT3WUYXcnigwRc0gvyZrlalzA3ylEuOrFdibbjZIDwMq9TyxWYvcrWdLIY
46pKGdQp8m7ozFxiOZlIII/NlCMQahyh1BQ1JsgaiKYhepko+jtXS5yxQQGfCh30
vePU22JoEZjCjUusZNh8dxPijdY42g2Ni5twob+Q3+ajxq/XamC0GWLKFwZQuv2K
YYxE3gJRyN6Zk3AmZmY/q+rGfRawEEbUVJsueL21Gkw3yEJJaMJNEylZPswRp9le
KfRybT3ocSXFbsNoLhzHYvJtTtuhF9JFcUvUOATx9IxAOuOzksCLcKiIC6PZID+0
xHiinaxhPZ87+YFwFUaEVB7JsbSrZF3SRJDE/QuH1CgE8Vg2xLS7tJoJdkKHrFZ5
SsA8zZqBXM2srYBG+ahSQ7CHAQrkEH4dkCWjYSuGK2ebv6QWXtI5oK6ApidxtNDK
pNqWmSBC5Nf205Cs7uu5X3pmnsCPL0oWfiTIDPL/bskMRugiyxk=
=ePoG
-----END PGP SIGNATURE-----

--9zSXsLTf0vkW971A--
