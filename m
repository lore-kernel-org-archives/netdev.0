From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] crypto: af_alg - add TLS type encryption
Date: Fri, 8 Apr 2016 10:52:50 +0800
Message-ID: <20160408025250.GA7596@gondor.apana.org.au>
References: <20160306012044.6369.63924.stgit@tstruk-mobl1>
 <20160405112940.GB11852@gondor.apana.org.au>
 <57054DBC.8010507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57054DBC.8010507@intel.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2016 at 10:56:12AM -0700, Tadeusz Struk wrote:
> 
> The intend is to enable HW acceleration of the TLS protocol.
> The way it will work is that the user space will send a packet of data
> via AF_ALG and HW will authenticate and encrypt it in one go.

There have been suggestions to implement TLS data-path within
the kernel.  So we should decide whether we pursue that or go
with your approach before we start adding algorithms.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
