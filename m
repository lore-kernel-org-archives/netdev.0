From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: core functions cleanup
Date: Wed, 01 Jan 2014 23:46:34 -0500 (EST)
Message-ID: <20140101.234634.128158345776529714.davem@davemloft.net>
References: <20131229140129.48d941ff@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbaABEqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:46:35 -0500
In-Reply-To: <20131229140129.48d941ff@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 29 Dec 2013 14:01:29 -0800

> The following functions are not used outside of net/core/dev.c
> and should be declared static.
> 
>   call_netdevice_notifiers_info
>   __dev_remove_offload
>   netdev_has_any_upper_dev
>   __netdev_adjacent_dev_remove
>   __netdev_adjacent_dev_link_lists
>   __netdev_adjacent_dev_unlink_lists
>   __netdev_adjacent_dev_unlink
>   __netdev_adjacent_dev_link_neighbour
>   __netdev_adjacent_dev_unlink_neighbour
> 
> 
> And the following are never used and should be deleted
>   netdev_lower_dev_get_private_rcu
>   __netdev_find_adj_rcu
> 
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
