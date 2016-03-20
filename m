From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: remove a dubious unlikely() clause
Date: Sun, 20 Mar 2016 16:32:19 -0400 (EDT)
Message-ID: <20160320.163219.2048951134824961876.davem@davemloft.net>
References: <1458498467.10868.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbcCTUcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 16:32:21 -0400
In-Reply-To: <1458498467.10868.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 20 Mar 2016 11:27:47 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP protocol is still used these days, and TCP uses
> clones in its transmit path. We can not optimize linux
> stack assuming it is mostly used in routers, or that TCP
> is dead.
> 
> Fixes: 795bb1c00d ("net: bulk free infrastructure for NAPI context, use napi_consume_skb")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Applied.
