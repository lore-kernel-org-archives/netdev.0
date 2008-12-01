From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 4/5] crypto: allow allocation of percpu crypto
	transforms
Date: Mon, 1 Dec 2008 20:38:59 +0800
Message-ID: <20081201123859.GA21424@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201071943.GT476@secunet.com> <20081201113828.GA20961@gondor.apana.org.au> <20081201.042502.223043756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34588 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750833AbYLAMjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 07:39:08 -0500
Content-Disposition: inline
In-Reply-To: <20081201.042502.223043756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 04:25:02AM -0800, David Miller wrote:
>
> If, in those changes, I was removing atomics to make rule insert and
> delete faster, making more TFM allocs happen might be a big no-no :)

Fair enough.  But it looks like this stuff only exists because of
the spinlock on the hash which shash will get rid of anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
