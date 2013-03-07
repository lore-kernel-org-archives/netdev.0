From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net 1/3] e1000e: fix pci-device enable-counter balance
Date: Thu, 07 Mar 2013 03:19:48 -0800
Message-ID: <1362655188.4164.37.camel@jtkirshe-mobl>
References: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1362654925-26088-2-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lTySrsg3Ae7IlYq6PRbP"
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Stable <stable@vger.kernel.org>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1362654925-26088-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lTySrsg3Ae7IlYq6PRbP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-03-07 at 03:15 -0800, Jeff Kirsher wrote:
> From: Konstantin Khlebnikov <khlebnikov@openvz.org>
>=20
> This patch removes redundant and unbalanced pci_disable_device() from
> __e1000_shutdown(). pci_clear_master() is enough, device can go into
> suspended state with elevated enable_cnt.
>=20
> Bug was introduced in commit 23606cf5d1192c2b17912cb2ef6e62f9b11de133
> ("e1000e / PCI / PM: Add basic runtime PM support (rev. 4)") in v2.6.35
>=20
> Cc: Bruce Allan <bruce.w.allan@intel.com>

CC: stable <stable@vger.kernel.org>

This time with the correct email for stable.

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Tested-by: Borislav Petkov <bp@suse.de>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/eth=
ernet/intel/e1000e/netdev.c
> index a177b8b..1799021 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -5986,7 +5986,7 @@ static int __e1000_shutdown(struct pci_dev *pdev, b=
ool *enable_wake,
>  	 */
>  	e1000e_release_hw_control(adapter);
> =20
> -	pci_disable_device(pdev);
> +	pci_clear_master(pdev);
> =20
>  	return 0;
>  }



--=-lTySrsg3Ae7IlYq6PRbP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJROHfUAAoJEOVv75VaS+3OaMAP/1+uu/V7bFpTDw01a6snLheD
nnnruma296iAWZHmhx8MvX9hfa/G1XxCdXr1KLXA8U61CW3/4IemO6LL2SqwDli8
TQfx7bqLT6eN6+knDH0hMbgSknQRCfKjZTvLLoJSFjuYe/23m0IiswXJWf6AKH19
Bf6LKHp2bxZ7eVElDDXi6zvnZz3cHtcmDbtO7QXxNSVh0kXzQJsf1NNgEqAxh/Qz
yAlT5V1rKcDVipknr7Jfczu7sYHOzaqmn4TlbaZCCVz4I/gPDL24xXtmolXiQ+gQ
FDFlmSAVEPBipi9jbHACbgQH7e8fZQJRH1eG16Ry744luOadW1laa1uYAa/9ruVW
cWXeObq6LYuUxhFyRf4Pkv7OVrgztJMnZxCT6myKZqeYPPGOmMk5HvLfFNTutjHj
86Z3nZjTP3qQ1Hx0dyWtvxCBn+lKT/ToLdvRlzT3vJIO82BLlsx0horQz6AmyuQy
U7CHDukMqb/yj3joCz+TAzQ/rNf5QpZRe17FCmbnPpw6fv467hwPsGs2Kqh81tzZ
LCHhikPYCDM9Z2r+H/4jK4G8vewMAgB8GMJlRksRzn+h2Xj7X2DqU0vEYn/MJSWV
4/tistTbAT1u5jOwVfWxLMirefFLrFhCaetVpj48J5ylhG1eYGQjSblOrEsl6RnT
LpXVJDCOIqQol+DhYYMl
=gNEy
-----END PGP SIGNATURE-----

--=-lTySrsg3Ae7IlYq6PRbP--
