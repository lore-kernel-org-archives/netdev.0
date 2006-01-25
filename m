From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] ipw2200: fix ->eeprom[EEPROM_VERSION] check
Date: Wed, 25 Jan 2006 12:34:17 +0800
Message-ID: <1138163657.9042.7.camel@debian.sh.intel.com>
References: <20060125004429.GE3234@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751000AbWAYEjv@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060125004429.GE3234@mipter.zuzino.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked.

Thanks,
-yi

On Wed, 2006-01-25 at 03:44 +0300, Alexey Dobriyan wrote:
> priv->eeprom is a pointer.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/wireless/ipw2200.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/net/wireless/ipw2200.c
> +++ b/drivers/net/wireless/ipw2200.c
> @@ -2456,7 +2456,7 @@ static void ipw_eeprom_init_sram(struct 
>  	   copy.  Otherwise let the firmware know to perform the operation
>  	   on it's own
>  	 */
> -	if ((priv->eeprom + EEPROM_VERSION) != 0) {
> +	if (priv->eeprom[EEPROM_VERSION] != 0) {
>  		IPW_DEBUG_INFO("Writing EEPROM data into SRAM\n");
>  
>  		/* write the eeprom data to sram */
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
