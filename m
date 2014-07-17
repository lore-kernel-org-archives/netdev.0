From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] sunvnet: clean up objects created in
 vnet_new() on vnet_exit()
Date: Wed, 16 Jul 2014 22:44:32 -0700 (PDT)
Message-ID: <20140716.224432.83094029257457367.davem@davemloft.net>
References: <20140716140226.GA29999@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.kleikamp@oracle.com, karl.volz@oracle.com,
	netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaGQFod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 01:44:33 -0400
In-Reply-To: <20140716140226.GA29999@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 16 Jul 2014 10:02:26 -0400

> 
> Nothing cleans up the objects created by
> vnet_new(), they are completely leaked.
> 
> vnet_exit(), after doing the vio_unregister_driver() to clean
> up ports, should call a helper function that iterates over vnet_list
> and cleans up those objects. This includes unregister_netdevice()
> as well as free_netdev().
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>
> Reviewed-by: Karl Volz <karl.volz@oracle.com>
> 
> ---
> v2: incorporated comments from David Miller.
> v3: muttrc config tweaks to avoid list-rejection
> and set up correct From/Message-ID headers.

Looks great, applied and queued up for -stable, thanks!
