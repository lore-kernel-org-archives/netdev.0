From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [take1] d80211: switch crypto to use new ciphers API
Date: Tue, 31 Oct 2006 12:03:27 +1100
Message-ID: <20061031010327.GB26146@gondor.apana.org.au>
References: <20061025224150.GA7364@devicescape.com> <20061026000624.GA29389@gondor.apana.org.au> <20061030180858.GA12593@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16399 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161497AbWJaBD4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 20:03:56 -0500
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061030180858.GA12593@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2006 at 10:08:58AM -0800, David Kimdon wrote:
> 
> Updated patch, now aes, tkip and wep are all tested.
> 
> Changes from take0:
> 
> Use IS_ERR() to evaluate return value of crypto_alloc_cipher().  Use
> ciper interface rather than blkcipher for aes encryption since we only
> encrypt a single block at a time.
> 
> --------
> 
> Switch d80211 software crypto to use the new cipher API.
> 
> Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Thanks David.  Looks good here.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
