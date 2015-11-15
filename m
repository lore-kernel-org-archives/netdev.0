From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: ensure proper barriers in lockless contexts
Date: Sun, 15 Nov 2015 18:37:03 -0500 (EST)
Message-ID: <20151115.183703.577812988592183622.davem@davemloft.net>
References: <1447346598.22599.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbbKOXhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 18:37:05 -0500
In-Reply-To: <1447346598.22599.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Nov 2015 08:43:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Some functions access TCP sockets without holding a lock and
> might output non consistent data, depending on compiler and or
> architecture.
> 
> tcp_diag_get_info(), tcp_get_info(), tcp_poll(), get_tcp4_sock() ...
> 
> Introduce sk_state_load() and sk_state_store() to fix the issues,
> and more clearly document where this lack of locking is happening.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
