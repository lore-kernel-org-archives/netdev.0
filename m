From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 1/3] driver net: cpsw: Convert pr_*() to dev_*() calls
Date: Fri, 2 May 2014 09:16:48 -0500
Message-ID: <20140502141624.GA4631@saruman.home>
References: <1399026017-734-1-git-send-email-george.cherian@ti.com>
 <1399026017-734-2-git-send-email-george.cherian@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LpQ9ahxlCli8rRTG"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <davem@davemloft.net>, <balbi@ti.com>,
	<zonque@gmail.com>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>
To: George Cherian <george.cherian@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1399026017-734-2-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--LpQ9ahxlCli8rRTG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 02, 2014 at 03:50:15PM +0530, George Cherian wrote:
> Convert all pr_*() calls to dev_*() calls.
>=20
> Signed-off-by: George Cherian <george.cherian@ti.com>

Reviewed-by: Felipe Balbi <balbi@ti.com>

> ---
>  drivers/net/ethernet/ti/cpsw.c | 50 +++++++++++++++++++++---------------=
------
>  1 file changed, 25 insertions(+), 25 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cps=
w.c
> index d14c8da..9512738 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1808,25 +1808,25 @@ static int cpsw_probe_dt(struct cpsw_platform_dat=
a *data,
>  		return -EINVAL;
> =20
>  	if (of_property_read_u32(node, "slaves", &prop)) {
> -		pr_err("Missing slaves property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing slaves property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->slaves =3D prop;
> =20
>  	if (of_property_read_u32(node, "active_slave", &prop)) {
> -		pr_err("Missing active_slave property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing active_slave property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->active_slave =3D prop;
> =20
>  	if (of_property_read_u32(node, "cpts_clock_mult", &prop)) {
> -		pr_err("Missing cpts_clock_mult property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing cpts_clock_mult property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->cpts_clock_mult =3D prop;
> =20
>  	if (of_property_read_u32(node, "cpts_clock_shift", &prop)) {
> -		pr_err("Missing cpts_clock_shift property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing cpts_clock_shift property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->cpts_clock_shift =3D prop;
> @@ -1838,31 +1838,31 @@ static int cpsw_probe_dt(struct cpsw_platform_dat=
a *data,
>  		return -ENOMEM;
> =20
>  	if (of_property_read_u32(node, "cpdma_channels", &prop)) {
> -		pr_err("Missing cpdma_channels property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing cpdma_channels property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->channels =3D prop;
> =20
>  	if (of_property_read_u32(node, "ale_entries", &prop)) {
> -		pr_err("Missing ale_entries property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing ale_entries property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->ale_entries =3D prop;
> =20
>  	if (of_property_read_u32(node, "bd_ram_size", &prop)) {
> -		pr_err("Missing bd_ram_size property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing bd_ram_size property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->bd_ram_size =3D prop;
> =20
>  	if (of_property_read_u32(node, "rx_descs", &prop)) {
> -		pr_err("Missing rx_descs property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing rx_descs property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->rx_descs =3D prop;
> =20
>  	if (of_property_read_u32(node, "mac_control", &prop)) {
> -		pr_err("Missing mac_control property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing mac_control property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->mac_control =3D prop;
> @@ -1876,7 +1876,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data =
*data,
>  	ret =3D of_platform_populate(node, NULL, NULL, &pdev->dev);
>  	/* We do not want to force this, as in some cases may not have child */
>  	if (ret)
> -		pr_warn("Doesn't have any child node\n");
> +		dev_warn(&pdev->dev, "Doesn't have any child node\n");
> =20
>  	for_each_child_of_node(node, slave_node) {
>  		struct cpsw_slave_data *slave_data =3D data->slave_data + i;
> @@ -1893,7 +1893,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data =
*data,
> =20
>  		parp =3D of_get_property(slave_node, "phy_id", &lenp);
>  		if ((parp =3D=3D NULL) || (lenp !=3D (sizeof(void *) * 2))) {
> -			pr_err("Missing slave[%d] phy_id property\n", i);
> +			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);
>  			return -EINVAL;
>  		}
>  		mdio_node =3D of_find_node_by_phandle(be32_to_cpup(parp));
> @@ -1918,18 +1918,18 @@ static int cpsw_probe_dt(struct cpsw_platform_dat=
a *data,
> =20
>  		slave_data->phy_if =3D of_get_phy_mode(slave_node);
>  		if (slave_data->phy_if < 0) {
> -			pr_err("Missing or malformed slave[%d] phy-mode property\n",
> -			       i);
> +			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property=
\n",
> +				i);
>  			return slave_data->phy_if;
>  		}
> =20
>  		if (data->dual_emac) {
>  			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
>  						 &prop)) {
> -				pr_err("Missing dual_emac_res_vlan in DT.\n");
> +				dev_err(&pdev->dev, "Missing dual_emac_res_vlan in DT.\n");
>  				slave_data->dual_emac_res_vlan =3D i+1;
> -				pr_err("Using %d as Reserved VLAN for %d slave\n",
> -				       slave_data->dual_emac_res_vlan, i);
> +				dev_err(&pdev->dev, "Using %d as Reserved VLAN for %d slave\n",
> +					slave_data->dual_emac_res_vlan, i);
>  			} else {
>  				slave_data->dual_emac_res_vlan =3D prop;
>  			}
> @@ -1953,7 +1953,7 @@ static int cpsw_probe_dual_emac(struct platform_dev=
ice *pdev,
> =20
>  	ndev =3D alloc_etherdev(sizeof(struct cpsw_priv));
>  	if (!ndev) {
> -		pr_err("cpsw: error allocating net_device\n");
> +		dev_err(&pdev->dev, "cpsw: error allocating net_device\n");
>  		return -ENOMEM;
>  	}
> =20
> @@ -1969,10 +1969,10 @@ static int cpsw_probe_dual_emac(struct platform_d=
evice *pdev,
>  	if (is_valid_ether_addr(data->slave_data[1].mac_addr)) {
>  		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
>  			ETH_ALEN);
> -		pr_info("cpsw: Detected MACID =3D %pM\n", priv_sl2->mac_addr);
> +		dev_info(&pdev->dev, "cpsw: Detected MACID =3D %pM\n", priv_sl2->mac_a=
ddr);
>  	} else {
>  		random_ether_addr(priv_sl2->mac_addr);
> -		pr_info("cpsw: Random MACID =3D %pM\n", priv_sl2->mac_addr);
> +		dev_info(&pdev->dev, "cpsw: Random MACID =3D %pM\n", priv_sl2->mac_add=
r);
>  	}
>  	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
> =20
> @@ -2010,7 +2010,7 @@ static int cpsw_probe_dual_emac(struct platform_dev=
ice *pdev,
>  	SET_NETDEV_DEV(ndev, &pdev->dev);
>  	ret =3D register_netdev(ndev);
>  	if (ret) {
> -		pr_err("cpsw: error registering net device\n");
> +		dev_err(&pdev->dev, "cpsw: error registering net device\n");
>  		free_netdev(ndev);
>  		ret =3D -ENODEV;
>  	}
> @@ -2032,7 +2032,7 @@ static int cpsw_probe(struct platform_device *pdev)
> =20
>  	ndev =3D alloc_etherdev(sizeof(struct cpsw_priv));
>  	if (!ndev) {
> -		pr_err("error allocating net_device\n");
> +		dev_err(&pdev->dev, "error allocating net_device\n");
>  		return -ENOMEM;
>  	}
> =20
> @@ -2047,7 +2047,7 @@ static int cpsw_probe(struct platform_device *pdev)
>  	priv->cpts =3D devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL=
);
>  	priv->irq_enabled =3D true;
>  	if (!priv->cpts) {
> -		pr_err("error allocating cpts\n");
> +		dev_err(&pdev->dev, "error allocating cpts\n");
>  		goto clean_ndev_ret;
>  	}
> =20
> @@ -2060,7 +2060,7 @@ static int cpsw_probe(struct platform_device *pdev)
>  	pinctrl_pm_select_default_state(&pdev->dev);
> =20
>  	if (cpsw_probe_dt(&priv->data, pdev)) {
> -		pr_err("cpsw: platform data missing\n");
> +		dev_err(&pdev->dev, "cpsw: platform data missing\n");
>  		ret =3D -ENODEV;
>  		goto clean_runtime_disable_ret;
>  	}
> @@ -2068,10 +2068,10 @@ static int cpsw_probe(struct platform_device *pde=
v)
> =20
>  	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
>  		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
> -		pr_info("Detected MACID =3D %pM\n", priv->mac_addr);
> +		dev_info(&pdev->dev, "Detected MACID =3D %pM\n", priv->mac_addr);
>  	} else {
>  		eth_random_addr(priv->mac_addr);
> -		pr_info("Random MACID =3D %pM\n", priv->mac_addr);
> +		dev_info(&pdev->dev, "Random MACID =3D %pM\n", priv->mac_addr);
>  	}
> =20
>  	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
> --=20
> 1.8.3.1
>=20

--=20
balbi

--LpQ9ahxlCli8rRTG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTY6jQAAoJEIaOsuA1yqREvtoP/3OkvrnfmNjrFzXgq0rdqnjK
AmfnVEjEpVKkq9pAgrJUOCuBQ+H6rnRiRMxZ6HRDqTy6Om/I0ZVAMDIMNo1TSh1O
66HjYEMok77dL6BcoHERf2wBZowb2hl4cLUEI3e9NMgYMSTQ7O18vwFXuGQANlf3
DCT1CWOjm0nIrRGJOmd1wSdXwpoKd9zyMsQiguBK+zp4hemDvtJid1xSWiyS9e90
vTM+Bvwte5Wb0rkqRF6SpBN4FW309CpiY1Dthpf9i2VuWzupvFCPJDryzFLFOzYA
v6VL/ta8e1iD0f3lQbwn6turQPDuRdkwb7G5adXJV0Dgn0OI8lEfUSQwv8l/jJAd
UJjfoqMKh0hFGz8Oc+QbuEoiUkJHNEGp5vteY/bECDftjg1ps43qILuDzPS2Sgvb
QMn/LB29LoBtanoYWpODsUUwoH4AMozxSfbcY06cMpsN4nc3Whz+xbNpShtbK0Mh
gZ9l0AccSCPQxc6zwBmSYp/8+W4Vnqpqd1hSUPJJmUwQ1yFxU3+CZHrNENNXK4T+
5Jyq2D5f9siNALj5Jk7Mgm+v4rjc7jGiEG4EUTENwM0owfqysLlNfVXCzFH7kc6b
jNYSZpnLvFJlmaTFN0DPud88/DuRsGpA2BSY53j2nmGG6J3x42YWU+eyJG3KjCfn
qPONZmawQ45xAELAIlGT
=SuyN
-----END PGP SIGNATURE-----

--LpQ9ahxlCli8rRTG--
