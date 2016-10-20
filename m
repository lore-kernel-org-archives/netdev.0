From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sched: act_mirred: Use passed lastuse argument
Date: Thu, 20 Oct 2016 11:15:07 -0400 (EDT)
Message-ID: <20161020.111507.1336932324302066566.davem@davemloft.net>
References: <1476888159-30332-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirva@mellanox.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, paulb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964843AbcJTPPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:15:09 -0400
In-Reply-To: <1476888159-30332-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 19 Oct 2016 17:42:39 +0300

> From: Paul Blakey <paulb@mellanox.com>
> 
> stats_update callback is called by NIC drivers doing hardware
> offloading of the mirred action. Lastuse is passed as argument
> to specify when the stats was actually last updated and is not
> always the current time.
> 
> Fixes: 9798e6fe4f9b ('net: act_mirred: allow statistic updates from offloaded actions')
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
