From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool] ethtool: Report Backplane as supported port
Date: Thu, 27 Feb 2014 22:55:58 +0000
Message-ID: <1393541758.14067.75.camel@deadeye.wl.decadent.org.uk>
References: <1392918536-20444-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Nlh0J+zTWwC3sBbdX8m4"
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	agospoda@redhat.com
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46668 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751384AbaB0W4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:56:03 -0500
In-Reply-To: <1392918536-20444-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Nlh0J+zTWwC3sBbdX8m4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-20 at 18:48 +0100, Ivan Vecera wrote:
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  ethtool.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index 315d00f..acb4397 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -496,6 +496,8 @@ static void dump_supported(struct ethtool_cmd *ep)
>  		fprintf(stdout, "MII ");
>  	if (mask & SUPPORTED_FIBRE)
>  		fprintf(stdout, "FIBRE ");
> +	if (mask & SUPPORTED_Backplane)
> +		fprintf(stdout, "Backplane ");
>  	fprintf(stdout, "]\n");
> =20
>  	dump_link_caps("Supported", "Supports", mask, 0);

Applied, thanks.

Ben.

--=20
Ben Hutchings
It is easier to change the specification to fit the program than vice versa=
.

--=-Nlh0J+zTWwC3sBbdX8m4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUw/Cfue/yOyVhhEJAQoblQ//QSgLnntoZP3FK6372VcYdqmwF/0QVmPA
KfRnd0sUlgL3qb+CZgfy5YMRW4G7XIN1KWfkIcEExHIvNEH1mLr8uNyoHRTFXPPX
OZ2KQsr/scaL9Uh2BrGgRc9As5bZLW+PmmqrlK0lJPmR8xLYN/vs1Qf9ZDPitLP1
or6NGfSAxFWL5N1GMW9QfwXA5XABUIXddL+Iu9NCz+o1ae3vOC6No2hYPx1a5kbs
hNDC3UixKeEfogONaLbxgUHk9DTwT3gWF1xbg2gJ2GdXJOGECnDD0NcmsWwSxjGf
nhlzuoSK8UIw7iq92Ymsv1Es1qvCnIdDj2awflJteW1tBrQw1wWo69nKkoRWBJ2I
MmtAZo036684M2T4utxkNb3bfOApAMPnqFvVGOHvoBw2oO+Bi3JvfnpCTuHcRQYr
FvvObAtCYkskHO0Qxxo2VMUwl1lrtUUcedbI9JBELEbh0sDpVqPp5wJyfZZCq40B
CZpQHiIw+fY+UD9NzCyJxvmXh6+xvBYTETkyP0wB2MCMZfO3KS8OnJBI7cZ0ynX3
x+/2n3mDlwR8+psn37Qoyj/h8en26pj8/o9A3C4xD540t6TQumMrnQiLyzIiDM96
fqfDY+1CZbh5F2PZx0lSy74Xwh0zHNlmy33V936R4L5FNjDCkqmQ0KJGu08e5fxX
McL0lC9tevI=
=F7Ka
-----END PGP SIGNATURE-----

--=-Nlh0J+zTWwC3sBbdX8m4--
