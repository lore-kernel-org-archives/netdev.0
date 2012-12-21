From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: fix possible use after free
Date: Fri, 21 Dec 2012 13:15:22 -0800 (PST)
Message-ID: <20121221.131522.1237366130565709662.davem@davemloft.net>
References: <1356055227.21834.4097.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yamahata@valinux.co.jp
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011Ab2LUVPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 16:15:23 -0500
In-Reply-To: <1356055227.21834.4097.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Thu, 20 Dec 2012 18:00:27 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Once skb_realloc_headroom() is called, tiph might point to freed memory.
> 
> Cache tiph->ttl value before the reallocation, to avoid unexpected
> behavior.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Isaku Yamahata <yamahata@valinux.co.jp>

Applied.
