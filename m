From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Verify key payload in verify_one_algo
Date: Thu, 19 May 2005 12:40:59 -0700 (PDT)
Message-ID: <20050519.124059.85410159.davem@davemloft.net>
References: <20050519020302.GA20285@gondor.apana.org.au>
	<20050519021505.GA20703@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050519021505.GA20703@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 19 May 2005 12:15:05 +1000

> We need to verify that the payload contains enough data so that
> attach_one_algo can copy alg_key_len bits from the payload.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks again.

I gather from these two patches that once you found the
first problem you went around auditing alg_key_len usage
and these were the only two bugs you spotted.  Right?
