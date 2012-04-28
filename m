From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] bnx2x: add transmit timestamping support
Date: Sat, 28 Apr 2012 09:48:39 +0200
Message-ID: <1335599319.2900.52.camel@edumazet-glaptop>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
	 <1335553447-11964-4-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55660 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab2D1Hsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 03:48:43 -0400
Received: by wibhq7 with SMTP id hq7so1322401wib.1
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 00:48:42 -0700 (PDT)
In-Reply-To: <1335553447-11964-4-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 15:04 -0400, Willem de Bruijn wrote:
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 60d5b54..afa6cbb 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -2953,6 +2953,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	netdev_tx_sent_queue(txq, skb->len);
>  
> +	skb_tx_timestamp(skb);
> +
>  	txdata->tx_pkt_prod++;
>  	/*
>  	 * Make sure that the BD data is updated before updating the producer

Acked-by: Eric Dumazet <edumazet@google.com>
