From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] team: Replace rcu_read_lock with a mutex in
 team_vlan_rx_kill_vid
Date: Mon, 18 Jan 2016 11:55:38 -0500 (EST)
Message-ID: <20160118.115538.1753600494506800913.davem@davemloft.net>
References: <1453131022-23818-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755931AbcARQzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 11:55:39 -0500
In-Reply-To: <1453131022-23818-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Mon, 18 Jan 2016 17:30:22 +0200

> We can't be within an RCU read-side critical section when deleting
> VLANs, as underlying drivers might sleep during the hardware operation.
> Therefore, replace the RCU critical section with a mutex. This is
> consistent with team_vlan_rx_add_vid.
> 
> Fixes: 3d249d4ca7d0 ("net: introduce ethernet teaming device")
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Applied and queued up for -stable, thanks.
