From: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] of: mdio: fix compile warning in
 of_mdiobus_register_phy()
Date: Tue, 27 May 2014 12:16:28 +0100
Message-ID: <20140527111628.A11E1C4156C@trevor.secretlab.ca>
References: <1400880835-29537-1-git-send-email-cengelma@gmx.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
To: Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400880835-29537-1-git-send-email-cengelma-RbZlAiThDcE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 23 May 2014 23:33:55 +0200, Christian Engelmayer <cengelma@gmx.=
at> wrote:
> Commit de906af1 (net: phy: make of_set_phy_supported work with genphy=
 driver)
> removed the last user of variable 'max_speed' in function
> of_mdiobus_register_phy(), leading to compile warning "unused variabl=
e
> =E2=80=98max_speed=E2=80=99 [-Wunused-variable]". Thus remove it.
>=20
> Signed-off-by: Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
> ---
> Compile tested. Applies against branch master in tree
> git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

Acked-by: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

g.

> ---
>  drivers/of/of_mdio.c | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index b857094..7c6e277 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -46,7 +46,6 @@ static int of_mdiobus_register_phy(struct mii_bus *=
mdio, struct device_node *chi
>  	struct phy_device *phy;
>  	bool is_c45;
>  	int rc;
> -	u32 max_speed =3D 0;
>  	u32 phy_id;
> =20
>  	is_c45 =3D of_device_is_compatible(child,
> --=20
> 1.9.1
>=20

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
