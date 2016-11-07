From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Fixes: 5943634fc559 ("ipv4: Maintain redirect and
 PMTU info in struct rtable again.")
Date: Mon, 07 Nov 2016 11:20:16 -0500 (EST)
Message-ID: <20161107.112016.598403889913912857.davem@davemloft.net>
References: <1478531058-12701-1-git-send-email-ssurya@ieee.org>
        <1478534932.17367.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.suryaputra.lin@gmail.com, netdev@vger.kernel.org,
        ssurya@ieee.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932343AbcKGQUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 11:20:18 -0500
In-Reply-To: <1478534932.17367.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Nov 2016 08:08:52 -0800

> In any case, rt is a shared object at that time, so even temporarily
> clearing/restoring rt_gateway seems wrong to me.
> 
> I would rather call __ipv4_neigh_lookup(dst->dev, new_gw) directly at
> this point.

Agreed.
