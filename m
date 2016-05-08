From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 2/3] net: ethernet: fec: use phydev from struct
 net_device
Date: Mon, 09 May 2016 00:01:23 +0100
Message-ID: <1462748483.9308.1.camel@decadent.org.uk>
References: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
	  <1462743877-31738-3-git-send-email-tremyfr@gmail.com>
	 <1462746137.2634.67.camel@decadent.org.uk> <572FC20A.5030805@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-o3qMu/TfN+j7AXtoRVmP"
Cc: fugang.duan@nxp.com, davem@davemloft.net, kan.liang@intel.com,
	decot@googlers.com, aduyck@mirantis.com, jiri@mellanox.com,
	jacob.e.keller@intel.com, tom@herbertland.com, andrew@lunn.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32915 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750844AbcEHXBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 19:01:43 -0400
In-Reply-To: <572FC20A.5030805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o3qMu/TfN+j7AXtoRVmP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-05-09 at 00:47 +0200, Philippe Reynes wrote:
> On 09/05/16 00:22, Ben Hutchings wrote:
> >=20
> > On Sun, 2016-05-08 at 23:44 +0200, Philippe Reynes wrote:
> > >=20
> > > The private structure contain a pointer to phydev, but the structure
> > > net_device already contain such pointer. So we can remove the pointer
> > > phydev in the private structure, and update the driver to use the one
> > > contained in struct net_device.
> > But there is no central code that updates the pointer, so:
> The function phy_attach_direct and phy_detach update the pointer
> phydev in the struct net_device.
[...]
> So from my understanding, those two lines aren't usefull.
> May you confirm that I'm on the right way please ?

Sorry, you're right.

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.
--=-o3qMu/TfN+j7AXtoRVmP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXL8VDAAoJEOe/yOyVhhEJ8OkQANWmax29n0uGIdwtSNhS32/4
2yvWl7GeAc11wVenigOOPF7MQ9exHt+qTh6EGg77sKovQHGqCY5AL6I2CjsmcOGd
vUFicdPZYBUCuvNMXP4OtlkE2DIgEGiWAdM5TeoVNTzFtYTvYUsmr9gYOlobxUYK
bzMfNUIe26fIjkhK8quTM5zg506QH7J4xKFbF1qKprs2QKzBEAtFGMCyZfGv8Pky
b3N+tZmCAKytwAXpbnXvsM0uyI0uyylONKjp5snf/YdEKr4jWGHHUZIKkHFTxtUe
g+iZB6JhpnM1c7Pp1BH+uml1RD2Xb06nE3BKtTyruMXm5rmYRA6uUt00eeH9hrdw
4N9QnD7q4ylhegot/jmjPJA+q0VTIJ6WdS+6Tlg6r4Kw+4QtuxqgqX0DZtoBSchh
OZzuqbjg1BGFYOZKIz/zF5iPU7aI9vVBox/kya+KJtIeBoMdqyZVCTmDt/BlsdI9
54WchRfIJr3MZm3xrS/zkV/njRKdvJDtcNFcegkURAQQOa2bs72jM/BikBf+tj5E
5H7ArDLxaqCgGnwYHEXtiNC6aEnwAAjrBq+R08l08IiwWLjioYMF+pA2i53syNTr
EK/ir70KmkLM24X3Dj++VlA38y/p1qQueJM1j/LM2llJXhL5V8cyAkvBJhhnh2+f
i04L0e1/FhjGSuKBpqaa
=msUK
-----END PGP SIGNATURE-----

--=-o3qMu/TfN+j7AXtoRVmP--
