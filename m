From: Edward Cree <ecree@solarflare.com>
Subject: Re: [patch net-next] sfc: remove unneeded variable
Date: Thu, 24 Nov 2016 13:22:24 +0000
Message-ID: <698affdd-d4e0-53c0-fff0-9b66252504a0@solarflare.com>
References: <20161124111651.GJ17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bert Kenward <bkenward@solarflare.com>, <netdev@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:29684 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965211AbcKXNWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 08:22:42 -0500
In-Reply-To: <20161124111651.GJ17225@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/11/16 11:16, Dan Carpenter wrote:
> We don't use ->heap_buf after commit 46d1efd852cc ("sfc: remove Software
> TSO") so let's remove the last traces.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
> index f97f828..fd17bda 100644
> --- a/drivers/net/ethernet/sfc/net_driver.h
> +++ b/drivers/net/ethernet/sfc/net_driver.h
> @@ -139,8 +139,6 @@ struct efx_special_buffer {
>   * struct efx_tx_buffer - buffer state for a TX descriptor
>   * @skb: When @flags & %EFX_TX_BUF_SKB, the associated socket buffer to be
>   *	freed when descriptor completes
> - * @heap_buf: When @flags & %EFX_TX_BUF_HEAP, the associated heap buffer to be
> - *	freed when descriptor completes.

Does that mean we can also remove EFX_TX_BUF_HEAP?
-Ed
