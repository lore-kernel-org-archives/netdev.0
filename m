From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/6] net: bcmgenet: re-align multiple lines
 correctly
Date: Tue, 22 Jul 2014 21:41:30 -0700
Message-ID: <1406090490.2755.18.camel@joe-AO725>
References: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
	 <1406051718-15883-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0207.hostedemail.com ([216.40.44.207]:44057 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755348AbaGWEld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 00:41:33 -0400
In-Reply-To: <1406051718-15883-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-22 at 10:55 -0700, Florian Fainelli wrote:
> checkpatch.pl flagged a lot of "CHECK: Alignment should match open
> parenthesis" checks, fix all of them to make the driver neater.

trivial notes

> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
[]
> @@ -670,7 +668,7 @@ static void bcmgenet_update_mib_counters(struct bcmgenet_priv *priv)
>  			if (s->type != BCMGENET_STAT_MIB_RX)
>  				offset = BCMGENET_STAT_OFFSET;
>  			val = bcmgenet_umac_readl(priv, UMAC_MIB_START +
> -								j + offset);
> +						  j + offset);

Maybe better as:

			val = bcmgenet_umac_readl(priv,
						  UMAC_MIB_START + j + offset);

> @@ -1318,7 +1315,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>  
>  		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
>  			netif_err(priv, rx_status, dev,
> -					"Droping fragmented packet!\n");
> +				  "Droping fragmented packet!\n");

dropping
