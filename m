From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] niu: remove one compound_head() call
Date: Sat, 17 Jan 2015 23:59:04 -0500 (EST)
Message-ID: <20150117.235904.941407588442229019.davem@davemloft.net>
References: <1421415570.11734.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbbARE7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 23:59:05 -0500
In-Reply-To: <1421415570.11734.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Jan 2015 05:39:30 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> After a "page = alloc_page(mask);", we do not need to use
> compound_head() : page already points to the right place.
> 
> This would be true even if using alloc_pages().
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
