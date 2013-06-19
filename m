From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 03/11] sfc: Increase size of RX SKB header area
Date: Wed, 19 Jun 2013 15:38:20 -0700
Message-ID: <1371681500.3252.341.camel@edumazet-glaptop>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
	 <1371680317.1956.110.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:34651 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935291Ab3FSWi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:38:26 -0400
Received: by mail-ee0-f50.google.com with SMTP id d49so3452733eek.37
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 15:38:24 -0700 (PDT)
In-Reply-To: <1371680317.1956.110.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 23:18 +0100, Ben Hutchings wrote:
> From: Jon Cooper <jcooper@solarflare.com>
> 
> This allows the SKB to hold the headers without reallocation more often.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/rx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> index b915e09..6efff3d 100644
> --- a/drivers/net/ethernet/sfc/rx.c
> +++ b/drivers/net/ethernet/sfc/rx.c
> @@ -36,7 +36,7 @@
>  #define EFX_RECYCLE_RING_SIZE_NOIOMMU (2 * EFX_RX_PREFERRED_BATCH)
>  
>  /* Size of buffer allocated for skb header area. */
> -#define EFX_SKB_HEADERS  64u
> +#define EFX_SKB_HEADERS  128u
>  

Yes, TCP with timestamps needs 66 bytes of headers on IPv4, and more on
IPv6...
