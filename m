From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: set skb->rxhash
Date: Tue, 27 Apr 2010 15:44:38 -0700 (PDT)
Message-ID: <20100427.154438.133411714.davem@davemloft.net>
References: <1272406825-11615-1-git-send-email-dm@chelsio.com>
	<20100427153656.7bcaba83@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46801
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755114Ab0D0Wod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:44:33 -0400
In-Reply-To: <20100427153656.7bcaba83@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 27 Apr 2010 15:36:56 -0700

>> +static int set_flags(struct net_device *dev, u32 flags)
>> +{
>> +	if (flags & ~ETH_FLAG_RXHASH)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (flags & ETH_FLAG_RXHASH)
>> +		dev->features |= NETIF_F_RXHASH;
>> +	else
>> +		dev->features &= ~NETIF_F_RXHASH;
>> +	return 0;
>> +}
> 
> You need to check for and reject other values NTUPLE and LRO

He does, it's the first he does in the function.
