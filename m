From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] net: ethernet: davicom: Allow to select DM9000 for
 nios2
Date: Fri, 12 Dec 2014 20:28:42 +0900
Message-ID: <20141212112842.GA17780@verge.net.au>
References: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51173 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965753AbaLLL2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 06:28:46 -0500
Content-Disposition: inline
In-Reply-To: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 10:21:11AM +0100, Tobias Klauser wrote:
> This chip is present on older revisions of the DE2 development kit.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

I wonder if || COMPILE_TEST should also be added to allow extra build
coverage. Is there a specific reason it won't compile more widely?

Likewise for your smsc patch.

> ---
>  drivers/net/ethernet/davicom/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
> index 316c5e5..7ec2d74 100644
> --- a/drivers/net/ethernet/davicom/Kconfig
> +++ b/drivers/net/ethernet/davicom/Kconfig
> @@ -4,7 +4,7 @@
>  
>  config DM9000
>  	tristate "DM9000 support"
> -	depends on ARM || BLACKFIN || MIPS || COLDFIRE
> +	depends on ARM || BLACKFIN || MIPS || COLDFIRE || NIOS2
>  	select CRC32
>  	select MII
>  	---help---
> -- 
> 2.2.0
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
