From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: [PATCH 09/26] tehuti: delete redundant NULL check before
 release_firmware()
Date: Wed, 11 Apr 2012 09:31:26 -0400
Message-ID: <20120411133126.GA8258@quad.redhat.com>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
 <alpine.LNX.2.00.1204092217250.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org,
	netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1204092217250.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2012 at 10:50:42PM +0200, Jesper Juhl wrote:
> release_firmware() checks for NULL pointers - no need to test before
> the call.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

> ---
>  drivers/net/ethernet/tehuti/tehuti.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
> index ad973ff..a445e77 100644
> --- a/drivers/net/ethernet/tehuti/tehuti.c
> +++ b/drivers/net/ethernet/tehuti/tehuti.c
> @@ -341,8 +341,8 @@ static int bdx_fw_load(struct bdx_priv *priv)
>  out:
>  	if (master)
>  		WRITE_REG(priv, regINIT_SEMAPHORE, 1);
> -	if (fw)
> -		release_firmware(fw);
> +
> +	release_firmware(fw);
>  
>  	if (rc) {
>  		netdev_err(priv->ndev, "firmware loading failed\n");
> -- 
> 1.7.10
> 
> 
> -- 
> Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
> Don't top-post http://www.catb.org/jargon/html/T/top-post.html
> Plain text mails only, please.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
