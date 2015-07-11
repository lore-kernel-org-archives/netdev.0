From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] gianfar: Add paged allocation and Rx S/G
Date: Fri, 10 Jul 2015 18:26:50 -0700 (PDT)
Message-ID: <20150710.182650.555632423222261831.davem@davemloft.net>
References: <1436459084-14103-1-git-send-email-claudiu.manoil@freescale.com>
	<1436459084-14103-5-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbbGKGPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:15:30 -0400
In-Reply-To: <1436459084-14103-5-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 9 Jul 2015 19:24:44 +0300

> @@ -2839,6 +2815,94 @@ static irqreturn_t gfar_transmit(int irq, void *grp_id)
>  	return IRQ_HANDLED;
>  }
>  
> +static bool gfar_add_rx_frag(struct gfar_rx_buff *rxb, unsigned int lstatus,
> +			     struct sk_buff *skb, bool first)
> +{

You really are again playing Russian Roulette with the type of
'lstatus' here.  Use 'u32' consistently.

> +static struct sk_buff *gfar_get_next_rxbuff(struct gfar_priv_rx_q *rx_queue,
> +					    unsigned long lstatus,
> +					    struct sk_buff *skb)

Likewise.
