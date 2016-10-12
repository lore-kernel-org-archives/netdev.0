From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v4 08/10] ARM: dts: sun8i: Enable sun8i-emac on the
 Orange Pi 2
Date: Wed, 12 Oct 2016 11:03:29 +0200
Message-ID: <20161012090329.GA9245@lukather>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-9-git-send-email-clabbe.montjoie@gmail.com>
 <20161012105559.aaf9122e376fa5969a2e61d9@free.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Cc: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161012105559.aaf9122e376fa5969a2e61d9-GANU6spQydw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 12, 2016 at 10:55:59AM +0200, Jean-Francois Moine wrote:
> On Fri,  7 Oct 2016 10:25:55 +0200
> Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>=20
> > The sun8i-emac hardware is present on the Orange PI 2.
> > It uses the internal PHY.
> >=20
> > This patch create the needed emac node.
> >=20
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  arch/arm/boot/dts/sun8i-h3-orangepi-2.dts | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> >=20
> > diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts b/arch/arm/boot/=
dts/sun8i-h3-orangepi-2.dts
> > index f93f5d1..5608eb4 100644
> > --- a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
> > +++ b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
> > @@ -54,6 +54,7 @@
> > =20
> >  	aliases {
> >  		serial0 =3D &uart0;
> > +		ethernet0 =3D &emac;
>=20
> As there is no 'of_alias_get_id' in the driver, this alias is
> useless.

Not really, this is used by U-Boot to set the mac address.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX/fxhAAoJEBx+YmzsjxAgANQP/1kXOutnxZzmCTV/jDTDS2U3
/vnJBR5QejIy5zG/ReNbzRWVGScDfZUGyjIGT55DC8iwEWQBHi3Xec/iqAlMQEVq
+BNXtV6mHQtbdn8IBvuZmVYlw9lh69kyAxSQCz4bNwCErnTcshWndxDRRJcXIp6P
q3S/h+64wY8izls1i55TzA9rWdfXfhHHmNhwf6If5KMmIytlLM7d3TQRt2IZiMu/
kqUB5Df3AhyCt20EtYREf0g7vD62MF/ZviwJyeamWgug8dPVkyBNVbG+majbn8mQ
gqtEE1mD/ZUVp9ZYtTaY0S4Ikz9bWXBSfbrst6ZCXI+zF/OGMWuChC3voI3lNrLV
UyOaubH1VVGl7570uJe4PVgEi3ty7Mg8Fz+ynaaEjZhidcQhgcq4+uVYCzXq1QM+
b7FCKR8G8AJjL5cB2Fcg7eCjw+vO4x8L66389mxvvHfl9TRFVqvoZPNLVLrDPZqj
KCe9YXS6jNyZ/GD+6F+08W/V1Esn+9zeF1/mIeggfPurkf4uYtrttok+p7BMCevW
ebkd/iV4EJOLjZVTNbRu/lp5FqPw9Wcx2alotRQxQsOSUzzy3mPpwQValTdCaTRz
tXkzgOcfjCn7krechDcdrpOIhAClOiR/En1b8LYsB6OsbvyU3E6JYWTb7lOXzQJl
c+r1ufFD4jE8bOyfFlnD
=0R/g
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
