From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tc35815: Remove unnecessary skb->dev assignment
Date: Tue, 08 May 2007 01:42:15 -0400
Message-ID: <46400DB7.1080500@garzik.org>
References: <20070508.004604.108738613.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54598 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968014AbXEHFmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:42:17 -0400
In-Reply-To: <20070508.004604.108738613.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> Apply changes in commit 4c13eb6657fe9ef7b4dc8f1a405c902e9e5234e0 to
> newly added piece of code.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
> index f1e2dfc..463d600 100644
> --- a/drivers/net/tc35815.c
> +++ b/drivers/net/tc35815.c
> @@ -540,7 +540,6 @@ static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
>  	skb = dev_alloc_skb(RX_BUF_SIZE);
>  	if (!skb)
>  		return NULL;
> -	skb->dev = dev;
>  	*dma_handle = pci_map_single(hwdev, skb->data, RX_BUF_SIZE,
>  				     PCI_DMA_FROMDEVICE);

applied


