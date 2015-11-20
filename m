From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: avoid NULL deref in napi_get_frags()
Date: Fri, 20 Nov 2015 16:43:41 -0500 (EST)
Message-ID: <20151120.164341.690387047334261056.davem@davemloft.net>
References: <1447963883.22599.243.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932397AbbKTVnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 16:43:43 -0500
In-Reply-To: <1447963883.22599.243.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Nov 2015 12:11:23 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> napi_alloc_skb() can return NULL.
> We should not crash should this happen.
> 
> Fixes: 93f93a440415 ("net: move skb_mark_napi_id() into core networking stack")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
