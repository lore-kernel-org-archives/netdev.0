From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] (7/23) sk98: basic ethtool support
Date: Fri, 12 Nov 2004 16:29:04 +0000
Message-ID: <20041112162904.GB7066@infradead.org>
References: <4192C60A.1050205@designassembly.de> <20041111154225.5cf85567@zqx3.pdx.osdl.net> <20041111155503.6e0349b8@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041111155503.6e0349b8@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 11, 2004 at 03:55:03PM -0800, Stephen Hemminger wrote:
> The basic stuff comes from the newer code from SysKonnect, but I redid
> it using ethtool_ops and a cleaner way of doing the stats (from e100)


> +/*****************************************************************************
> + *
> + * 	getSettings - retrieves the current settings of the selected adapter
> + *
> + * Description:
> + *	The current configuration of the selected adapter is returned.
> + *	This configuration involves a)speed, b)duplex and c)autoneg plus
> + *	a number of other variables.
> + *
> + * Returns:    always 0
> + *
> + */

Please use normal kernel-doc function documentation.
 
> +static int getSettings(struct net_device *dev, struct ethtool_cmd *ecmd)

And avoid studlyCaps.  Also an sk98lin prefix even on private function
helps avoiding nameclashes for the generic names (and in the debugger
or oopses)

> +{
> +	const DEV_NET *pNet = netdev_priv(dev);

please always use struct net_device instead of strange typedefs for it.
