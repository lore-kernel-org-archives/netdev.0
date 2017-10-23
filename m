From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/8] mlxsw: Add support for non-equal-cost
 multi-path
Date: Mon, 23 Oct 2017 05:27:30 +0100 (WEST)
Message-ID: <20171023.052730.1826275066929092363.davem@davemloft.net>
References: <20171022211150.2567-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbdJWE1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:27:34 -0400
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 22 Oct 2017 23:11:42 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> In the device, nexthops are stored as adjacency entries in an array
> called the KVD linear (KVDL). When a multi-path route is hit the
> packet's headers are hashed and then converted to an index into KVDL
> based on the adjacency group's size and base index.
> 
> Up until now the driver ignored the `weight` parameter for multi-path
> routes and allocated only one adjacency entry for each nexthop with a
> limit of 32 nexthops in a group. This set makes the driver take the
> `weight` parameter into account when allocating adjacency entries.
> 
> First patch teaches dpipe to show the size of the adjacency group, so
> that users will be able to determine the actual weight of each nexthop.
> The second patch refactors the KVDL allocator, making it more receptive
> towards the addition of another partition later in the set.
> 
> Patches 3-5 introduce small changes towards the actual change in the
> sixth patch that populates the adjacency entries according to their
> relative weight.
> 
> Last two patches finally add another partition to the KVDL, which allows
> us to allocate more than 32 entries per-group and thus support more
> nexthops and also provide higher accuracy with regards to the requested
> weights.

Series applied, thank you.
