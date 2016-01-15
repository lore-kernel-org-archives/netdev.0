From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: smsc: Fix disabling energy detect mode
Date: Fri, 15 Jan 2016 14:55:02 -0500 (EST)
Message-ID: <20160115.145502.1019508793273660216.davem@davemloft.net>
References: <1452849633-26877-1-git-send-email-t.remmet@phytec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: t.remmet@phytec.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452849633-26877-1-git-send-email-t.remmet@phytec.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Teresa Remmet <t.remmet@phytec.de>
Date: Fri, 15 Jan 2016 10:20:33 +0100

> @@ -110,10 +105,11 @@ static int lan911x_config_init(struct phy_device *phydev)
>   */
>  static int lan87xx_read_status(struct phy_device *phydev)
>  {
> +	bool *energy_enable = phydev->priv;
>  	int err = genphy_read_status(phydev);
>  	int i;

Please order local variable declarations from longest to shortest line.

> +static int smsc_phy_probe(struct phy_device *phydev)
> +{
> +	struct device *dev = &phydev->mdio.dev;
> +	bool *energy_enable;
> +	int __maybe_unused len;
> +	struct device_node *of_node __maybe_unused = dev->of_node;

Likewise.
