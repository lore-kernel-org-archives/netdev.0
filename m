From: David Miller <davem@davemloft.net>
Subject: Re: route.c:645 suspicious rcu_dereference_check()
Date: Thu, 30 Aug 2012 13:34:33 -0400 (EDT)
Message-ID: <20120830.133433.566450758375930776.davem@davemloft.net>
References: <20120828175734.41b17a6c@mj>
	<1346193187.3571.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: proski@gnu.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab2H3Ref (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:34:35 -0400
In-Reply-To: <1346193187.3571.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Aug 2012 15:33:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> [PATCH] ipv4: must use rcu protection while calling fib_lookup
> 
> Following lockdep splat was reported by Pavel Roskin :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Pavel Roskin <proski@gnu.org>

Applied, thanks.

It looks like the redirect handlers might have the same problem?
