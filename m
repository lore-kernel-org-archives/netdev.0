From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net:bcmgent:Return the variable ret rather then zero
 for the function bcmgenet_power_down
Date: Thu, 16 Jul 2015 12:35:30 -0700
Message-ID: <55A80782.9050907@gmail.com>
References: <1437075256-21395-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437075256-21395-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/07/15 12:34, Nicholas Krause wrote:
> This makes the function bcmgenet_power_down return the variable ret
> rather then zero in order to make this function be able to signal its
> caller with a error code when a failure occurs internally rather then
> always appearing to run successfully to its caller.

Still not quite the right subject (missing spaces, typos), copy/paste this:

net: bcmgenet: Return the variable ret rather then zero for the function
bcmgenet_power_down

> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 64c1e9d..129e5b5 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -877,7 +877,7 @@ static int bcmgenet_power_down(struct bcmgenet_priv *priv,
>  		break;
>  	}
>  
> -	return 0;
> +	return ret;
>  }
>  
>  static void bcmgenet_power_up(struct bcmgenet_priv *priv,
> 


-- 
Florian
