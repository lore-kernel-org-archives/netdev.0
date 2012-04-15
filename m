From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] net: vxge: Add MODULE_FIRMWARE
Date: Sun, 15 Apr 2012 14:56:55 +0100
Message-ID: <1334498215.3209.4.camel@deadeye>
References: <1334262882-96973-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Qyr72/ocTHZVrdke0YQN"
Cc: linux-kernel@vger.kernel.org, Jon Mason <jdmason@kudzu.us>,
	netdev@vger.kernel.org
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334262882-96973-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Qyr72/ocTHZVrdke0YQN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-04-12 at 14:34 -0600, Tim Gardner wrote:
> Cc: Jon Mason <jdmason@kudzu.us>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> ---
>  drivers/net/ethernet/neterion/vxge/vxge-main.c |    2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net=
/ethernet/neterion/vxge/vxge-main.c
> index 51387c3..dcef72d 100644
> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> @@ -4856,3 +4856,5 @@ vxge_closer(void)
>  }
>  module_init(vxge_starter);
>  module_exit(vxge_closer);
> +MODULE_FIRMWARE("vxge/X3fw-pxe.ncf");
> +MODULE_FIRMWARE("vxge/X3fw.ncf");

I don't agree; these firmware files are updates for the flash and only
need to be loaded once.

Also: this driver's behaviour of automatically updating flash without
any confirmation seems quite dangerous.  The driver also isn't usable
after it performs such an update:

	printk(KERN_NOTICE "Upgrade of firmware successful!  Adapter must be "
	       "hard reset before using, thus requiring a system reboot or a "
	       "hotplug event.\n");

So what is the point of integrating firmware update into the driver at
all?

Ben.

--=20
Ben Hutchings
It is easier to change the specification to fit the program than vice versa=
.

--=-Qyr72/ocTHZVrdke0YQN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT4rTp+e/yOyVhhEJAQq5KQ//VwSf6MH/Jv+lLOFzACmeaWTl4HKN07CP
NCKDBhRpW2mMgfFyeljrLN7MMK7sVBr22sL31A4u5LwKVyrG8ZfxDLke1m8tmFbW
Xx9Nr9or7AlUIB8Fu3yLmdWFO1Qo8xa/DMQju2J3LUxI0KoUh3GbkRkEDIY7SYa9
GZ0pffTknvsePwcu+cihOfwg5vxGDAo31CXSl9ax6YQe5u/Qjz61cGUkMOwTSjwA
kv5xWkGw9lwauAW2e/aTE6r7CYH2fQJ+zrZAvFT/nbreeOioYBW0ImG7ZpSocCBA
u23Jq0vusfLEITUB0OnTkLBvxV7pZfRoE5KQt4WLsVreiecyesxGhO/XJxeVl8jv
q7M2EPNkopzuP2HBnBguktOTf2T3UGg5SPYFH1eTNZyJ+xonXLl9dLWofHVq5jd7
4ZvyUyL9liZoDBWqL8DVIKbDUaF2EPexXQsYm9tttO6af3pBHF7SZ8Y75gu5vbTn
c51bm6rvD/nimHWRFxTdGnq8iRjuyvMN2I56ZG0mNVTf2WFKdremtovemx42EZZt
KyWycthDyIturskkEt+gK/8o+tkUbHt3tItUcwJS3jTCkIEmLuhPWbbdGdirw5aE
jk3Ms4PttAQ/XoCqANwRl9eYgpuNiT/q6u+PSYpL/gruU6npNPUFQHfKPIO7oblB
/GsbrIjcdbM=
=XXn9
-----END PGP SIGNATURE-----

--=-Qyr72/ocTHZVrdke0YQN--
