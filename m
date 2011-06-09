From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tun: reserves space for network in skb
Date: Thu, 09 Jun 2011 00:09:14 -0700 (PDT)
Message-ID: <20110609.000914.359816474597759076.davem@davemloft.net>
References: <20110609003306.651532958@vyatta.com>
	<20110609003321.904295399@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab1FIHJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:09:15 -0400
In-Reply-To: <20110609003321.904295399@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 08 Jun 2011 17:33:07 -0700

> The tun driver allocates skb's to hold data from user and then passes
> the data into the network stack as received data. Most network devices
> allocate the receive skb with routines like dev_alloc_skb() that reserves
> additional space for use by network protocol stack but tun does not.
> 
> Because of the lack of padding, when the packet is passed through bridge
> netfilter a new skb has to be allocated.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Netconf must be coming up soon, Stephen Hemminger is submitting patches
again :-)

Both applied, thanks!
