From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC PATCH v4 2/2] net: phy: Add gmiitorgmii converter support
Date: Tue, 9 Aug 2016 08:07:35 +0000
Message-ID: <03CA77BA8AF6F1469AEDFBDA1322A7B74A1C3E6C@XAP-PVEXMBX02.xlnx.xilinx.com>
References: <1470640505-8279-1-git-send-email-appanad@xilinx.com>
 <1470640505-8279-2-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Appana Durga Kedareswara Rao <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"Michal Simek" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"Appana Durga Kedareswara Rao" <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"andrew-g2DYL2Zd6BY@public.gmane.org" <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Anirudha Sarangi <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470640505-8279-2-git-send-email-appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kedar,

> -----Original Message-----
> From: Kedareswara rao Appana [mailto:appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org]
> Sent: Monday, August 08, 2016 12:45 PM
> To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; mark.rutland-5wv7dgnIgG8@public.gmane.org; Michal Simek
> <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>; Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>; Appana
> Durga Kedareswara Rao <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>; f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org;
> andrew-g2DYL2Zd6BY@public.gmane.org; Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>;
> Anirudha Sarangi <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: [RFC PATCH v4 2/2] net: phy: Add gmiitorgmii converter support
> 
> This patch adds support for gmiitorgmii converter.
> 
> The GMII to RGMII IP core provides the Reduced Gigabit Media
> Independent Interface (RGMII) between Ethernet physical media
> Devices and the Gigabit Ethernet controller. This core can
> Switch dynamically between the three different speed modes of
> Operation by configuring the converter register through mdio write.
> 
> MDIO interface is used to set operating speed of Ethernet MAC.
> 
> Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> ---
> Thanks a lot Andrew for your inputs.
> Changes for v4:
> --> Updated phydev speed for all 3 speeds as suggested by zhuyj.
> Changes for v3:
> --> Updated the driver as suggested by Andrew.
> Changes for v2:
> --> Passed struct xphy pointer directly to the fix_mac_speed
> API as suggested by the Florian.
> --> Added checks for the phy-node fail case as suggested
> by the Florian
> 
> +
> +#define XILINX_GMII2RGMII_REG	0x10
> +#define BMCR_SPEED10		0x00

Move this macro to mii.h

> +
> +struct gmii2rgmii {
> +	struct phy_device *phy_dev;
> +	struct phy_driver *phy_drv;
> +	struct phy_driver conv_phy_drv;
> +	int addr;
> +};
> +
> +static int xgmiitorgmii_read_status(struct phy_device *phydev)
> +{
> +	struct gmii2rgmii *priv = (struct gmii2rgmii *)phydev->priv;
> +	u16 val = 0;
> +
> +	priv->phy_drv->read_status(phydev);
> +
> +	val = mdiobus_read(phydev->mdio.bus, priv->addr,
> XILINX_GMII2RGMII_REG);
> +

    Since its read and then modify, you should mask the speed field
With zero and then write new value.
           

> +	switch (phydev->speed) {
> +	case SPEED_1000:
> +		val |= BMCR_SPEED1000;
> +	case SPEED_100:
> +		val |= BMCR_SPEED100;
> +	case SPEED_10:
> +		val |= BMCR_SPEED10;
> +	}
> +
> +	mdiobus_write(phydev->mdio.bus, priv->addr,
> XILINX_GMII2RGMII_REG, val);
> +
> +	return 0;
> +}
> +
> +int xgmiitorgmii_probe(struct mdio_device *mdiodev)
> +{
> +	struct device *dev = &mdiodev->dev;
> +	struct device_node *np = dev->of_node, *phy_node;
> +	struct gmii2rgmii *priv;
> +	int ret;
> +
> +	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;
> +
> +	phy_node = of_parse_phandle(np, "phy-handle", 0);
> +	if (IS_ERR(phy_node)) {
> +		dev_err(dev, "Couldn't parse phy-handle\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +
> +	priv->phy_dev = of_phy_find_device(phy_node);
> +	if (!priv->phy_dev) {
> +		ret = -EPROBE_DEFER;
> +		dev_info(dev, "Couldn't find phydev\n");
> +		goto out;
> +	}
> +
> +	priv->addr = mdiodev->addr;
> +	priv->phy_drv = priv->phy_dev->drv;
> +	memcpy(&priv->conv_phy_drv, priv->phy_dev->drv,
> +	       sizeof(struct phy_driver));
> +	priv->conv_phy_drv.read_status = xgmiitorgmii_read_status;
> +	priv->phy_dev->priv = priv;
> +	priv->phy_dev->drv = &priv->conv_phy_drv;
> +
> +	return 0;
> +out:
> +	return ret;

Since there is no resource cleaning here, you could consider
Return from this function in above conditions and avoid goto here.

Regards,
Punnaiah

> +}
> +
> +static const struct of_device_id xgmiitorgmii_of_match[] = {
> +	{ .compatible = "xlnx,gmii-to-rgmii-1.0" },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, xgmiitorgmii_of_match);
> +
> +static struct mdio_driver xgmiitorgmii_driver = {
> +	.probe	= xgmiitorgmii_probe,
> +	.mdiodrv.driver = {
> +		.name = "xgmiitorgmii",
> +		.of_match_table = xgmiitorgmii_of_match,
> +	},
> +};
> +
> +static int __init xgmiitorgmii_init(void)
> +{
> +	return mdio_driver_register(&xgmiitorgmii_driver);
> +}
> +module_init(xgmiitorgmii_init);
> +
> +static void __exit xgmiitorgmii_cleanup(void)
> +{
> +	mdio_driver_unregister(&xgmiitorgmii_driver);
> +}
> +module_exit(xgmiitorgmii_cleanup);
> +
> +MODULE_DESCRIPTION("Xilinx GMII2RGMII converter driver");
> +MODULE_LICENSE("GPL");
> --
> 2.1.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
