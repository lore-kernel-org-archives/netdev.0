From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] sunvnet: allow admin to set sunvnet MTU
Date: Mon, 29 Sep 2014 14:58:39 -0400 (EDT)
Message-ID: <20140929.145839.1840433438051963991.davem@davemloft.net>
References: <5429940D.4040500@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	Raghuram.Kothakota@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaI2S6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:58:41 -0400
In-Reply-To: <5429940D.4040500@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 29 Sep 2014 13:17:01 -0400

> @@ -884,6 +884,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	skb = vnet_skb_shape(skb, &start, &nlen);
>  +	if (skb->len > port->rmtu)
> +		goto out_dropped;
> +
>  	spin_lock_irqsave(&port->vio.lock, flags);

More patch corruption.
