From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: export fixed_phy_register()
Date: Fri, 12 Dec 2014 04:31:48 -0800
Message-ID: <548AE034.7070700@gmail.com>
References: <1418357006-2450-1-git-send-email-msalter@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Mark Salter <msalter@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418357006-2450-1-git-send-email-msalter@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 11/12/2014 20:03, Mark Salter a =E9crit :
> When building the bcmgenet driver as module, I get:
>=20
> ERROR: "fixed_phy_register" [drivers/net/ethernet/broadcom/genet/gene=
t.ko] undefined!
>=20
> commit b0ba512e225d72 ("net: bcmgenet: enable driver to work without =
device
> tree") which added a call to fixed_phy_register. But fixed_phy_regist=
er
> needs to be exported if used from a module.
>=20
> Signed-off-by: Mark Salter <msalter@redhat.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

I will have to rework the GENET/SYSTEMPORT/SF2 dependencies anyway, tha=
nks!

> ---
>  drivers/net/phy/fixed.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index 47872caa..3ad0e6e 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -274,6 +274,7 @@ struct phy_device *fixed_phy_register(unsigned in=
t irq,
> =20
>  	return phy;
>  }
> +EXPORT_SYMBOL_GPL(fixed_phy_register);
> =20
>  static int __init fixed_mdio_bus_init(void)
>  {
>=20
