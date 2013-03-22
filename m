From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: preserve ACK clocking in TSO
Date: Fri, 22 Mar 2013 10:34:35 -0400 (EDT)
Message-ID: <20130322.103435.879689479406836333.davem@davemloft.net>
References: <1363923369.4431.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	nanditad@google.com, vanj@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933519Ab3CVOei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:34:38 -0400
In-Reply-To: <1363923369.4431.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Mar 2013 20:36:09 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> A long standing problem with TSO is the fact that tcp_tso_should_defer()
> rearms the deferred timer, while it should not.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I always wondered about this, good catch.

Applied and queued up for -stable, thanks!
