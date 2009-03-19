From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 1/9] of: add of_parse_phandle() helper for parsing
 phandle properties
Date: Thu, 19 Mar 2009 16:07:50 +1100
Message-ID: <1237439270.18869.42.camel@localhost>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-yB53ZDpZVYo2TaZnAyJu"
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60816 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbZCSFSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 01:18:03 -0400
In-Reply-To: <20090319050015.11320.61641.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yB53ZDpZVYo2TaZnAyJu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-03-18 at 23:00 -0600, Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>=20
> of_parse_phandle() is a helper function to read and parse a phandle
> property and return a pointer to the resulting device_node.
>=20
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>=20
>  drivers/of/base.c  |   23 +++++++++++++++++++++++
>  include/linux/of.h |    3 +++
>  2 files changed, 26 insertions(+), 0 deletions(-)
>=20
>=20
> diff --git a/drivers/of/base.c b/drivers/of/base.c
> index cd17092..1eaada4 100644
> --- a/drivers/of/base.c
> +++ b/drivers/of/base.c
> @@ -494,6 +494,29 @@ int of_modalias_node(struct device_node *node, char =
*modalias, int len)
>  EXPORT_SYMBOL_GPL(of_modalias_node);
> =20
>  /**
> + * of_parse_phandle - Resolve a phandle property to a device_node pointe=
r
> + * @np: Pointer to device node holding phandle property
> + * @phandle_name: Name of property holding a phandle value
> + * @index: For properties holding a table of phandles, this is the index=
 into
> + *         the table
> + *
> + * Returns the device_node pointer pointed to by the phandle, or NULL
> + */

I think it would good to follow the convention of many of the other of_
routines and have an explicit comment about the refcounting, eg:

 *      Returns a node pointer with refcount incremented, use
 *      of_node_put() on it when done.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-yB53ZDpZVYo2TaZnAyJu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAknB0yUACgkQdSjSd0sB4dJRggCgsZOarhzWFn+s17G+DngZr8r7
L64An3qdvhitFVFnQS+94+8VlT3zcMaW
=QIj4
-----END PGP SIGNATURE-----

--=-yB53ZDpZVYo2TaZnAyJu--

