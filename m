From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v3 14/16] i40e: make a define from a large constant
Date: Fri, 20 Dec 2013 12:12:11 -0800
Message-ID: <1387570331.2183.97.camel@jtkirshe-mobl>
References: <1387563694-3166-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387563694-3166-15-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387564814.2353.60.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-W95XL/JqbftpkVvcry+8"
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50653 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035Ab3LTUMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 15:12:12 -0500
In-Reply-To: <1387564814.2353.60.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-W95XL/JqbftpkVvcry+8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-12-20 at 10:40 -0800, Joe Perches wrote:
> On Fri, 2013-12-20 at 10:21 -0800, Jeff Kirsher wrote:
> > Make a define used in the header file by both VF and PF drivers.
> []
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/=
ethernet/intel/i40e/i40e_txrx.h
> []
> > @@ -66,6 +66,26 @@ enum i40e_dyn_idx_t {
> []
> > +/* Supported RSS offloads */
> > +#define I40E_DEFAULT_RSS_HENA ( \
> > +	((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
>=20
> BIT_ULL
>=20
> > +	((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
>=20
> etc...
>=20

Joe, I am not seeing widespread use of the macro BIT_ULL, so what is the
driving factor to use the macro?  I know you mentioned this on a
previous patch I pushed and wanted to ask then, but simply forgot.

--=-W95XL/JqbftpkVvcry+8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJStKSbAAoJEOVv75VaS+3OHk8P/3mH6v6Co9IRaVEWTxXENzS0
V6kc/Ejfywz9gPEWGfbZndNl5k6x8fmiFxDAClRLo0eHDMx6c0+ynE+QuWlIeVrO
kF3Kht1yCDAqeGIrKGdSOuRGO3Y2bTpZGkkLEJiwzBp0yVEluI2mQ4TNifY27yAY
szQTvdV1KJRPVkAjZWUfMqIVtsvu0WpLTURY8ZtRgAPCU8ZyLGea1mvAXwnw47ty
1zLgtYk3AawLTweyzGpVm/PZW2X40/QRyeVENpP7lzl9GNhBl2uvAy8OgzB9Kw8O
91gk0ipIkrLKcfzZMDL59dCnQ1IoNuOklVGAvThKeiU/6EWfYr68zkc321bg6kmi
PrzI4Osu+ns9N4JcsHyJMDx0VJNp8Gr3Nx5uVmSbTXOLtJpP07lmzjIGkqkXGz3A
KdJjQO5jETeroslIZkqC4q37JQkta51EyqtOCcwV7yDg1UcFfiV8TjHEMVoWLv3r
deWoSK+ZFVs1SZHNEABCmN/aLclmNyK3EHV+qtkwYapTtqOFD7BStfi4qlVhGhst
ZdXyi9TKJB4jKQWb3ifC1+Q120G+NiFUZCbUFbCezMBFs6n+jeo1k8UbLBFktHYT
wva8TeCC7pX8RDcCQHViuOFiHx3aXvrLdTaEs2D2kpXE2vKRtzmy0AposlQdUamY
Me+fUcz2ro65z5hDwRjX
=YiqF
-----END PGP SIGNATURE-----

--=-W95XL/JqbftpkVvcry+8--
