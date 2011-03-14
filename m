From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC v2 PATCH 1/9] crypto: authencesn - Add algorithm to
 handle IPsec extended sequence numbers
Date: Mon, 14 Mar 2011 09:37:41 +0100
Message-ID: <20110314083741.GN31402@secunet.com>
References: <20110308100407.GB31402@secunet.com>
 <20110308100458.GC31402@secunet.com>
 <20110313063017.GA10849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alex Badea <abadea@ixiacom.com>,
	Andreas Gruenbacher <agruen@suse.de>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110313063017.GA10849@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 13, 2011 at 02:30:17PM +0800, Herbert Xu wrote:
> On Tue, Mar 08, 2011 at 11:04:58AM +0100, Steffen Klassert wrote:
> >
> > +	return crypto_authenc_esn_genicv(req, iv, CRYPTO_TFM_REQ_MAY_SLEEP);
> 
> BTW, we should get rid of these MAY_SLEEP flags.  Originally I
> included them for the IPsec encryption path because that happens
> to be sleepable. We should instead be getting it from the request
> itself.
> 

Not sure if I get you right, but we do not set this flag here.
We use it to mask the flags we got from the request, so we pass
this flag to the ahash algorithm just if it was set by the
original aead request.
