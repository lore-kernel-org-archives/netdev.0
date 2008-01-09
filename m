From: David Miller <davem@davemloft.net>
Subject: Re: [SOCK]: Adds a rcu_dereference() in sk_filter
Date: Tue, 08 Jan 2008 23:41:54 -0800 (PST)
Message-ID: <20080108.234154.107152881.davem@davemloft.net>
References: <4783DDBF.2040303@cosmosbay.com>
	<E1JCUFO-00079j-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, dim@openvz.org,
	kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48332
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbYAIHlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:41:55 -0500
In-Reply-To: <E1JCUFO-00079j-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 09 Jan 2008 17:17:06 +1100

> Eric Dumazet <dada1@cosmosbay.com> wrote:
> > 
> > It seems commit fda9ef5d679b07c9d9097aaf6ef7f069d794a8f9 introduced a RCU 
> > protection for sk_filter(), without a rcu_dereference()
> > 
> > Either we need a rcu_dereference(), either a comment should explain why we 
> > dont need it. I vote for the former.
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
