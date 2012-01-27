From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 03/32] sfc: Remove parentheses around return
 expressions, reported by checkpatch
Date: Fri, 27 Jan 2012 13:01:06 -0800
Message-ID: <1327698066.18858.3.camel@joe2Laptop>
References: <1327696858.2503.7.camel@bwh-desktop>
	 <1327696976.2503.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44817 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753787Ab2A0VBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jan 2012 16:01:25 -0500
In-Reply-To: <1327696976.2503.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-27 at 20:42 +0000, Ben Hutchings wrote:
> Fix the following error:
> ERROR: return is not a function, parentheses are not required
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

trivia:

> diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
[]
> @@ -98,8 +98,8 @@ static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
>  	/* Offset is always within one page, so we don't need to consider
>  	 * the page order.
>  	 */
> -	return (((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
> -		efx->type->rx_buffer_hash_size);
> +	return ((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
> +		efx->type->rx_buffer_hash_size;
>  }

The function returns unsigned int, perhaps the
cast should be (__force unsigned int) or the
function should return unsigned long or maybe
size_t?
