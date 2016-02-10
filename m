From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] lan78xx: replace devid to chipid & chiprev
Date: Wed, 10 Feb 2016 23:45:58 +0100
Message-ID: <20160210224558.GB14610@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D404AB9F2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54032 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbcBJWqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 17:46:04 -0500
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404AB9F2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2016 at 09:13:37PM +0000, Woojung.Huh@microchip.com wrote:
> 
> Replace devid to chipid & chiprev for easy access.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/usb/lan78xx.c | 20 +++++++++++---------
>  drivers/net/usb/lan78xx.h |  1 +
>  2 files changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index 1c299b8..b14b22d 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -278,7 +278,8 @@ struct lan78xx_net {
>  	int			link_on;
>  	u8			mdix_ctrl;
>  
> -	u32			devid;
> +	u32			chipid;
> +	u32			chiprev;
>  	struct mii_bus		*mdiobus;
>  };
>  
> @@ -471,7 +472,7 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
>  	 */
>  	ret = lan78xx_read_reg(dev, HW_CFG, &val);
>  	saved = val;
> -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000) {
> +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_) {

Why the extra ( ... )?

    Andrew
