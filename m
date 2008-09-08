From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [rfc 1/3] ipvs: handle PARTIAL_CHECKSUM
Date: Mon, 8 Sep 2008 19:54:04 +1000
Message-ID: <20080908095403.GA14746@gondor.apana.org.au>
References: <20080908020420.313463898@vergenet.net> <20080908021535.063462678@vergenet.net> <20080908072439.GA27257@gondor.apana.org.au> <20080908090525.GA855@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	Siim =?iso-8859-1?B?UMO1ZGVy?= <siim@p6drad-teel.net>,
	Julian Anastasov <ja@ssi.bg>,
	Malcolm Turnbull <malcolm@loadbalancer.org>,
	Julius Volz <juliusv@google.com>,
	Vince Busam <vbusam@google.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080908090525.GA855@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 08, 2008 at 07:05:27PM +1000, Simon Horman wrote:
> 
> If cp->app is not present, then only the destiantion IP address
> and possibly port will have been altered. If it is present,
> then other parts of the packet may also have been altered.

Right, when cp->app is present, and we're using partial checksums,
you don't need to update anything apart from the IP address because
the hardware will compute the checksum later.

Thanks for the explanation!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
