From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if
 subtree does not match
Date: Wed, 07 Aug 2013 17:17:57 -0700 (PDT)
Message-ID: <20130807.171757.2288573843214009818.davem@davemloft.net>
References: <20130807003431.GD16410@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, teco@inf-net.nl, yoshfuji@linux-ipv6.org,
	equinox@diac24.net, boutier@pps.univ-paris-diderot.fr
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933010Ab3HHAMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 20:12:42 -0400
In-Reply-To: <20130807003431.GD16410@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 7 Aug 2013 02:34:31 +0200

> In case a subtree did not match we currently stop backtracking and return
> NULL (root table from fib_lookup). This could yield in invalid routing
> table lookups when using subtrees.
> 
> Instead continue to backtrack until a valid subtree or node is found
> and return this match.
> 
> Also remove unneeded NULL check.
> 
> Reported-by: Teco Boot <teco@inf-net.nl>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: David Lamparter <equinox@diac24.net>
> Cc: <boutier@pps.univ-paris-diderot.fr>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and qeued up for -stable, thanks!
