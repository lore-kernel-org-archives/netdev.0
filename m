From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 4/6] alx: separate link speed/duplex fields
Date: Fri, 21 Jun 2013 13:37:29 +0100
Message-ID: <1371818249.8771.19.camel@deadeye.wl.decadent.org.uk>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
	 <1371766494-18979-5-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lGaccNuRS94N+gL3N/2x"
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36286 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161196Ab3FUMhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 08:37:35 -0400
In-Reply-To: <1371766494-18979-5-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lGaccNuRS94N+gL3N/2x
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-06-21 at 00:14 +0200, Johannes Berg wrote:
> As suggested by Ben Hutchings, use separate fields to track
> current link speed and duplex setting.
>=20
> Reported-by: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
>  drivers/net/ethernet/atheros/alx/ethtool.c |  35 ++------
>  drivers/net/ethernet/atheros/alx/hw.c      | 136 ++++++++++++-----------=
------
>  drivers/net/ethernet/atheros/alx/hw.h      |  24 ++++-
>  drivers/net/ethernet/atheros/alx/main.c    |  37 ++++----
>  4 files changed, 106 insertions(+), 126 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/eth=
ernet/atheros/alx/ethtool.c
> index 50a91d0..2170b61 100644
> --- a/drivers/net/ethernet/atheros/alx/ethtool.c
> +++ b/drivers/net/ethernet/atheros/alx/ethtool.c
> @@ -58,7 +58,8 @@ static int alx_get_settings(struct net_device *netdev, =
struct ethtool_cmd *ecmd)
>  			  SUPPORTED_100baseT_Full |
>  			  SUPPORTED_Autoneg |
>  			  SUPPORTED_TP |
> -			  SUPPORTED_Pause;
> +			  SUPPORTED_Pause |
> +			  SUPPORTED_Asym_Pause;
>  	if (alx_hw_giga(hw))
>  		ecmd->supported |=3D SUPPORTED_1000baseT_Full;
>=20
[...]

This hunk belongs in patch 6.

Otherwise, I think this is fine, but I didn't look too closely.

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.

--=-lGaccNuRS94N+gL3N/2x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUcRJCee/yOyVhhEJAQoa6BAAwDSbgt6eloOhtaV7sznInTKq0ZIV+rN7
TANsyovCvNZT1ppqPZJctvzvuIk5X4TnGrApDeecfLYuNIjmLa682drxA35cTVIc
LLIabyKFBH/HPqr3L+7uRgPrZtjsV1WOSt0a/6DQTfmwvOYeRPOBu1dc3N2qhSN9
5e0D7HLTDsASjJFjj19knqkSKIkdmWSr0DiGywz9EVM0ZIR0K3tsWms3UJyA+4Iy
WKw9YI5kMB1L75krdt7MHkwE0T4HjjBiobyp/w+C86fdvQaaRKojl8wbPsLNrLML
4zCQOC9tRL+nul6wP2WLag40vUPbY+3Dwa4Lxh2DGQ44GiYTvXxJ40llAW4fPAne
jvqfSmgBSpCLUjwvftDepLr8f+erFWpN1Q0x6CLvPkW+mgobTtu5jJwWFebKtkku
jFAX1mwOuV39NJAf9YkxPkg61bwgHSsdB4SZacHEvDCl4uk5rXXGy4p+shU0xTY+
8RNeH7jG4L+522UP5aq+Ry47I7yRA5yQpX/gaCQmF/aBD824s5PtcxLz4WFag8re
scQPTtI5ie/9DYeol3Qf/BluWE4Xgxx/l2r7TH+k3YacO2SNbcQUQxPi9MKHrCQa
BFd0q5d/LuyXU7oisg0+Dq2FT+MIXW/MRfFW6DIkb4Xptaqodv6Q5K68wf2rOVlU
r7nF/cdF2Yg=
=duaB
-----END PGP SIGNATURE-----

--=-lGaccNuRS94N+gL3N/2x--
