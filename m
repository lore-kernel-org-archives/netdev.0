From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] net: ixgbe: fix error handling in tc cls_u32
 offload routines.
Date: Thu, 03 Mar 2016 15:37:52 -0800
Message-ID: <1457048272.2936.12.camel@intel.com>
References: <1457047192-17092-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ngUIml2JnpqqZUiJMPpF"
To: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	john.r.fastabend@intel.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6456 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986AbcCCXiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 18:38:00 -0500
In-Reply-To: <1457047192-17092-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ngUIml2JnpqqZUiJMPpF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-03-03 at 15:19 -0800, Sridhar Samudrala wrote:
> Check for handle ids when adding/deleting hash nodes OR
> adding/deleting
> filter entries and limit them to max number of links or header nodes
> supported(IXGBE_MAX_LINK_HANDLE).
>=20
> Start from bit 0 when setting hash table bit-map.(adapter->tables)
>=20
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 52
> +++++++++++++++++----------
> =C2=A01 file changed, 34 insertions(+), 18 deletions(-)

Dave I will add this to my queue
--=-ngUIml2JnpqqZUiJMPpF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW2MrQAAoJEOVv75VaS+3O+C8P/iV9DlyjJiLnWlmwk0TK6WLH
EHhH3QbSbIe7W7XsKX1CUzDo24p59eJT9yoOOPBGlphE86xDmGQByZpD5Tpc74na
061NdPqazBWR7qtNfkOQpVbU8As7BOFXK61LAvrTKgSkDJq8+zsOZ6R1Bz823RVQ
tgxait7StIcoWMhP45QzMq7h25Tr3IcDCP9x3j46DmcxLPA1cRyiSBrRHGlP+z/g
w6ixBCB+5ZCrBWAneSzP5csKcX9vthc4iCIQPSEPHLF6TyppvkCRwBqnD/Sr4JgE
CAJ72V95J0un8znWDwoxKH4X9Ja7/HDls+gljjYUA7p5Sp6F1KXlNMV7QNmPhK5w
xVItiJ0K+1ChlKwxviSfl7GBIHBj17LQNG5kMHNKFKeBpoZkOW2tiorzqg+uhtP5
/gEnVDaX5dcIStmOP453F3xdp8+KzoU8uj+wc2M0QGCWKGKUdqLOCh9GfuSdCNQW
dDVjHTQpLNmtxjtYSbpSIMXMeN8A7Oi1zsHoRlS9vYHitsEqM4EyyCR9v4UoXJxC
OjH/s/L3l3RTuGl3AXG1n2ZxsXqs7Ag0rCZ4zZJS9BlwrLbm9Vv1trnxBxKIkvTZ
E6JaAxc1vfvEK1WWZRBkc5k7grLAu779veCEODGGuMMFW5SlY4pUt/nLxyTv5KdX
7GCa6Squf17/AYw9rrQm
=O6ri
-----END PGP SIGNATURE-----

--=-ngUIml2JnpqqZUiJMPpF--
