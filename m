From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH 15/15] net: usb: lan78xx: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 18:14:57 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40965345@CHN-SV-EXMX02.mchp-main.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
 <20161115180644.3941-16-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <andrew@lunn.ch>, <tremyfr@gmail.com>,
        <UNGLinuxDriver@microchip.com>, <linux-usb@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-16-f.fainelli@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/usb/lan78xx.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index bcd9010c1f27..cf2857fa938f 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -1447,11 +1447,6 @@ static u32 lan78xx_get_link(struct net_device *net)
>  	return net->phydev->link;
>  }
> 
> -static int lan78xx_nway_reset(struct net_device *net)
> -{
> -	return phy_start_aneg(net->phydev);
> -}
> -
>  static void lan78xx_get_drvinfo(struct net_device *net,
>  				struct ethtool_drvinfo *info)
>  {
> @@ -1655,7 +1650,7 @@ static int lan78xx_set_pause(struct net_device
> *net,
> 
>  static const struct ethtool_ops lan78xx_ethtool_ops = {
>  	.get_link	= lan78xx_get_link,
> -	.nway_reset	= lan78xx_nway_reset,
> +	.nway_reset	= phy_ethtool_nway_reset,
>  	.get_drvinfo	= lan78xx_get_drvinfo,
>  	.get_msglevel	= lan78xx_get_msglevel,
>  	.set_msglevel	= lan78xx_set_msglevel,
> --
> 2.9.3
Acked-by: Woojung Huh <woojung.huh@microchip.com>
