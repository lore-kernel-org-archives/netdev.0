From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ptp_pch: Add missing #include <linux/slab.h>
Date: Wed, 16 May 2012 12:40:53 +0100
Message-ID: <1337168453.4107.44.camel@deadeye>
References: <1337157810-13494-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jb7ZWD/vVBfGAXqotaVW"
Cc: Takahiro Shimizu <tshimizu818@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337157810-13494-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jb7ZWD/vVBfGAXqotaVW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-05-16 at 10:43 +0200, Geert Uytterhoeven wrote:
> drivers/ptp/ptp_pch.c: In function 'pch_eth_enable_set':
> drivers/ptp/ptp_pch.c:152:2: error: implicit declaration of function 'ior=
ead32' [-Werror=3Dimplicit-function-declaration]
> drivers/ptp/ptp_pch.c:153:2: error: implicit declaration of function 'iow=
rite32' [-Werror=3Dimplicit-function-declaration]

<linux/io.h> might be more useful.

Ben.

> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Not even compile-tested, as it fails on parisc/xtensa only.
> http://kisskb.ellerman.id.au/kisskb/buildresult/6312813/
> http://kisskb.ellerman.id.au/kisskb/buildresult/6313050/
>=20
>  drivers/ptp/ptp_pch.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
> index 375eb04..6fff680 100644
> --- a/drivers/ptp/ptp_pch.c
> +++ b/drivers/ptp/ptp_pch.c
> @@ -30,6 +30,7 @@
>  #include <linux/module.h>
>  #include <linux/pci.h>
>  #include <linux/ptp_clock_kernel.h>
> +#include <linux/slab.h>
> =20
>  #define STATION_ADDR_LEN	20
>  #define PCI_DEVICE_ID_PCH_1588	0x8819

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-jb7ZWD/vVBfGAXqotaVW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT7OSRee/yOyVhhEJAQp0Gw//e/CvdaO3bSfbF3BLeyriaZ+5KdXYVIue
VyZ3p6hdgqP+13d1w6ZR5feUlyAr8iYpk6ErIXw8VjKbZa9Kd6M8ChoOD7jFZADw
VNoQB9vUdoChIAhYvgh/oDYERhOkFu4LbI7+1z4cDW6kHEBmFLlc9lDrulwL0dMe
f/Dzx94Xl35WDj2AIPjUt761ppkSZxJgKJXyAp4mO8R3zn8YZy0g/KekjDgS8DVv
7/XH9bnT5PKIpPI2JbGqpcs+tVwzh5ZkvDVXjf63tiyCjfSgPKy7WQ7eQNestyy2
1C+TLUawnYcBXoZcRkAeR5g2nOHylg5tXg6B8oei/LTLgoJAe0kqzGfE0wOvejIe
4ZqZqWwI8fWAXt0kjXKho09ROV+2AxGBGTfZemVEAi+GljY05ZJo4fpMtAX+Z9VI
/Ygkz+lBrNIHTLmTcyV1uGxSS9XULXBxSsH0IQT4fkmujWyNeJsQxTAwRXhcDwIQ
5RI8HngXtyOZHg2dCwvvksGuMqtbZyaIVJz1vLrC88xtAxGVMldgFna7NML3fJPB
eCi1hjsvkA7TKa4g8AZlLroUodmYBdxNLsG4dg8WxsUI304grDw9zfZt+MGRCCay
IlvvQQTkBGeSLsF3Eq+wQB6DkYRZgtCZRzE3itawsY7pZ6bHmzObgeG3Kz59ZHb3
l/QikI7WgkA=
=QH/M
-----END PGP SIGNATURE-----

--=-jb7ZWD/vVBfGAXqotaVW--
