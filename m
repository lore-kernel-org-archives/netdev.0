From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v9 06/10] arm64: dts: allwinner: Restore EMAC changes
Date: Fri, 27 Oct 2017 17:11:14 +0200
Message-ID: <20171027151114.ax2yhf75lbho2js5@flea>
References: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
 <20171024175714.15840-7-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="xamingy2657ieqdv"
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171024175714.15840-7-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xamingy2657ieqdv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 24, 2017 at 07:57:10PM +0200, Corentin Labbe wrote:
> The original dwmac-sun8i DT bindings have some issue on how to handle
> integrated PHY and was reverted in last RC of 4.13.
> But now we have a solution so we need to get back that was reverted.
>=20
> This patch restore arm64 DT about dwmac-sun8i
> This reverts commit 87e1f5e8bb4b ("arm64: dts: allwinner: Revert EMAC cha=
nges")
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts   | 16 ++++++++++++++=
++
>  .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts    | 15 +++++++++++++++
>  arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts  | 17 ++++++++++++++=
+++
>  .../dts/allwinner/sun50i-a64-sopine-baseboard.dts    | 16 ++++++++++++++=
++
>  arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi        | 20 ++++++++++++++=
++++++
>  .../boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts     | 17 ++++++++++++++=
+++
>  .../boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts    | 17 ++++++++++++++=
+++
>  .../boot/dts/allwinner/sun50i-h5-orangepi-prime.dts  | 17 ++++++++++++++=
+++
>  8 files changed, 135 insertions(+)

Can you split the changes between the A64 and the H5? It's going to be
difficult to merge otherwise.

(You also forgot to add Florian's Acked-by on your whole serie).

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--xamingy2657ieqdv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZ80ySAAoJEBx+YmzsjxAg90EP/3vi3XRH80OaUyXMehF8q71J
6FSZo9Heqby0iPuvdjdkwijNy0UWxgYdtdFbRkmDiyb52YcMnPQitJ4khaOCxnkt
mVdu7LAqQAwio7t4XKvnrXXniT9wG0O/WszKbzy0rhZI7NEdS5Fj6GccqCF9n23L
Lohy5OL/jz7AxtkJf1juJuYilNHixTRLfq9aSjt9FVrE3KPMvuqy4nVxU1kwM76w
qjdO91Kw3Kl6V1l6hvcKHA/I+WieoGwJprNRMVcA2ybI58TnBVGjeWw1yH7nD+ES
gTrvjHUTpDtTxQdwzogFDtvDxezHXxYKho+H2ruif2BYgrt8AAwiGHiPxuZN0cDe
wJ4AdgZJmnop+QVlpKCl/iBlpVRrwFCCApkT1Bav7xpn66k3g3Ae2aL/bozvdAtP
UqXG6+K/bDSZo+/I+xTJt4z9+llYjHoFkvmEC6Fj9MT1uhIoWAXH8OCETGU4ss75
qLxWOjwnXtUtS6F4mOSDU0MGylD0tH/6tPkeSD4KkNzg53Z0E9tdA8S9xMl5Z/tZ
8Nwbyzvgi9vPovBDx0Mka/l0GaNTdYf9LaJ4aHjc+7K2Ym1w/xX/lvTntSFRjmUe
hnZ0WW/QG46Kah6k34h6Osu095iiYJUSOlAh04Cc0tk6EnVcIpNNRM6M+jcFS9p7
GJ4f9QcbtTnXos4+UpoA
=5gK+
-----END PGP SIGNATURE-----

--xamingy2657ieqdv--
