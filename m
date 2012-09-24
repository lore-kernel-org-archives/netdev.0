From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4] lxt PHY: Support for the buggy LXT973 rev A2
Date: Mon, 24 Sep 2012 20:30:35 +0200
Message-ID: <20120924183035.GA2252@netboy.at.omicron.at>
References: <201209241400.q8OE0w38011790@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David S Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201209241400.q8OE0w38011790@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 24, 2012 at 04:00:58PM +0200, Christophe Leroy wrote:

> diff -u a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
> --- a/drivers/net/phy/lxt.c	2012-09-23 03:08:48.000000000 +0200
> +++ b/drivers/net/phy/lxt.c	2012-09-23 03:18:00.000000000 +0200

...

> @@ -175,6 +292,16 @@
>  	.driver		= { .owner = THIS_MODULE,},
>  }, {
>  	.phy_id		= 0x00137a10,
> +	.name		= "LXT973-A2",
> +	.phy_id_mask	= 0xffffffff,
> +	.features	= PHY_BASIC_FEATURES,
> +	.flags		= 0,
> +	.probe		= lxt973_probe,
> +	.config_aneg	= lxt973_config_aneg,
> +	.read_status	= lxt973a2_read_status,

I like this way of matching the A2 chips much better than what you had
before. But are you sure this will work correctly?

What do A3 chips have in the last nibble of phy_id?

> +	.driver		= { .owner = THIS_MODULE,},
> +}, {
> +	.phy_id		= 0x00137a10,
>  	.name		= "LXT973",
>  	.phy_id_mask	= 0xfffffff0,
>  	.features	= PHY_BASIC_FEATURES,

Thanks,
Richard
