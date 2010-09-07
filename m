From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 22:11:12 +0800
Message-ID: <20100907141112.GB6903@gondor.apana.org.au>
References: <20100907084213.GA4610@gondor.apana.org.au> <20100907140646.GA31921@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100907140646.GA31921@infradead.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 10:06:46AM -0400, Christoph Hellwig wrote:
> On Tue, Sep 07, 2010 at 04:42:13PM +0800, Herbert Xu wrote:
> > Hi:
> > 
> > This is what I am proposing for the Crypto API user-interface.
> 
> Can you explain why we would ever want a userspace interface to it?
> 
> doing crypto in kernel for userspace consumers sis simply insane.
> It's computational intensive code which has no business in kernel space
> unless absolutely required (e.g. for kernel consumers).  In addition
> to that adding the context switch overhead and address space transitions
> is god awfull too.
> 
> This all very much sounds like someone had far too much crack.

FWIW I don't care about user-space using kernel software crypto at
all.  It's the security people that do.

The purpose of the user-space API is to export the hardware crypto
devices to user-space.  This means PCI devices mostly, as things
like aesni-intel can already be used without kernel help.

Now as a side-effect if this means that we can shut the security
people up about adding another interface then all the better.  But
I will certainly not go out of the way to add more crap to the
kernel for that purpose.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
