From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net/ibm/emac: bump version numbers for correct work
 with ethtool
Date: Wed, 23 Sep 2015 20:03:03 +0100
Message-ID: <1443034983.12750.10.camel@decadent.org.uk>
References: <20150923144222.66de305c@fr-ThinkPad-W520>
	 <20150923.110549.113067983983388057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-D1xC4VhxHVjOduV1aERt"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>, ivan@ru.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150923.110549.113067983983388057.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-D1xC4VhxHVjOduV1aERt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-09-23 at 11:05 -0700, David Miller wrote:
> From: Ivan Mikhaylov <ivan@ru.ibm.com>
> Date: Wed, 23 Sep 2015 14:42:22 +0400
>=20
> > Register dump out work preventing with=20
> > old ethtool + new driver and new ethtool + old driver.
>=20
> First of all you didn't provide a proper Signoff.
>=20
> Second of all, there was so much discussion about whether this does
> or does not break things for various combinations of old/new ethtool
> and kernel.
>=20
> Therefore I want a real detailed commit message that explains why this
> is all OK.  After so much confusion and discussion, providing a patch
> with absolutely no commit message is completely inappropriate.

I would suggest something like this:

"""
The size of the MAC register dump used to be the size specified by the
reg property in the device tree.  Userland has no good way of finding
out that size, and it was not specified consistently for each MAC type,
so ethtool would end up printing junk at the end of the register dump
if the device tree didn't match the size it assumed.

Using the new version numbers indicates unambiguously that the size of
the MAC register dump is dependent only on the MAC type.

Fixes: 5369c71f7ca2 ("net/ibm/emac: fix size of emac dump memory areas")
"""

Also:

Acked-by: Ben Hutchings <ben@decadent.org.uk>

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.
--=-D1xC4VhxHVjOduV1aERt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVgL3Z+e/yOyVhhEJAQrTkBAAgRIl48KJkMeVIEhtellWQjQ55KMwZR7Z
UaiUfiKdfCYWHu/7GZjmIjqVuP+MoP0f2CL+ixSf2Eg3R9Sm7Vb5+Rp6fbZlVUsb
/cVyEof71UQaybpKS9aksNzd6Dzr0/ugG6Zh49QAc+B1+pHM6DQXcORBtTN+ECZ2
hGEYPlFlgzTufMqmydHS8ZoA657CH9v0vGGeH7TvAvevYzU7EBcSUdEpADMyVWIt
y+jRFh7cOH3qGdWfHXdHdfugW+g0UJmCXq5spB7myBdDzqgJBG/GiJjlbQ022dc7
eMckMzk3jzCqJidGmaOwHwgOkhQOTmxgI1LeGWqfj0hmLiDj42KJPEiQml1txgUu
YP+KoyJXy1z1qHES97RqKFfkcGCGdMq/uDr9jWyHPZOMsEj0w2AkFaWCc+F2GALe
syHuUNZRokyXBYMO75/9ZBNxp72OvLcTJ4KmbU18MWEDr0S63zkj6ESujubbu317
YmRad7csW9OeCZ4KLNEH00c9zOOc/uuis4HYj01XXJ7aXhVLh2TUtH25wPS1JYlc
QP/qouxT6u7QdhnYqO8CevWRqMAfSBvtx4rWxsaQzSyOkY6fSkJMhAczwB8Gty8r
gfNuWIL3DEERvLUmpP4jz54Cv3sv7LpOswJ46eQGJFOWflsHCAliDcCF6tFiP8jM
IkXHHUu2F9Y=
=CX07
-----END PGP SIGNATURE-----

--=-D1xC4VhxHVjOduV1aERt--
