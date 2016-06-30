From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V6 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Thu, 30 Jun 2016 08:34:33 -0400 (EDT)
Message-ID: <20160630.083433.705935493078392286.davem@davemloft.net>
References: <1467191413-16715-1-git-send-email-thloh@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org, preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org,
	dinguyen-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	thloh85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cnphoon-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org
To: thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467191413-16715-1-git-send-email-thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: <thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Date: Wed, 29 Jun 2016 02:10:13 -0700

> +static void auto_nego_timer_callback(unsigned long data)
> +{
> +	u16 val = 0;
> +	u16 speed = 0;
> +	u16 duplex = 0;
> +
> +	struct tse_pcs *pcs = (struct tse_pcs *)data;
> +	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
> +	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;

Please do not break up a set of local variable declarations with
an empty line.

> +	if ((tse_pcs_base) && (sgmii_adapter_base))

Unnecessary parenthesis.

> +	if ((tse_pcs_base) && (sgmii_adapter_base))

Likewise.

> @@ -88,9 +104,13 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>  	struct device_node *np = dev->of_node;
>  	struct regmap *sys_mgr_base_addr;
>  	u32 reg_offset, reg_shift;
> -	int ret;
> -	struct device_node *np_splitter;
> +	int ret, index;
> +	struct device_node *np_splitter = NULL;
> +	struct device_node *np_sgmii_adapter = NULL;
> +
>  	struct resource res_splitter;
> +	struct resource res_tse_pcs;
> +	struct resource res_sgmii_adapter;

Again, do not break up local variable declarations with an empty line
like this.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
