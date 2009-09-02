From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Wed, 02 Sep 2009 14:37:28 -0400
Message-ID: <4A9EBB68.2080903@hp.com>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com>	<20090902.013002.181288977.davem@davemloft.net>	<4A9E6551.4030209@gmail.com>	<4A9E699B.7080400@gmail.com> <20090902092351.11649796@nehalam> <4A9E9D8A.50406@trash.net> <4A9EA250.2010209@gmail.com> <4A9EA8C6.2000501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:33687 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbZIBSh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 14:37:28 -0400
In-Reply-To: <4A9EA8C6.2000501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
> index 3c1895e..0525a1d 100644
> --- a/include/net/rtnetlink.h
> +++ b/include/net/rtnetlink.h
> @@ -70,6 +70,8 @@ struct rtnl_link_ops {
>  	size_t			(*get_xstats_size)(const struct net_device *dev);
>  	int			(*fill_xstats)(struct sk_buff *skb,
>  					       const struct net_device *dev);
> +	int			(*get_tx_queues)(struct net*, struct nlattr *tb[],
> +						 int *tx_queues, int *real_tx_queues);

	int			(*get_tx_queues)(struct net *net, struct nlattr *tb[],

Total nitpick, but tbird highlighted it because of the missing "net".

-Brian
