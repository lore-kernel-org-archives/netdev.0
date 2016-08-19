From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv3 net-next 3/4] chcr: Support for Chelsio's Crypto
 Hardware
Date: Fri, 19 Aug 2016 14:15:22 +0800
Message-ID: <20160819061522.GA20778@gondor.apana.org.au>
References: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
 <1471417386-14026-4-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
        davem@davemloft.net, atul.gupta@chelsio.com, yeshaswi@chelsio.com,
        jlulla@chelsio.com, harsh@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471417386-14026-4-git-send-email-hariprasad@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 17, 2016 at 12:33:05PM +0530, Hariprasad Shenai wrote:
> The Chelsio's Crypto Hardware can perform the following operations:
> SHA1, SHA224, SHA256, SHA384 and SHA512, HMAC(SHA1), HMAC(SHA224),
> HMAC(SHA256), HMAC(SHA384), HAMC(SHA512), AES-128-CBC, AES-192-CBC,
> AES-256-CBC, AES-128-XTS, AES-256-XTS
> 
> This patch implements the driver for above mentioned features. This
> driver is an Upper Layer Driver which is attached to Chelsio's LLD
> (cxgb4) and uses the queue allocated by the LLD for sending the crypto
> requests to the Hardware and receiving the responses from it.
> 
> The crypto operations can be performed by Chelsio's hardware from the
> userspace applications and/or from within the kernel space using the
> kernel's crypto API.
> 
> The above mentioned crypto features have been tested using kernel's
> tests mentioned in testmgr.h. They also have been tested from user
> space using libkcapi and Openssl.
> 
> Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
