From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] of: mdio: fix compile warning in of_mdiobus_register_phy()
Date: Fri, 23 May 2014 14:57:21 -0700
Message-ID: <CAGVrzcY6CCAFO-vrkB7+H+XfSnPT7uhF2VbDzY5YC_XYa7fTRg@mail.gmail.com>
References: <1400880835-29537-1-git-send-email-cengelma@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christian Engelmayer <cengelma@gmx.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400880835-29537-1-git-send-email-cengelma@gmx.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-05-23 14:33 GMT-07:00 Christian Engelmayer <cengelma@gmx.at>:
> Commit de906af1 (net: phy: make of_set_phy_supported work with genphy=
 driver)
> removed the last user of variable 'max_speed' in function
> of_mdiobus_register_phy(), leading to compile warning "unused variabl=
e
> =E2=80=98max_speed=E2=80=99 [-Wunused-variable]". Thus remove it.
>
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> Compile tested. Applies against branch master in tree
> git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> ---
>  drivers/of/of_mdio.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index b857094..7c6e277 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -46,7 +46,6 @@ static int of_mdiobus_register_phy(struct mii_bus *=
mdio, struct device_node *chi
>         struct phy_device *phy;
>         bool is_c45;
>         int rc;
> -       u32 max_speed =3D 0;
>         u32 phy_id;
>
>         is_c45 =3D of_device_is_compatible(child,
> --
> 1.9.1
>



--=20
=46lorian
