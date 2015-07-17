From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: Return the variable ret rather then zero
 for the function bcmgenet_power_down
Date: Fri, 17 Jul 2015 10:55:41 -0700
Message-ID: <55A9419D.1040708@gmail.com>
References: <1437075530-21552-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33193 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021AbbGQR5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 13:57:33 -0400
In-Reply-To: <1437075530-21552-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/07/15 12:38, Nicholas Krause wrote:
> This makes the function bcmgenet_power_down return the variable ret
> rather then zero in order to make this function be able to signal its
> caller with a error code when a failure occurs internally rather then
> always appearing to run successfully to its caller.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

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
