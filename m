From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPCOMP] Use per-cpu buffers
Date: Sat, 11 Sep 2004 08:33:15 +1000
Sender: linux-ppp-owner@vger.kernel.org
Message-ID: <20040910223315.GA1335@gondor.apana.org.au>
References: <20040910111047.GA29330@gondor.apana.org.au> <Xine.LNX.4.44.0409101140160.6664-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	netdev@oss.sgi.com, linux-ppp@vger.kernel.org, paulus@samba.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0409101140160.6664-100000@thoron.boston.redhat.com>
List-Id: netdev.vger.kernel.org

On Fri, Sep 10, 2004 at 11:42:00AM -0400, James Morris wrote:
> 
> I haven't looked at the code for a while, but I think we might be able to 
> save some memory by specifying compression parameters and making the 
> appropriate changes to zlib.

It'd also be nice to add a compression algorithm that requires little 
memory to run.  That way we can get a clear picture of what interface
changes are OK and what aren't.

Could we perhaps use v44? Is the patent an issue?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
