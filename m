From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: small napi_get_frags() optim
Date: Fri, 06 Dec 2013 12:52:39 -0500 (EST)
Message-ID: <20131206.125239.591330780647291086.davem@davemloft.net>
References: <1386308667.30495.230.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab3LFRwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:52:40 -0500
In-Reply-To: <1386308667.30495.230.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Dec 2013 21:44:27 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Remove one useless conditional branch : 
> napi->skb is NULL, so nothing bad can happen.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
