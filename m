From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: core: Correctly iterate over lower adjacency
 list
Date: Wed, 19 Oct 2016 10:38:29 -0400 (EDT)
Message-ID: <20161019.103829.1873231752009765175.davem@davemloft.net>
References: <1476885428-5189-1-git-send-email-idosch@idosch.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        dsa@cumulusnetworks.com, idosch@mellanox.com
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56016 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932591AbcJSOib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:38:31 -0400
In-Reply-To: <1476885428-5189-1-git-send-email-idosch@idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: idosch@idosch.org
Date: Wed, 19 Oct 2016 16:57:08 +0300

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Tamir reported the following trace when processing ARP requests received
> via a vlan device on top of a VLAN-aware bridge:
 ...
> The problem is that netdev_all_lower_get_next_rcu() never advances the
> iterator, thereby causing the loop over the lower adjacency list to run
> forever.
> 
> Fix this by advancing the iterator and avoid the infinite loop.
> 
> Fixes: 7ce856aaaf13 ("mlxsw: spectrum: Add couple of lower device helper functions")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Tamir Winetroub <tamirw@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied.
