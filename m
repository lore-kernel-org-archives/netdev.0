From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Tue, 8 Jan 2008 07:48:41 +1100
Message-ID: <20080107204841.GA30297@gondor.apana.org.au>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com> <E1JBqpd-0006vB-00@gondolin.me.apana.org.au> <20080107145624.05918cea.dada1@cosmosbay.com> <20080107203845.GA29803@gondor.apana.org.au> <47828FB5.1030303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3507 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753882AbYAGVEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 16:04:52 -0500
Content-Disposition: inline
In-Reply-To: <47828FB5.1030303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2008 at 09:46:45PM +0100, Eric Dumazet wrote:
>
> Well, we call rcu_read_unlock_bh()/rcu_read_lock_bh() for each bucket, 
> empty or not, before and after patch, so we dont change latency.

Oh I see.  Your patch looks good then.  But we still need a solution
in general unless we're to avoid all uses of conditional locking.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
