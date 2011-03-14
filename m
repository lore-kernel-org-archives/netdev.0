From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC v2 PATCH 1/9] crypto: authencesn - Add algorithm to
 handle IPsec extended sequence numbers
Date: Mon, 14 Mar 2011 11:02:45 +0100
Message-ID: <20110314100245.GO31402@secunet.com>
References: <20110308100407.GB31402@secunet.com>
 <20110308100458.GC31402@secunet.com>
 <20110313063017.GA10849@gondor.apana.org.au>
 <20110314083741.GN31402@secunet.com>
 <20110314093907.GA25957@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alex Badea <abadea@ixiacom.com>,
	Andreas Gruenbacher <agruen@suse.de>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110314093907.GA25957@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2011 at 05:39:07PM +0800, Herbert Xu wrote:
> > 
> > Not sure if I get you right, but we do not set this flag here.
> > We use it to mask the flags we got from the request, so we pass
> > this flag to the ahash algorithm just if it was set by the
> > original aead request.
> 
> Indeed you are right.  As long as it is only a mask and only
> used on the sync path it should be OK.
> 

Yes, that's how it is used in both, authenc and authencesn.
