From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove bogus checks of rt_gateway being zero.
Date: Tue, 24 Jan 2012 18:16:39 -0500 (EST)
Message-ID: <20120124.181639.2228224485434148573.davem@davemloft.net>
References: <20120124.180937.1535236308212704084.davem@davemloft.net>
	<1327446946.14373.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab2AXXQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 18:16:43 -0500
In-Reply-To: <1327446946.14373.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2012 00:15:46 +0100

>> @@ -454,8 +454,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>>  			dev->stats.tx_fifo_errors++;
>>  			goto tx_error;
>>  		}
>> -		if ((dst = rt->rt_gateway) == 0)
>> -			goto tx_error_icmp;
>>  	}
>>  
>>  	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
> 
> Hmm...
> 
> So dst wont be initialized ?

Grrr, good catch, I'll fix this, thanks Eric.
