From: David Miller <davem@davemloft.net>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Thu, 10 Jan 2008 03:56:35 -0800 (PST)
Message-ID: <20080110.035635.229679928.davem@davemloft.net>
References: <47847A10.1020508@cosmosbay.com>
	<20080109094637.GA28874@gondor.apana.org.au>
	<20080109113727.50eae500.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43259
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757236AbYAJL4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 06:56:41 -0500
In-Reply-To: <20080109113727.50eae500.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 9 Jan 2008 11:37:27 +0100

> [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
> 
> In rt_cache_get_next(), no need to guard seq->private by a rcu_dereference()
> since seq is private to the thread running this function. Reading seq.private
> once (as guaranted bu rcu_dereference()) or several time if compiler really is 
> dumb enough wont change the result.
> 
> But we miss real spots where rcu_dereference() are needed, both in 
> rt_cache_get_first() and rt_cache_get_next()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I've applied this to net-2.6, thanks!
