From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] crypto/x509: Fix unaligned access in
 x509_get_sig_params()
Date: Tue, 20 Oct 2015 22:26:41 +0800
Message-ID: <20151020142641.GJ7625@gondor.apana.org.au>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
 <288f39ff7c8b0bc60693e338fc8f6cea9008d443.1445286755.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com, davem@davemloft.net,
	zohar@linux.vnet.ibm.com, David.Woodhouse@intel.com,
	steffen.klassert@secunet.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <288f39ff7c8b0bc60693e338fc8f6cea9008d443.1445286755.git.sowmini.varadhan@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 19, 2015 at 05:23:28PM -0400, Sowmini Varadhan wrote:
> x509_get_sig_params() has the same code pattern as the one in
> pkcs7_verify() that is fixed by commit 62f57d05e287 ("crypto: pkcs7 - Fix
> unaligned access in pkcs7_verify()") so apply a similar fix here: make
> sure that desc is pointing at an algined value past the digest_size,
> and take alignment values into consideration when doing kzalloc()
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Patch applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
