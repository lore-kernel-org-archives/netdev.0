From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] mlxsw: Add support for nexthop group
 consolidation for IPv6
Date: Mon, 14 Aug 2017 22:24:46 -0700 (PDT)
Message-ID: <20170814.222446.2291698336308702761.davem@davemloft.net>
References: <20170814190920.9576-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdHOFYr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:24:47 -0400
In-Reply-To: <20170814190920.9576-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 14 Aug 2017 21:09:18 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Arkadi says:
> 
> Due to limited ASIC resources the maximum number of routes is limited by
> the nexthop resource. In order to improve the routing scale nexthop
> consolidation should be performed.
> 
> In case of IPv4, the kernel does the consolidation of nexthops in the form
> of the fib_info struct. In that case, the driver uses the fib_info's
> address as a key for the internal nexthop group representative struct
> lookup. In case of IPv6, the kernel doesn't do consolidation, thus the
> driver should implement it by itself.
> 
> The hash value is calculated based on the nexthop set, by performing
> bitwise xor on the ifindexs of the nexthops, in a similar way to IPV4's
> kernel implementation. In case of collision a full match is performed
> between the sets which include address and ifindex comparison.
> 
> In order to use the same hash table in both cases (IPv4/6), the rhashtable
> is changed to operate on variable length key.

Series applied, thanks.
