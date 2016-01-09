From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next 2/2] net: tc35815: Drop unused variable
Date: Sat, 9 Jan 2016 22:37:13 +0100
Message-ID: <20160109213713.GD6877@lunn.ch>
References: <1452374494-18752-1-git-send-email-linux@roeck-us.net>
 <1452374494-18752-2-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452374494-18752-2-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 09, 2016 at 01:21:34PM -0800, Guenter Roeck wrote:
> Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
> removes some code from tc_mii_init(), but does not remove a now unused
> variable. This results in the following build warning.
> 
> drivers/net/ethernet/toshiba/tc35815.c: In function 'tc_mii_init':
> drivers/net/ethernet/toshiba/tc35815.c:670:6: warning: unused variable 'i'
> 
> Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Andrew Lunn <andrew@lunn.ch>

	  Thanks
		Andrew

> ---
>  drivers/net/ethernet/toshiba/tc35815.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
> index 5b5e7dcf9a99..c6c5ef979b84 100644
> --- a/drivers/net/ethernet/toshiba/tc35815.c
> +++ b/drivers/net/ethernet/toshiba/tc35815.c
> @@ -670,7 +670,6 @@ static int tc_mii_init(struct net_device *dev)
>  {
>  	struct tc35815_local *lp = netdev_priv(dev);
>  	int err;
> -	int i;
>  
>  	lp->mii_bus = mdiobus_alloc();
>  	if (lp->mii_bus == NULL) {
> -- 
> 2.1.4
> 
