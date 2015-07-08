From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: graceful exit from netif_alloc_netdev_queues()
Date: Wed, 08 Jul 2015 15:50:41 -0700 (PDT)
Message-ID: <20150708.155041.406258593466011752.davem@davemloft.net>
References: <1436195606.4571.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbbGHWuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 18:50:44 -0400
In-Reply-To: <1436195606.4571.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jul 2015 17:13:26 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> User space can crash kernel with
> 
> ip link add ifb10 numtxqueues 100000 type ifb
> 
> We must replace a BUG_ON() by proper test and return -EINVAL for
> crazy values.
> 
> Fixes: 60877a32bce00 ("net: allow large number of tx queues")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
