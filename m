From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Tue, 8 Jan 2008 07:38:46 +1100
Message-ID: <20080107203845.GA29803@gondor.apana.org.au>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com> <E1JBqpd-0006vB-00@gondolin.me.apana.org.au> <20080107145624.05918cea.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3024 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754766AbYAGUjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 15:39:18 -0500
Content-Disposition: inline
In-Reply-To: <20080107145624.05918cea.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2008 at 02:56:24PM +0100, Eric Dumazet wrote:
> 
> AFAIK, this patch reduces complexity and text size.

But if we had loads of empty hash buckets couldn't this potentially
increase latency by disabling BH longer than before?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
