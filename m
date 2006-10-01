From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Sun, 1 Oct 2006 11:52:51 +1000
Message-ID: <20061001015251.GA3795@gondor.apana.org.au>
References: <200609302223.47627.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, axboe@suse.de,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1033 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751387AbWJABxF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 21:53:05 -0400
To: Ismail Donmez <ismail@pardus.org.tr>
Content-Disposition: inline
In-Reply-To: <200609302223.47627.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 30, 2006 at 10:23:46PM +0300, Ismail Donmez wrote:
> 
> With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
> changed behaviour so it returns false when the node is empty as expected. 
> Hence Herbert's fix for sched_htb.c should be reverted.

I've fixed sched_htb.c? That's news to me :)

I fully agree with your patch though.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
