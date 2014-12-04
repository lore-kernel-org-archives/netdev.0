From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2] drivers: net : cpsw: Update Kconfig for CPSW
Date: Thu, 4 Dec 2014 08:48:30 -0600
Message-ID: <20141204144830.GB18045@saruman>
References: <1417668869-25616-1-git-send-email-lokeshvutla@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Yylu36WmvOXNoKYn"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
	<grygorii.strashko@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<t-kristo@ti.com>
To: Lokesh Vutla <lokeshvutla@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417668869-25616-1-git-send-email-lokeshvutla@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Yylu36WmvOXNoKYn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 04, 2014 at 10:24:29AM +0530, Lokesh Vutla wrote:
> CPSW is present in AM33xx, AM43xx, DRA7xx.
> Updating the Kconfig to depend on ARCH_OMAP2PLUS instead of listing
> all SoC's.
>=20
> Signed-off-by: Lokesh Vutla <lokeshvutla@ti.com>

Reviewed-by: Felipe Balbi <balbi@ti.com>

> ---
>  drivers/net/ethernet/ti/Kconfig | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kc=
onfig
> index 5d8cb79..7051255 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -5,7 +5,7 @@
>  config NET_VENDOR_TI
>  	bool "Texas Instruments (TI) devices"
>  	default y
> -	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3 ||=
 SOC_AM33XX || ARCH_KEYSTONE))
> +	depends on PCI || EISA || AR7 || ARCH_DAVINCI || ARCH_OMAP2PLUS || ARCH=
_KEYSTONE
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y
>  	  and read the Ethernet-HOWTO, available from
> @@ -32,7 +32,7 @@ config TI_DAVINCI_EMAC
> =20
>  config TI_DAVINCI_MDIO
>  	tristate "TI DaVinci MDIO Support"
> -	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX || ARCH_KE=
YSTONE )
> +	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS || ARCH_KEYSTONE
>  	select PHYLIB
>  	---help---
>  	  This driver supports TI's DaVinci MDIO module.
> @@ -42,7 +42,7 @@ config TI_DAVINCI_MDIO
> =20
>  config TI_DAVINCI_CPDMA
>  	tristate "TI DaVinci CPDMA Support"
> -	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX )
> +	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
>  	---help---
>  	  This driver supports TI's DaVinci CPDMA dma engine.
> =20
> @@ -58,7 +58,7 @@ config TI_CPSW_PHY_SEL
> =20
>  config TI_CPSW
>  	tristate "TI CPSW Switch Support"
> -	depends on ARM && (ARCH_DAVINCI || SOC_AM33XX)
> +	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
>  	select TI_DAVINCI_CPDMA
>  	select TI_DAVINCI_MDIO
>  	select TI_CPSW_PHY_SEL
> --=20
> 1.9.1
>=20

--=20
balbi

--Yylu36WmvOXNoKYn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUgHQ+AAoJEIaOsuA1yqREuZMP/RuJtb2Fy+UpqZPtSTQ/q8/Y
CBkQ8M+azi2yQIb+NlEKgE/DLLCIJfMjTOk67Ac6AzgP4OaJLl9N/X/3axyeHuTd
GYPXM89xmQdz9LD6R5bUEIrRK2J3zXsJ+lJh/CPKRPYP1vMZoqdl3eZv2IJt3wb2
prYaZseXWdSY/OzsVwflLB1DnhI/6fgy9j3M0zRQsnWHZokc6Deg9EP+YGYdoDP7
7XVS1kmHPlpw4VQJubL+VpECglLxVuKAmMD7S+UKWJUKVe8aYgRNnBi8AyTN7MKn
glPEi8cDZYhFdShMozuR31pJojiTgS8IWXMcNXXu1sJzsHSWq7gDc58o2JQ9toDU
LwCCt2TlShlqdpVnG7d2T3/FPGjJbweKKU/XIZwWqVBAnh8kPZWIezQlqUN8ttjg
vdGCU/LgzsyXGtHDVcQZkYUmOShYLS5iSffFGajdCu1O9uIOeclQ7eML3xix/L43
oJwb0byXfkJpAH5a1BICRcQr0BI303usroMuENr88PLo0BsQ+MEqFHzTav464y2g
PIrq9tjYh74MmTOlsqKOFBv/Ihey3jnipEIho0KnKkDsK2QQaoyqCQQeIiPbN6ST
DXvtJCxlLVrNHdz6xUrIi5MvqIevERKcNQKWSdET4DHV30rZbL1IdYKXBsS9Z0eU
av5FOlsLmi2rW0n7PeIV
=B3YQ
-----END PGP SIGNATURE-----

--Yylu36WmvOXNoKYn--
