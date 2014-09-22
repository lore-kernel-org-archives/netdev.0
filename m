From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH] batman-adv: fix potential NULL pointer dereferencing
Date: Mon, 22 Sep 2014 11:12:43 +0200
Message-ID: <541FE80B.7090108@meshcoding.com>
References: <DUB123-W2663266CEA8296935E9450A0B30@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="QIEvtgX74iXQCQ94BGgt2I8Q24IHaWgVC"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: mpirker@linux.com,
	"mareklindner@neomailbox.ch" <mareklindner@neomailbox.ch>,
	"sw@simonwunderlich.de" <sw@simonwunderlich.de>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DUB123-W2663266CEA8296935E9450A0B30@phx.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QIEvtgX74iXQCQ94BGgt2I8Q24IHaWgVC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable



On 22/09/14 11:11, Mario Pirker wrote:
> From b451e7317148e18bf6c5c8fd747d79ab34260354 Mon Sep 17 00:00:00 2001
> From: Mario Pirker <mario.pirker@kellogg.ox.ac.uk>
> Date: Tue, 16 Sep 2014 17:55:13 +0200
> Subject: [PATCH] batman-adv: fix potential NULL pointer dereferencing
>=20
> The call batadv_gw_node_get may return NULL. The return value has to
> be sanity checked before the pointer is dereferenced.
>=20
> Signed-off-by: Mario Pirker <mariopirker@hotmail.com>
> ---

We already have a patch queued to fix this issue
(http://permalink.gmane.org/gmane.org.freifunk.batman/12357).

Actually it is not about a missing check but it is more about a typo in
the check right below the one you added.

Cheers,

>  net/batman-adv/gateway_client.c | 5 +++++
>  1 file changed, 5 insertions(+)
>=20
> diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
> index 90cff58..7ee0913 100644
> --- a/net/batman-adv/gateway_client.c
> +++ b/net/batman-adv/gateway_client.c
> @@ -810,6 +810,11 @@ bool batadv_gw_out_of_range(struct batadv_priv *ba=
t_priv,
>                 goto out;
> =20
>         gw_node =3D batadv_gw_node_get(bat_priv, orig_dst_node);
> +
> +       /* gw_node can be NULL. We need to check before dereferencing *=
/
> +       if (gw_node =3D=3D NULL)
> +               goto out;
> +
>         if (!gw_node->bandwidth_down =3D=3D 0)
>                 goto out;
> =20
> --=20
> 1.8.1.4 		 	   		 =20
>=20

--=20
Antonio Quartulli


--QIEvtgX74iXQCQ94BGgt2I8Q24IHaWgVC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUH+gSAAoJEJgn97Bh2u9eUmQP/1Hwwemeea9m0S3/mo5591Uj
jPSO5o111irsOZvI0vDV06YbJxfPfZRkc4HDfTceo8EvA9Q9I4MMjp0epRx6g2tu
4F+ODVMKTrRhyHBre2MnExQw0xHV8fkIoPHMUqK/UT3Op3VVvnX2ct7/+7WXdzSP
7kRqQ8RrE/IdfhrHBCE38kzeqWRXiqQCSrkctrOF55du5aeeuBWVdVFkraUcvlII
XFhiLgnsnYVj5l7DjlUjnQSd8TDuVVoBpFYycDpSV+44+ARMo6QIvyLqieDpDStf
lNSdMgh3fLg3BwdN7YUngdVcjjy9qhj7vlOEl3fHx9zxyXQve0DLKeRkyCA5iVbT
oBJEgIuTpK/F+b3VAbdY5u1tNHC3d9IghxzsqEaKST1CTjfCP7RTWBp+PBm5JKWY
jGMN49RCstR4F58KR9Q47ABGQoB+3WUfLnXqvyRaV8GxpR49t/eAn7HHN/iaxOq9
H60tZc6GpFGSl2H3istaZu2E3rJey1LhJ1XQoJdAKrRZL48fzqUL7f+4EggQrqzQ
c+mPgRTy5J9E3VhqUwYDt0H5/GXV8YjHV3AJnIZr8VKEsruZ/je7bTS7c3zFdUah
PWl3hFnk3vVwVnGArba3GOeEQxzt+EQeqQHayJH1u4Ag9RosSv2EByKJR4KKHb4l
gSalG0OODuKvJeRawjLN
=xgGV
-----END PGP SIGNATURE-----

--QIEvtgX74iXQCQ94BGgt2I8Q24IHaWgVC--
