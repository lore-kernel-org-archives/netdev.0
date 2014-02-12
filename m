From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH] USB2NET : SR9800 : One chip USB2.0 USB2NET SR9800 Device
 Driver Support
Date: Wed, 12 Feb 2014 11:12:46 +0100
Message-ID: <20140212101245.GA3409@ulmo.nvidia.com>
References: <1392010419-5217-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EVF5PPMfhYS0aIcm"
Cc: davem@davemloft.net, horms@verge.net.au, joe@perches.com,
	romieu@fr.zoreil.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, sunhecheng@vip.126.com
To: liujunliang_ljl@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392010419-5217-1-git-send-email-liujunliang_ljl@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 10, 2014 at 01:33:39PM +0800, liujunliang_ljl@163.com wrote:
> From: Liu Junliang <liujunliang_ljl@163.com>
>=20
>=20
> Signed-off-by: Liu Junliang <liujunliang_ljl@163.com>
> ---
>  drivers/net/usb/Kconfig  |   16 +
>  drivers/net/usb/Makefile |    1 +
>  drivers/net/usb/sr9800.c |  873 ++++++++++++++++++++++++++++++++++++++++=
++++++
>  drivers/net/usb/sr9800.h |  202 +++++++++++
>  4 files changed, 1092 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/usb/sr9800.c
>  create mode 100644 drivers/net/usb/sr9800.h
>=20
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 47b0f73..2551bf6 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -291,6 +291,22 @@ config USB_NET_SR9700
>  	  This option adds support for CoreChip-sz SR9700 based USB 1.1
>  	  10/100 Ethernet adapters.
> =20
> +config USB_NET_SR9800
> +	tristate "CoreChip-sz SR9800 based USB 2.0 10/100 ethernet devices"
> +	depends on USB_USBNET
> +	select CRC32
> +	default y

Why is this selected by default? I can see that some of the other USB
network drivers are also selected by default, but not all of them. Is
there some rule of thumb as to which should default to y and which
shouldn't?

Thierry

--EVF5PPMfhYS0aIcm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJS+0kdAAoJEN0jrNd/PrOhXvwQAJIW4vgv0NkyQVo5jSvzeLY4
9PFCrtd6N1n+O7P99x38JCCD9lWtfdin1EZfj+UicCanup2WzpyBWHeBhdSN4oZA
/+C+TgEIuX0+Be11IXeUOGMP9a3k/12HY3oHuz7BA2JjcK6PnfMxaEC7iGGJSjgz
q4Goa5kSqjvNgbP8h5bQPTNtMnRdsSytI7PMJbl4t1ho0V7H3pSo9zD7rxaPhmtE
v/18VQawGcY83Hr0B0Q18XAnNXaQMLZTvdhVfDUxB5VKT4Xhcri0m4adbAzMI9kR
K9CEChkDn68y13drJVILKqUjW+4LMQHAsQV07yl98Sqk7LYOedL9mQOnIL0crjWa
OAmLHwLv0ED25W1Hv3UdeSpBdIkO9cD0PCa7vHQnv7lpTlkaDyYelKLQ2D+GXrCw
1L/341ak9QEGiCU1TiOHDblnsN+OtCt0Pt+hijLHFl4TQKw3QIUoZLa4bQuDPM8M
juTSV63HRjiDlNGvtjBezlR9GFu5w3SJuNSNsFkZ7ADJwjz9On9JaDwH/Ad7AqmZ
ylE+zzbIpOWjyNToMH2dattpeVZkIfGkS02y6PcIx51EGMw5B8l6qKLB9YpkJpwR
7rhMYjpLKIn/6rRGlwmZKYnWYl7p/FdI0yOnVbtMYx406ivUNc+kgvmx5l1mXhT7
b8gKKYYA0pMEMXjgnkK1
=3y7X
-----END PGP SIGNATURE-----

--EVF5PPMfhYS0aIcm--
