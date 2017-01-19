From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: Do not reuse pages from emergency reserve
Date: Thu, 19 Jan 2017 11:50:03 -0500 (EST)
Message-ID: <20170119.115003.1254899603401185224.davem@davemloft.net>
References: <1484797482.16328.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753251AbdASQum (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:50:42 -0500
In-Reply-To: <1484797482.16328.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jan 2017 19:44:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> A driver using dev_alloc_page() must not reuse a page that had to
> use emergency memory reserve.
> 
> Otherwise all packets using this page will be immediately dropped,
> unless for very specific sockets having SOCK_MEMALLOC bit set.
> 
> This issue might be hard to debug, because only a fraction of the RX
> ring buffer would suffer from drops.
> 
> Fixes: 75354148ce69 ("gianfar: Add paged allocation and Rx S/G")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
