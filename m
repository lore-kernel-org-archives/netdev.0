From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net: Detect drivers that reschedule NAPI and
 exhaust budget
Date: Tue, 23 Dec 2014 23:20:42 -0500 (EST)
Message-ID: <20141223.232042.1356795429868323688.davem@davemloft.net>
References: <20141220201453.GA6924@gondor.apana.org.au>
	<E1Y2QRq-0001pW-Tn@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbaLXEUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 23:20:44 -0500
In-Reply-To: <E1Y2QRq-0001pW-Tn@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 21 Dec 2014 07:16:22 +1100

> The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
> interrupt masking in NAPI) required drivers to leave poll_list
> empty if the entire budget is consumed.
> 
> We have already had two broken drivers so let's add a check for
> this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
