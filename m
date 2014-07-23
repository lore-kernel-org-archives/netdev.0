From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/6] net: bcmgenet: add missing blank line
 after declaration
Date: Tue, 22 Jul 2014 21:35:26 -0700
Message-ID: <1406090126.2755.13.camel@joe-AO725>
References: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
	 <1406051718-15883-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0011.hostedemail.com ([216.40.44.11]:43917 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751286AbaGWEf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 00:35:29 -0400
In-Reply-To: <1406051718-15883-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-22 at 10:55 -0700, Florian Fainelli wrote:
> checkpatch flagged a bunch of problems in bcmgenet.h with: WARNING:
> Missing a blank line after declarations, fix them.
[]
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
[]
> @@ -438,6 +438,7 @@ struct bcmgenet_mib_counters {
>  struct enet_cb {
>  	struct sk_buff      *skb;
>  	void __iomem *bd_addr;
> +
>  	DEFINE_DMA_UNMAP_ADDR(dma_addr);
>  	DEFINE_DMA_UNMAP_LEN(dma_len);
>  };
> @@ -503,6 +504,7 @@ struct bcmgenet_tx_ring {
>  	unsigned int	prod_index;	/* Tx ring producer index SW copy */
>  	unsigned int	cb_ptr;		/* Tx ring initial CB ptr */
>  	unsigned int	end_ptr;	/* Tx ring end CB ptr */
> +
>  	void (*int_enable)(struct bcmgenet_priv *priv,
>  				struct bcmgenet_tx_ring *);
>  	void (*int_disable)(struct bcmgenet_priv *priv,

checkpatch false positives.

The first is a macro definition, the second is a function pointer.

Please use the version in -next.
