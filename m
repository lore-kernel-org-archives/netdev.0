From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 05/14] net: mvpp2: do not force the link mode
Date: Mon, 28 Aug 2017 08:55:45 +0200
Message-ID: <20170828065545.GC2568@kwain>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-6-antoine.tenart@free-electrons.com>
 <20170825224312.GD20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="dkEUBIird37B8yKS"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825224312.GD20805@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dkEUBIird37B8yKS
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Russell,

On Fri, Aug 25, 2017 at 11:43:13PM +0100, Russell King - ARM Linux wrote:
> On Fri, Aug 25, 2017 at 04:48:12PM +0200, Antoine Tenart wrote:
> > The link mode (speed, duplex) was forced based on what the phylib
> > returns. This should not be the case, and only forced by ethtool
> > functions manually. This patch removes the link mode enforcement from
> > the phylib link_event callback.
>=20
> So how does RGMII work (which has no in-band signalling between the PHY
> and MAC)?
>=20
> phylib expects the network driver to configure it according to the PHY
> state at link_event time - I think you need to explain more why you
> think that this is not necessary.

Good catch, this won't work properly with RGMII. This could be done
out-of-band according to the spec, but that would use PHY polling and we
do not want that (the same concern was raised by Andrew on another
patch).

I'll keep this mode enforcement for RGMII then.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--dkEUBIird37B8yKS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmjvnEACgkQXE2LyK3b
vNgmKw/+KwOCmU8HDLwG9/7bvG8qmop1mutfj8DuWgF+8ZkTG9oywdJfeyDCLzLH
ZpyvrggMKr+fpYW4/ScTnPb9Wl7IrmF2nW44gGuB54BziC1SbGCXfK0Zqj56lsWf
agGifkqPquTEbhz70MqdA0cX+Z+zLVDGZmdLKXWabGQoveNXR9K/mgZ19hSHj8y8
ilrjO0mPgIrwYk+ya/N575fHXM9iSN93kw1NlEFNFgYjjZrHLR9bfnFbRVN/mquD
uGEgDenaXs33MqTF9IxzRDPMXh0OCIR+0eKbfcZP/vHaSa4kL6hPsnbV3jzy+fUE
Ps1IzTIIaSwEjRjnDGtqxhkNYE4gx9cM3gzof+dx3ibo+lXBdJa5hHwQVxHnHd93
e9+jWAzffPeVEjR4XDG8CU+BDBRNlP5/yUZ642d88xhf1ZubYATbK+0tbe1RKAgR
UNvxYBui76MyXhup3kJeT0enIK7aPIAVAZhjjNzkuHfQuTG3x3OjH3W4lw8O9pR+
H/gKjYSzokKV1HQ0WBXF6N6HLp3ObbKjjix8JFQBzQXvoARz/gKSTRIi+N8Gv/rf
ERmiq5bOmGS3kPWMtjTFrLP3PGwI9MdjLqYYlpsOCTUmnFdKidmcsFyffIjohmD8
TXycVp0rel5mylqoGSDy9MR30vSAzoU/7DiewjW+E0Dkk2J0+gM=
=/ifD
-----END PGP SIGNATURE-----

--dkEUBIird37B8yKS--
