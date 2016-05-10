From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] net: l3mdev: Add hook in ip and ipv6
Date: Mon, 09 May 2016 22:39:35 -0400 (EDT)
Message-ID: <20160509.223935.348154720671175340.davem@davemloft.net>
References: <1462681005-25959-1-git-send-email-dsa@cumulusnetworks.com>
	<1462681005-25959-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbcEJCjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 22:39:39 -0400
In-Reply-To: <1462681005-25959-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat,  7 May 2016 21:16:44 -0700

> +static inline
> +struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
> +{
> +	struct net_device *master = NULL;
> +
> +	if (netif_is_l3_slave(skb->dev))
> +		master = netdev_master_upper_dev_get_rcu(skb->dev);
> +
> +	else if (netif_is_l3_master(skb->dev))
> +		master = skb->dev;

Please no empty line between if and else if clauses.
