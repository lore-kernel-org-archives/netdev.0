From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 7/8] sctp: use IS_ENABLED() instead of checking for
 built-in or module
Date: Fri, 9 Sep 2016 12:43:09 -0400
Message-ID: <20160909164309.GC15908@hmsreliant.think-freely.org>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
 <1473425000-9782-8-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        linux-sctp@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473425000-9782-8-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 09, 2016 at 08:43:19AM -0400, Javier Martinez Canillas wrote:
> The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
> built-in or as a module, use that macro instead of open coding the same.
> 
> Using the macro makes the code more readable by helping abstract away some
> of the Kconfig built-in and module enable details.
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> ---
> 
>  net/sctp/auth.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/auth.c b/net/sctp/auth.c
> index 912eb1685a5d..f99d4855d3de 100644
> --- a/net/sctp/auth.c
> +++ b/net/sctp/auth.c
> @@ -48,7 +48,7 @@ static struct sctp_hmac sctp_hmac_list[SCTP_AUTH_NUM_HMACS] = {
>  		/* id 2 is reserved as well */
>  		.hmac_id = SCTP_AUTH_HMAC_ID_RESERVED_2,
>  	},
> -#if defined (CONFIG_CRYPTO_SHA256) || defined (CONFIG_CRYPTO_SHA256_MODULE)
> +#if IS_ENABLED(CONFIG_CRYPTO_SHA256)
>  	{
>  		.hmac_id = SCTP_AUTH_HMAC_ID_SHA256,
>  		.hmac_name = "hmac(sha256)",
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
