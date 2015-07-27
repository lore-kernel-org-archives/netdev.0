From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next]r8169: Correct values on dma_alloc_coherent
Date: Mon, 27 Jul 2015 22:55:26 +0200
Message-ID: <20150727205526.GA8398@electric-eye.fr.zoreil.com>
References: <1437992498-2381-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44534 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729AbbG0Uzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 16:55:44 -0400
Content-Disposition: inline
In-Reply-To: <1437992498-2381-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 3df51fa..fd249a6 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -6724,8 +6724,8 @@ static int rtl8169_init_ring(struct net_device *dev)
>  
>  	rtl8169_init_ring_indexes(tp);
>  
> -	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
> -	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
> +	memset(tp->tx_skb, 0x0, NUM_RX_DESC);
> +	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC);

	void *Rx_databuff[NUM_RX_DESC];

:o(

Please don't mess with the kernel code until you've figured how wrong
these changes are. Then give yourself a few months and read more code.

Really.

-- 
Ueimor
