From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] crypto: algif_hash - User-space interface for hash
 operations
Date: Thu, 04 Nov 2010 12:23:19 -0700 (PDT)
Message-ID: <20101104.122319.183032357.davem@davemloft.net>
References: <20101104173456.GA1321@gondor.apana.org.au>
	<E1PE3jX-0000MX-UB@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1PE3jX-0000MX-UB@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 04 Nov 2010 12:36:19 -0500

> crypto: algif_hash - User-space interface for hash operations
> 
> This patch adds the af_alg plugin for hash, corresponding to
> the ahash kernel operation type.
> 
> Keys can optionally be set through the setsockopt interface.
> 
> Each sendmsg call will finalise the hash unless sent with a MSG_MORE
> flag.
> 
> Partial hash states can be cloned using accept(2).
> 
> The interface is completely synchronous, all operations will
> complete prior to the system call returning.
> 
> Both sendmsg(2) and splice(2) support reading the user-space
> data directly without copying (except that the Crypto API itself
> may copy the data if alignment is off).
> 
> For now only the splice(2) interface supports performing digest
> instead of init/update/final.  In future the sendmsg(2) interface
> will also be modified to use digest/finup where possible so that
> hardware that cannot return a partial hash state can still benefit
> from this interface.
> 
> Thakns to Miloslav Trmac for reviewing this and contributing
> fixes and improvements.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>
