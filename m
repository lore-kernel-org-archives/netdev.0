From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: Do not drop to make_route if oif is l3mdev
Date: Thu, 13 Oct 2016 12:05:50 -0400 (EDT)
Message-ID: <20161013.120550.886221045348261348.davem@davemloft.net>
References: <1476303611-28154-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756577AbcJMQFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 12:05:52 -0400
In-Reply-To: <1476303611-28154-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 12 Oct 2016 13:20:11 -0700

> Commit e0d56fdd7342 was a bit aggressive removing l3mdev calls in
> the IPv4 stack. If the fib_lookup fails we do not want to drop to
> make_route if the oif is an l3mdev device.
> 
> Also reverts 19664c6a0009 ("net: l3mdev: Remove netif_index_is_l3_master")
> which removed netif_index_is_l3_master.
> 
> Fixes: e0d56fdd7342 ("net: l3mdev: remove redundant calls")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
