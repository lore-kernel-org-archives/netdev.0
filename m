From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/12] ftgmac100: Move ftgmac100_hard_start_xmit()
 around
Date: Fri, 07 Apr 2017 05:49:07 -0700 (PDT)
Message-ID: <20170407.054907.736146169595152256.davem@davemloft.net>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
        <20170407033105.29558-3-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52978 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933113AbdDGMtJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 08:49:09 -0400
In-Reply-To: <20170407033105.29558-3-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri,  7 Apr 2017 13:30:55 +1000

> Move it below ftgmac100_xmit() and the rest of the tx path
> 
> No code change.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 59 ++++++++++++++++----------------
>  1 file changed, 30 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index f4b719214..3966c7a 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -63,6 +63,7 @@ struct ftgmac100 {
>  	u32 rxdes0_edorr_mask;
>  
>  	/* Tx ring */
> +	struct sk_buff *tx_skbs[TX_QUEUE_ENTRIES];
>  	unsigned int tx_clean_pointer;
>  	unsigned int tx_pointer;
>  	unsigned int tx_pending;

Add this only in patch #6 or wherever it is that you start using it, not
this patch

Thanks.
