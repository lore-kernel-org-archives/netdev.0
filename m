From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 14/14] batman-adv: drop dependency against CRC16
Date: Wed, 15 Jan 2014 14:16:12 +0100
Message-ID: <52D68A1C.3080302@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com> <1389652298-472-15-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="UKs1J24qX4uPImdPKPuXeqx54CfTCrUqK"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:32303 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbaAONR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 08:17:26 -0500
In-Reply-To: <1389652298-472-15-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UKs1J24qX4uPImdPKPuXeqx54CfTCrUqK
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 13/01/14 23:31, Antonio Quartulli wrote:
> The crc16 functionality is not used anymore, therefore
> we can safely remove the dependency in the Kbuild file.
>=20
> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>

David,

we just realized that this dependency is still needed by our module.
(also thanks to Fengguang Wu build bot!)

Could you please revert this patch only?
Or do you want me to send the "revert" on the netdev ml as a patch (or
pull request)?


Thanks a lot!


> ---
>  net/batman-adv/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
> index fa780b7..2b2dc47 100644
> --- a/net/batman-adv/Kconfig
> +++ b/net/batman-adv/Kconfig
> @@ -5,7 +5,6 @@
>  config BATMAN_ADV
>  	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
>  	depends on NET
> -	select CRC16
>  	select LIBCRC32C
>          default n
>  	help
>=20


--=20
Antonio Quartulli




--UKs1J24qX4uPImdPKPuXeqx54CfTCrUqK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS1oohAAoJEEKTMo6mOh1VUUoP/Rd2+AsWhMdan+Y4qJhq2MH8
iqi1qQw2g31valJxlZ2I3tdzLgPDys1Eedm7zhoyex2Tpxqx6wbauBqs4XDvPAgC
TZRjuB9P96lpqMxapD5BcnVjVwRN5KN/HdZmPQXwunv2x+B3Q1JHxMS7FJxeuaQE
DMk83eqoCL03BNTYUno5Z+UOvoDIZz7AkwuK8aM5XhsdR8XYBY+LJyGQhcPoo3yl
Ghfek+GmSUu85bOyjxF5iuHmPFt03+90vFPQGE6C75AbTnv5LS56gdCNSjTCIQN/
fQqwQzrPcHuPcDKhHRnKybat72CvZPGy8WL26VqOm9FJokTM5KnFzaSjCRJZw3nx
otPnfQRBNGtdwGqF0c91DS5FzB2WnuRKAvcyTDGxPEFUXk4prKPNGyDhbr0SPxoD
PqnRFfw4EfrR6zRK229+XWDYj9AYKvVaL5xhWssmCnbWshevY7T+3P2IbvEykKpc
pO3NAC3eLKwSrijWRFkR4s+/jOdg/LW4nZ+tUixlWI7CtX0p6g5cyTsqRb2IsiLx
sX5YSqTa/DGLOyd39sH8jSUK8c2HfIGpLnP32pChGMY+gLmuSwNvTIFY9mJ32sbM
hoOs71wuVENrKDK/KPC5RTKtK3j2TWuSLlXARPiZdujQLlRPkpUTQ4E8otfYdh4M
KBf3xp2ntlQs0K2TzYlx
=dXVB
-----END PGP SIGNATURE-----

--UKs1J24qX4uPImdPKPuXeqx54CfTCrUqK--
