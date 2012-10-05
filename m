From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 4/20 V2] drivers/net/can/sja1000/peak_pcmcia.c: fix error
 return code
Date: Fri, 05 Oct 2012 23:07:06 +0200
Message-ID: <506F4BFA.2090006@pengutronix.de>
References: <1349469667-6137-1-git-send-email-peter.senna@gmail.com> <1349469667-6137-4-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig761A2545C156F724C8D92326"
Cc: wg@grandegger.com, linux@dominikbrodowski.net,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1349469667-6137-4-git-send-email-peter.senna@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig761A2545C156F724C8D92326
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/05/2012 10:41 PM, Peter Senna Tschudin wrote:
> From: Peter Senna Tschudin <peter.senna@gmail.com>
>=20
> The function pcan_probe() return 0 for success and negative value
> for most of its internal tests failures. There is one exception
> that is error case going to probe_err_4:. Fore this error case, the
> function abort its success execution path but returns non negative
> value, making it difficult for a caller function to notice the error.
>=20
> This patch fixes the error case that do not return negative value.
>=20
> This was found by Coccinelle, but the code change was made by hand.
> This patch is not robot generated.
>=20
> A simplified version of the semantic match that finds this problem is
> as follows: (http://coccinelle.lip6.fr/)
>=20
> // <smpl>
> (
> if@p1 (\(ret < 0\|ret !=3D 0\))
>  { ... return ret; }
> |
> ret@p1 =3D 0
> )
> ... when !=3D ret =3D e1
>     when !=3D &ret
> *if(...)
> {
>   ... when !=3D ret =3D e2
>       when forall
>  return ret;
> }
> // </smpl>
>=20
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>


Too late, v1 of this patch is already in net/master

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig761A2545C156F724C8D92326
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBvS/oACgkQjTAFq1RaXHMZ+QCgl76N92Yd2LChjRYEORSnHUs+
IcIAnjIp88hNdwK7TewfxgbeYr4dqhU0
=/ldX
-----END PGP SIGNATURE-----

--------------enig761A2545C156F724C8D92326--
