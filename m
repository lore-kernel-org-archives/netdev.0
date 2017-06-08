From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vrf: Make add_fib_rules per network namespace flag
Date: Thu, 08 Jun 2017 19:28:36 -0400 (EDT)
Message-ID: <20170608.192836.1501451775101159374.davem@davemloft.net>
References: <20170608173111.22831-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrm@mellanox.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdFHX2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 19:28:43 -0400
In-Reply-To: <20170608173111.22831-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu,  8 Jun 2017 11:31:11 -0600

> Commit 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")
> adds the l3mdev FIB rule the first time a VRF device is created. However,
> it only creates the rule once and only in the namespace the first device
> is created - which may not be init_net. Fix by using the net_generic
> capability to make the add_fib_rules flag per network namespace.
> 
> Fixes: 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")
> Reported-by: Petr Machata <petrm@mellanox.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Yeah that's not very helpful behavior.

Applied and queued up for -stable, thanks David.
