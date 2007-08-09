From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Wed, 08 Aug 2007 18:48:24 -0700 (PDT)
Message-ID: <20070808.184824.133910636.davem@davemloft.net>
References: <20070808230733.GA17270@shell.boston.redhat.com>
	<E1IIwQx-000468-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57196
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756466AbXHIBsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 21:48:24 -0400
In-Reply-To: <E1IIwQx-000468-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 09 Aug 2007 09:03:27 +0800

> Such loops should always use something like cpu_relax() which comes
> with a barrier.

This is an excellent point.

And it needs to be weighed with the error prone'ness Andrew mentioned.
There probably is a middle ground somewhere.
