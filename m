From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] TG3: limit reaches -1
Date: Wed, 11 Feb 2009 12:40:16 -0800
Message-ID: <1234384817.14439.131.camel@HP1>
References: <4992AD3A.7000301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>, mcarlson@broadcom.com
To: "Roel Kluin" <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2697 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756718AbZBKUoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 15:44:03 -0500
In-Reply-To: <4992AD3A.7000301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-02-11 at 02:49 -0800, Roel Kluin wrote:
> With while (limit--) { ... } limit reaches -1, so 0 means success.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Acked-by: Michael Chan <mchan@broadcom.com>

Thanks.
> ---
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 8b3f846..4595962 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -852,7 +852,7 @@ static int tg3_bmcr_reset(struct tg3 *tp)
>  		}
>  		udelay(10);
>  	}
> -	if (limit <= 0)
> +	if (limit < 0)
>  		return -EBUSY;
>  
>  	return 0;
> @@ -1603,7 +1603,7 @@ static int tg3_wait_macro_done(struct tg3 *tp)
>  				break;
>  		}
>  	}
> -	if (limit <= 0)
> +	if (limit < 0)
>  		return -EBUSY;
>  
>  	return 0;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


