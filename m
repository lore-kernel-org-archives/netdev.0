From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH] netcp:Fix error handling in the function netcp_xgbe_serdes_config
Date: Tue, 21 Jul 2015 10:57:24 -0400
Message-ID: <55AE5DD4.3060304@ti.com>
References: <1437407684-1750-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>, <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437407684-1750-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2015 11:54 AM, Nicholas Krause wrote:
> This fixes error handling in the function netcp_xgbe_serdes_config
> by putting the return value of netcp_xgbe_serdes_check_lane into
> the variable ret and return this value to the caller as this function
> can fail when called by returning the error code -ETIMEOUT.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>   drivers/net/ethernet/ti/netcp_xgbepcsr.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/netcp_xgbepcsr.c b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
> index 33571ac..0c79e3d 100644
> --- a/drivers/net/ethernet/ti/netcp_xgbepcsr.c
> +++ b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
> @@ -483,7 +483,7 @@ static int netcp_xgbe_serdes_config(void __iomem *serdes_regs,
>   		return ret;
>
>   	netcp_xgbe_serdes_enable_xgmii_port(sw_regs);
> -	netcp_xgbe_serdes_check_lane(serdes_regs, sw_regs);
> +	ret = netcp_xgbe_serdes_check_lane(serdes_regs, sw_regs);
>   	return ret;
>   }
>
>
Nicholas,

Thanks for the patch.

Acked-by: Murali Karicheri <m-karicheri2@ti.com>

-- 
Murali Karicheri
Linux Kernel, Keystone
