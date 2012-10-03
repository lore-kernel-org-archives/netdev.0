From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] netxen: write IP address to firmware when
 using bonding
Date: Tue, 02 Oct 2012 22:40:35 -0400 (EDT)
Message-ID: <20121002.224035.1104522257834310906.davem@davemloft.net>
References: <1348562883-14780-1-git-send-email-nikolay@redhat.com>
	<1349169386-18391-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, agospoda@redhat.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab2JCCkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:40:36 -0400
In-Reply-To: <1349169386-18391-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue,  2 Oct 2012 11:16:26 +0200

> This patch allows LRO aggregation on bonded devices that contain an NX3031
> device. It also adds a for_each_netdev_in_bond_rcu(bond, slave) macro
> which executes for each slave that has bond as master.
> 
> V2: Remove local ip caching, retrieve addresses dynamically and
>     restore them if necessary.
> 
> Note: Tested with NX3031 adapter.
> 
> Signed-off-by: Andy Gospodarek <agospoda@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

This doesn't apply cleanly to the current tree.

It is also poorly styled, for example:

> +				if (addr) {
> +					netxen_config_ipaddr(adapter, addr,
> +							     ip_event);
> +				}

No curley braces for a single statement.

There are also a lot of extransoue empty lines added to the
code which do not enhance readability in any way and just take
up valuable vertical screen realestate.

You've also missed the net-next merge window cutoff, so you'll
need to wait until after the merge window to send this in again.

Thanks.
