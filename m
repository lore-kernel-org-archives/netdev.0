From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] ethernet/arc/arc_emac - Add new driver
Date: Thu, 06 Jun 2013 16:35:06 -0700 (PDT)
Message-ID: <20130606.163506.962150797885004652.davem@davemloft.net>
References: <1370348510-23754-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sjhill-8NJIiSa5LzA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vineet.Gupta1-HKixBCOQz3hWk0Htik3J/w@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org,
 paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
 Mischa.Jonker-HKixBCOQz3hWk0Htik3J/w@public.gmane.org
To: Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1370348510-23754-1-git-send-email-abrodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Date: Tue, 4 Jun 2013 16:21:50 +0400

> +{
> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
> +	struct phy_device *phydev = priv->phy_dev;
> +	u32 reg;
> +
> +	int status_change = 0;

Do not add empty lines amongst the top-level variable declarations
of a function.  Fix this in the entire driver, as needed.

> +			netdev_warn(net_dev,
> +				"Speed (%d) is not 10/100?\n", phydev->speed);

Functions calls on multiple lines must have the arguments
aligned properly on the second and subsequent lines, this
means:

		function(arg1, arg2,
			 arg3, arg4);

You must use the appropriate number of TAB and space characters
to achieve this proper column alignment, rather than only using
TAB characters as you have done here.

Audit and fix this in your entire driver.

> +static int arc_emac_get_settings(struct net_device *net_dev,
> +		struct ethtool_cmd *cmd)

The argument indention rules above apply to function definitions
as well.
