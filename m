From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_router: Correctly reallocate
 adjacency entries
Date: Tue, 24 Jan 2017 13:45:02 -0500 (EST)
Message-ID: <20170124.134502.48158963519122839.davem@davemloft.net>
References: <1485166302-5629-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54514 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAXSpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:45:04 -0500
In-Reply-To: <1485166302-5629-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 23 Jan 2017 11:11:42 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> mlxsw_sp_nexthop_group_mac_update() is called in one of two cases:
> 
> 1) When the MAC of a nexthop needs to be updated
> 2) When the size of a nexthop group has changed
> 
> In the second case the adjacency entries for the nexthop group need to
> be reallocated from the adjacency table. In this case we must write to
> the entries the MAC addresses of all the nexthops that should be
> offloaded and not only those whose MAC changed. Otherwise, these entries
> would be filled with garbage data, resulting in packet loss.
> 
> Fixes: a7ff87acd995 ("mlxsw: spectrum_router: Implement next-hop routing")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
