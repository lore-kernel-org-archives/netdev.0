From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] genet:Return the variable ret rather then zero for the
 function bcmgenet_power_down
Date: Thu, 16 Jul 2015 12:24:53 -0700
Message-ID: <55A80505.8010009@gmail.com>
References: <1436972983-2820-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36208 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbbGPT0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 15:26:46 -0400
In-Reply-To: <1436972983-2820-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/07/15 08:09, Nicholas Krause wrote:
> This makes the function bcmgenet_power_down return the variable ret
> rather then zero in order to make this function be able to signal its
> caller with a error code when a failure occurs internally rather then
> always appearing to run successfully to its caller.

Please adjust the subject to be "net: bcmgenet: blah blah", just to
conform to the style used for all other changes.

This seems fine otherwise...

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
