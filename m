From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Sun, 24 Apr 2016 14:18:06 -0400 (EDT)
Message-ID: <20160424.141806.786009616301278103.davem@davemloft.net>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
	<1461230323-27891-2-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, suzuki.poulose-5wv7dgnIgG8@public.gmane.org,
	punit.agrawal-5wv7dgnIgG8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, anup.patel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461230323-27891-2-git-send-email-pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date: Thu, 21 Apr 2016 14:48:38 +0530

> +struct shared_mdio_master *shared_mdio_alloc_master(struct device *parent,
> +						    struct device_node *node)
> +{
> +	int ret = 0;
> +	struct shared_mdio_master *master;

Always order local variable declarations in reverse christmas tree
(longest to shortest line) order.

> +static int shared_mdio_driver_probe(struct device *dev)
> +{
> +	int rc;
> +	struct shared_mdio_master *master = to_shared_mdio_master(dev);
> +	struct shared_mdio_driver *drv = to_shared_mdio_driver(dev->driver);

Likewise.

Please audit your entire submission for this issue.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
