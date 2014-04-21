From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 1/2] ixgbe: missing "static" in function
 definition
Date: Mon, 21 Apr 2014 22:35:27 +0100
Message-ID: <1398116127.3624.156.camel@deadeye.wl.decadent.org.uk>
References: <1396494376-6521-1-git-send-email-crrodriguez@opensuse.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hXq7C/9G+4z2dE03+bwK"
Cc: netdev@vger.kernel.org
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51230 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753870AbaDUVfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 17:35:32 -0400
In-Reply-To: <1396494376-6521-1-git-send-email-crrodriguez@opensuse.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hXq7C/9G+4z2dE03+bwK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-04-03 at 00:06 -0300, Cristian Rodr=C3=ADguez wrote:
> Signed-off-by: Cristian Rodr=C3=ADguez <crrodriguez@opensuse.org>
> ---
>  ixgbe.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/ixgbe.c b/ixgbe.c
> index 6a663e4..3928d77 100644
> --- a/ixgbe.c
> +++ b/ixgbe.c
> @@ -76,7 +76,7 @@ enum ixgbe_mac_type {
>  	ixgbe_num_macs
>  };
> =20
> -enum ixgbe_mac_type
> +static enum ixgbe_mac_type
>  ixgbe_get_mac_type(u16 device_id)
>  {
>  	enum ixgbe_mac_type mac_type =3D ixgbe_mac_unknown;

Applied, thanks.

Ben.

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-hXq7C/9G+4z2dE03+bwK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1WPH+e/yOyVhhEJAQoo5RAApX5UzLkaCtpORkOe5f3bQGFJoML1STgx
RzNFGLbDVrFIS3L96xdwy5QzoBIrfPcx43boS1hgP743DVUJlt778zEOv1DMmT/p
+gwWaV3Xg5wLQS/sgjpXca0SSCOO5Ct0joOnBnMdmgwT+awXzZLIzkiCWpXg2m7u
N7Qb6hURLQzGp4F+dNqbo3iKbxYban9UtwEY0DiUIipV/DqPzRsX3LfFBowtSrJV
w2bydvgoCVLUBW/1wDbG+1Gj2Z0hvAVBBQA9COhcfNLMtprwLNxgG3g1yNQxfxeR
KRC2+HJS1Uj0K9aZiWVAGWa/OPhOAG8EC1ybTa6KJKtDgyWfegtOONO/fNRFg1Aq
ct6+bnoaY1asidShZeJ3RMeZdNC4bUr5cXx8mB6IjsQqWYJNG9elNqIhrZCE78Tx
Tgf1eeuvbISh80btlJfjrkSk9fbALkXxccMHcRPXhKBhrhSj9f8g0s6qapw3jFio
6K7+Yxnj1OIrCyFVddY4NpfvanRWW94hSwitLMYcRn7q305jsjbu5HrGa7P+Uzpe
reNV5sp0GZQUfs8v2XMWggDj5kcHqjnCmLEuJENw+0XbL73xAtv8h6QZoUNedduV
kIv+MLy4n0kTGcy3Z81Zya9CwdsIlEtsX5jeSDYjUnKcejzE9QlmJ58Hok7G4jE+
vfGMcWwcDhU=
=EXTA
-----END PGP SIGNATURE-----

--=-hXq7C/9G+4z2dE03+bwK--
