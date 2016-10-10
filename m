From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v4 10/10] ARM: sunxi: Enable sun8i-emac driver on
 multi_v7_defconfig
Date: Mon, 10 Oct 2016 14:30:46 +0200
Message-ID: <20161010123046.GH3462@lukather>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-11-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5528785308989539993=="
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1475828757-926-11-git-send-email-clabbe.montjoie@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============5528785308989539993==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fmEUq8M7S0s+Fl0V"
Content-Disposition: inline


--fmEUq8M7S0s+Fl0V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 07, 2016 at 10:25:57AM +0200, Corentin Labbe wrote:
> Enable the sun8i-emac driver in the multi_v7 default configuration
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  arch/arm/configs/multi_v7_defconfig | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi=
_v7_defconfig
> index 5845910..f44d633 100644
> --- a/arch/arm/configs/multi_v7_defconfig
> +++ b/arch/arm/configs/multi_v7_defconfig
> @@ -229,6 +229,7 @@ CONFIG_NETDEVICES=3Dy
>  CONFIG_VIRTIO_NET=3Dy
>  CONFIG_HIX5HD2_GMAC=3Dy
>  CONFIG_SUN4I_EMAC=3Dy
> +CONFIG_SUN8I_EMAC=3Dy

Any reason to build it statically?

Thanks,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--fmEUq8M7S0s+Fl0V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX+4n2AAoJEBx+YmzsjxAgwzEP/2nFEuUi5nk6qJuzFm1+KnwM
7iMrDhaMASeU0VR0lBXNcW+wD2iym1Z45grHqGQ9yFUnJINcPbO9QdlJ8Jc/uRNp
2gyFESX/nO5XsBXXfFR57IAVLAujTKYV5qTXaFqD+szO+JUTueb8gnuXeTPYT+iL
eO238u56svO5OFjoXn20dB3OnFLX6juiMz0awz7QJUGVvJkb22kXi22+z6xfx90G
rQZHTdmz31PULNCNeupQjsjC1yrxB7IofYBvehjxK+sjA3PvtQ0pL/+IDNsyRCfj
Aj0cOzklDK1eMHmby6fB1p8ZErzLfn3AEB0dhLjpqF0LbrIsN6bE+f6zroHTFRlG
YMhjRxlXDwwmj1RhRvMZ1aC1zKnhS5ED8HJUjn1vTcEPCURxmB4GQsE0XLZgK5iH
7y2bcSX6mPB8iFyKz/WIxJxXF8LulgPFH55O6X8PcTb8zb8IjsHiKfYtzPdajHRH
d6AQSAWbMQ6oyQCVlSa9qE7rmBQgpTWoOvNKToX0y4iGpv+446xLUEy7w/ZaSLxQ
la4rJHGG0jT1geiDunJC+mYs3PSAEB34H8WDFZpNQbT9NKcIidjlCSJ6lW2axujz
gwtcDXcjfD7Gdn2TXDVCcMN5JiO0WNZcgvOX0dRARjN6h428jCcVQzuwsHx5VhXg
jZceHeF2qbYJCD363kY6
=2DPL
-----END PGP SIGNATURE-----

--fmEUq8M7S0s+Fl0V--


--===============5528785308989539993==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============5528785308989539993==--
